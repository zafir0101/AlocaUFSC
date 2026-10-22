package alocaufsc.domain.allocationsystem;

import alocaufsc.domain.entities.Entity;
import alocaufsc.domain.entities.User;
import alocaufsc.domain.eventsystem.Event;
import alocaufsc.domain.eventsystem.EventObserver;
import alocaufsc.technicalservices.persistence.FacadeDbRest;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.UUID;

@Service
public class AllocationService {
    public static final int MAX_REJECTION_REASON_LENGTH = 500;

    private final FacadeDbRest facadeDb;
    private final EventObserver eventObserver;

    public AllocationService(FacadeDbRest facadeDb, EventObserver eventObserver) {
        this.facadeDb = facadeDb;
        this.eventObserver = eventObserver;
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
        if (!event.isAllocatable()) {
            throw new IllegalArgumentException("Este evento não pode receber uma alocação no status atual.");
        }

        Venue venue = requireAvailableVenue(user, info.venueId(), info.start(), info.end(), null);

        Allocation allocation = new Allocation(UUID.randomUUID().toString(), venue, user, info.start(), info.end(),
                AllocationStatus.PENDING, LocalDateTime.now());

        event.setAllocation(allocation);
        eventObserver.addObserver(allocation.getId(), event);
        eventObserver.updateEventStatus(allocation.getId());

        return facadeDb.saveAllocation(allocation);
    }

    public synchronized void updateAllocation(User user, Allocation allocation, AllocationInfo allocationInfo) {
        ensureUser(user);
        if (!allocation.getRequester().getId().equals(user.getId())) {
            throw new SecurityException("Você só pode editar seus próprios pedidos de alocação.");
        }
        if (allocationInfo == null || allocationInfo.venueId() == null || allocationInfo.venueId().isBlank()) {
            throw new IllegalArgumentException("Selecione o espaço desejado.");
        }

        boolean conflict = facadeDb.findAvailableVenues(allocationInfo.start(), allocationInfo.end(), null)
                .stream().noneMatch(v -> v.getId().equals(allocation.getVenue().getId()));
        if (conflict) {
            allocation.setStatus(AllocationStatus.CANCELED);
            eventObserver.updateEventStatus(allocation.getId());
            return;
        }

        allocation.setStatus(AllocationStatus.PENDING);
        allocation.setReviewedBy(null);
        allocation.setReviewedAt(null);
        allocation.setRejectionReason(null);
        allocation.updateData(allocation.getVenue(), allocationInfo.start(), allocationInfo.end());

        facadeDb.saveAllocation(allocation);
        eventObserver.updateEventStatus(allocation.getId());
    }

    public List<Allocation> getMyAllocations(User user) {
        ensureUser(user);
        return facadeDb.findAllocationsByRequester(user).stream()
                .sorted(Comparator.comparing(Allocation::getCreatedAt).reversed())
                .toList();
    }

    public Allocation getAllocation(User user, String id) {
        ensureUser(user);
        Allocation allocation = getAllocationEntity(id);
        if (user.getEntity() != Entity.MANAGER && !allocation.getRequester().getId().equals(user.getId())) {
            throw new SecurityException("Você não tem permissão para ver este pedido de alocação.");
        }
        return allocation;
    }

    public List<Allocation> getAllocationByStatus(User admin, AllocationStatus status) {
        if (status == null) {
            throw new IllegalArgumentException("Informe o status.");
        }
        return facadeDb.findAllocationsByStatus(status).stream()
                .sorted(Comparator.comparing(Allocation::getCreatedAt))
                .toList();
    }

    public synchronized Allocation approveAllocation(User admin, String allocationId) {
        Allocation allocation = getAllocationEntity(allocationId);
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

        eventObserver.updateEventStatus(allocationId);

        return facadeDb.saveAllocation(allocation);
    }

    public synchronized Allocation rejectAllocation(User admin, String id, String reason) {
        if (reason != null && reason.trim().length() > MAX_REJECTION_REASON_LENGTH) {
            throw new IllegalArgumentException("O motivo deve ter no máximo " + MAX_REJECTION_REASON_LENGTH + " caracteres.");
        }
        Allocation allocation = getAllocationEntity(id);
        ensurePending(allocation);

        allocation.setStatus(AllocationStatus.REJECTED);
        allocation.setReviewedBy(admin);
        allocation.setReviewedAt(LocalDateTime.now());
        allocation.setRejectionReason(reason == null || reason.isBlank() ? null : reason.trim());

        eventObserver.updateEventStatus(allocation.getId());

        return facadeDb.saveAllocation(allocation);
    }

    private Allocation getAllocationEntity(String id) {
        return facadeDb.findAllocation(id)
                .orElseThrow(() -> new NoSuchElementException("Pedido de alocação não encontrado."));
    }

    private Venue requireAvailableVenue(User user, String venueId, LocalDateTime start, LocalDateTime end,
                                        String ignoreAllocationId) {
        Venue venue = facadeDb.findAvailableVenues(start, end, ignoreAllocationId).stream()
                .filter(v -> v.getId().equals(venueId))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("O espaço selecionado não está disponível no período informado."));
        if (!venue.allows(user.getEntity())) {
            throw new SecurityException("Seu perfil não pode utilizar este espaço.");
        }
        return venue;
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


    private void ensureUser(User user) {
        if (user == null) {
            throw new SecurityException("Usuário não autenticado.");
        }
    }
}