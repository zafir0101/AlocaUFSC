package alocaufsc.domain.allocationsystem;

import alocaufsc.domain.entities.Entity;
import alocaufsc.domain.entities.User;
import alocaufsc.domain.eventsystem.Event;
import alocaufsc.domain.eventsystem.EventStatus;
import alocaufsc.domain.notificationsystem.Notification;
import alocaufsc.domain.notificationsystem.NotificationType;
import alocaufsc.technicalservices.persistence.FacadeDbRest;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.List;
import java.util.NoSuchElementException;

@Service
public class AllocationService {
    public static final int MAX_REJECTION_REASON_LENGTH = 500;
    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final FacadeDbRest facadeDb;

    public AllocationService(FacadeDbRest facadeDb) {
        this.facadeDb = facadeDb;
    }

    public List<Venue> searchAvailableVenues(User user, LocalDateTime start, LocalDateTime end) {
        ensureUser(user);
        validatePeriod(start, end);
        return facadeDb.findAvailableVenues(start, end, null).stream()
                .filter(v -> v.allows(user.getEntity()))
                .sorted(Comparator.comparing(Venue::getCenter)
                        .thenComparing(Venue::getBuilding, String.CASE_INSENSITIVE_ORDER)
                        .thenComparing(Venue::getName, String.CASE_INSENSITIVE_ORDER))
                .toList();
    }

    public List<Event> getEligibleEvents(User user) {
        ensureUser(user);
        return facadeDb.findEventsByCreator(user).stream()
                .filter(this::isAllocatable)
                .filter(e -> !hasOpenAllocation(e.getId()))
                .toList();
    }

    public synchronized Allocation createAllocation(User user, AllocationInfo info) {
        ensureUser(user);
        if (info == null || info.eventId() == null) {
            throw new IllegalArgumentException("Selecione o evento ao qual a alocação será vinculada.");
        }
        if (info.venueId() == null || info.venueId().isBlank()) {
            throw new IllegalArgumentException("Selecione o espaço desejado.");
        }
        validatePeriod(info.start(), info.end());

        Event event = facadeDb.findEvent(info.eventId())
                .orElseThrow(() -> new NoSuchElementException("Evento não encontrado."));
        if (!event.getCreator().getId().equals(user.getId())) {
            throw new SecurityException("Você só pode solicitar alocação para eventos criados por você.");
        }
        if (!isAllocatable(event)) {
            throw new IllegalArgumentException("Este evento não pode receber uma alocação no status atual.");
        }
        if (hasOpenAllocation(event.getId())) {
            throw new IllegalArgumentException("Este evento já possui um pedido de alocação pendente ou aprovado.");
        }

        Venue venue = requireAvailableVenue(user, info.venueId(), info.start(), info.end(), null);

        Allocation allocation = new Allocation(null, venue, event, user, info.start(), info.end(),
                AllocationStatus.PENDING, LocalDateTime.now());
        return facadeDb.saveAllocation(allocation);
    }

    public synchronized Allocation updateAllocation(User user, Long id, AllocationInfo newData) {
        ensureUser(user);
        Allocation allocation = getAllocationEntity(id);
        if (!allocation.getRequester().getId().equals(user.getId())) {
            throw new SecurityException("Você só pode editar seus próprios pedidos de alocação.");
        }
        if (newData == null || newData.venueId() == null || newData.venueId().isBlank()) {
            throw new IllegalArgumentException("Selecione o espaço desejado.");
        }
        validatePeriod(newData.start(), newData.end());

        boolean changed = !newData.venueId().equals(allocation.getVenue().getId())
                || !newData.start().equals(allocation.getStart())
                || !newData.end().equals(allocation.getEnd());

        if (changed) {
            Venue venue = requireAvailableVenue(user, newData.venueId(), newData.start(), newData.end(), allocation.getId());
            boolean wasApproved = allocation.getStatus() == AllocationStatus.APPROVED;
            allocation.setStatus(AllocationStatus.PENDING);
            allocation.setReviewedBy(null);
            allocation.setReviewedAt(null);
            allocation.setRejectionReason(null);
            allocation.updateData(venue, newData.start(), newData.end());
            if (wasApproved) {
                // o espaço anterior foi liberado: o evento volta a aguardar local
                allocation.getEvent().setStatus(EventStatus.AGUARDANDO_LOCAL);
                facadeDb.saveEvent(allocation.getEvent());
            }
        }
        return facadeDb.saveAllocation(allocation);
    }

    public List<Allocation> getMyAllocations(User user) {
        ensureUser(user);
        return facadeDb.findAllocationsByRequester(user).stream()
                .sorted(Comparator.comparing(Allocation::getCreatedAt).reversed())
                .toList();
    }

    public Allocation getAllocation(User user, Long id) {
        ensureUser(user);
        Allocation allocation = getAllocationEntity(id);
        if (user.getEntity() != Entity.MANAGER && !allocation.getRequester().getId().equals(user.getId())) {
            throw new SecurityException("Você não tem permissão para ver este pedido de alocação.");
        }
        return allocation;
    }

    public List<Allocation> getAllocationByStatus(User admin, AllocationStatus status) {
        ensureAdmin(admin);
        if (status == null) {
            throw new IllegalArgumentException("Informe o status.");
        }
        return facadeDb.findAllocationsByStatus(status).stream()
                .sorted(Comparator.comparing(Allocation::getCreatedAt))
                .toList();
    }

    public synchronized Allocation approveAllocation(User admin, Long id) {
        ensureAdmin(admin);
        Allocation allocation = getAllocationEntity(id);
        ensurePending(allocation);

        boolean conflict = facadeDb.findAvailableVenues(allocation.getStart(), allocation.getEnd(), allocation.getId())
                .stream().noneMatch(v -> v.getId().equals(allocation.getVenue().getId()));
        if (conflict) {
            throw new IllegalStateException("Conflito de agenda: o espaço já está alocado neste período.");
        }

        allocation.setStatus(AllocationStatus.APPROVED);
        allocation.setReviewedBy(admin);
        allocation.setReviewedAt(LocalDateTime.now());
        allocation.setRejectionReason(null);
        Allocation saved = facadeDb.saveAllocation(allocation);

        Event event = saved.getEvent();
        event.setStatus(EventStatus.ALOCADO);
        facadeDb.saveEvent(event);

        notifyRequester(saved, NotificationType.ALOCACAO_APROVADA,
                "Seu pedido de alocação do evento \"" + event.getTitle() + "\" foi aprovado: "
                        + saved.getVenue().getName() + " (" + saved.getVenue().getLocation() + "), "
                        + saved.getStart().format(FMT) + " a " + saved.getEnd().format(FMT) + ".");
        return saved;
    }

    public synchronized Allocation rejectAllocation(User admin, Long id, String reason) {
        ensureAdmin(admin);
        if (reason != null && reason.trim().length() > MAX_REJECTION_REASON_LENGTH) {
            throw new IllegalArgumentException("O motivo deve ter no máximo " + MAX_REJECTION_REASON_LENGTH + " caracteres.");
        }
        Allocation allocation = getAllocationEntity(id);
        ensurePending(allocation);

        allocation.setStatus(AllocationStatus.REJECTED);
        allocation.setReviewedBy(admin);
        allocation.setReviewedAt(LocalDateTime.now());
        allocation.setRejectionReason(reason == null || reason.isBlank() ? null : reason.trim());
        Allocation saved = facadeDb.saveAllocation(allocation);

        Event event = saved.getEvent();
        event.setStatus(EventStatus.AGUARDANDO_LOCAL);
        facadeDb.saveEvent(event);

        String msg = "Seu pedido de alocação do evento \"" + event.getTitle() + "\" em "
                + saved.getVenue().getName() + " foi recusado.";
        if (saved.getRejectionReason() != null) {
            msg += " Motivo: " + saved.getRejectionReason();
        }
        notifyRequester(saved, NotificationType.ALOCACAO_RECUSADA, msg);
        return saved;
    }

    private Allocation getAllocationEntity(Long id) {
        return facadeDb.findAllocation(id)
                .orElseThrow(() -> new NoSuchElementException("Pedido de alocação não encontrado."));
    }

    private Venue requireAvailableVenue(User user, String venueId, LocalDateTime start, LocalDateTime end,
                                        Long ignoreAllocationId) {
        Venue venue = facadeDb.findAvailableVenues(start, end, ignoreAllocationId).stream()
                .filter(v -> v.getId().equals(venueId))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("O espaço selecionado não está disponível no período informado."));
        if (!venue.allows(user.getEntity())) {
            throw new SecurityException("Seu perfil não pode utilizar este espaço.");
        }
        return venue;
    }

    private boolean isAllocatable(Event event) {
        return event.getStatus() == EventStatus.ATIVO || event.getStatus() == EventStatus.AGUARDANDO_LOCAL;
    }

    private boolean hasOpenAllocation(Long eventId) {
        return facadeDb.findAllocationsByEvent(eventId).stream()
                .anyMatch(a -> a.getStatus() == AllocationStatus.PENDING || a.getStatus() == AllocationStatus.APPROVED);
    }

    private void ensurePending(Allocation allocation) {
        if (allocation.getStatus() != AllocationStatus.PENDING) {
            throw new IllegalStateException("Apenas pedidos pendentes podem ser analisados.");
        }
    }

    private void validatePeriod(LocalDateTime start, LocalDateTime end) {
        if (start == null || end == null) {
            throw new IllegalArgumentException("Informe o início e o fim do período.");
        }
        if (!end.isAfter(start)) {
            throw new IllegalArgumentException("O fim do período deve ser posterior ao início.");
        }
        if (start.isBefore(LocalDateTime.now())) {
            throw new IllegalArgumentException("O período não pode começar no passado.");
        }
    }

    private void notifyRequester(Allocation allocation, NotificationType type, String message) {
        facadeDb.saveNotification(new Notification(null, allocation.getRequeste(), type, message,
                allocation.getEvent().getId(), LocalDateTime.now(), false));
    }

    private void ensureUser(User user) {
        if (user == null) {
            throw new SecurityException("Usuário não autenticado.");
        }
    }

    private void ensureAdmin(User user) {
        if (user == null || user.getEntity() != Entity.MANAGER) {
            throw new SecurityException("Apenas administradores podem analisar pedidos de alocação.");
        }
    }
}