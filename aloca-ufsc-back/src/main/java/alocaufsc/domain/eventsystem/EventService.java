package alocaufsc.domain.eventsystem;

import alocaufsc.domain.Period;
import alocaufsc.domain.allocationsystem.AllocationInfo;
import alocaufsc.domain.allocationsystem.AllocationService;
import alocaufsc.domain.allocationsystem.AllocationStatus;
import alocaufsc.domain.entities.User;
import alocaufsc.technicalservices.persistence.FacadeDbRest;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.UUID;

@Service
public class EventService {
    public static final int MAX_TITLE_LENGTH = 100;
    public static final int MAX_DESCRIPTION_LENGTH = 1000;

    private final AllocationService allocationService;
    private final FacadeDbRest facadeDbRest;

    public EventService(FacadeDbRest facadeDbRest, AllocationService allocationService) {
        this.facadeDbRest = facadeDbRest;
        this.allocationService = allocationService;
    }

    public Event createEvent(User u, EventInfo ie) {
        validate(ie);
        if (ie.period().start().isBefore(LocalDateTime.now())) {
            throw new IllegalArgumentException("O evento não pode começar no passado.");
        }
        checkDuplicate(u, null, ie);

        Event event = new Event(UUID.randomUUID().toString(), ie.title().trim(), ie.description(), ie.period(),
                EventStatus.SEM_ESPACO, null, u);
        return facadeDbRest.saveEvent(event);
    }

    public List<Event> getEventsByCreator(User u) {
        return facadeDbRest.findEventsByCreator(u).stream()
                .sorted(Comparator.comparing((Event e) -> e.getStatus() == EventStatus.CANCELADO)
                        .thenComparing(e -> e.getPeriod().start()))
                .toList();
    }

    public List<Event> getEventsByStatus(EventStatus status) {
        return facadeDbRest.findAllEvents().stream()
                .filter(e -> e.getStatus() == status)
                .sorted(Comparator.comparing(e -> e.getPeriod().start()))
                .toList();
    }

    public Event getEvent(User u, String eventId) {
        return getOwnedEvent(u, eventId);
    }

    public Event editEvent(User u, String eventId, EventInfo newInfoEvent) {
        Event event = getOwnedEvent(u, eventId);
        if (event.getStatus() == EventStatus.CANCELADO) {
            throw new IllegalArgumentException("Não é possível editar um evento cancelado.");
        }
        if (event.getStatus() == EventStatus.ATIVO) {
            ensureNotEnded(event, "Não é possível editar um evento que já passou.");
        }
        validate(newInfoEvent);

        LocalDateTime now = LocalDateTime.now();
        boolean startChanged = !newInfoEvent.period().start().equals(event.getPeriod().start());
        boolean endChanged = !newInfoEvent.period().end().equals(event.getPeriod().end());
        if (startChanged && newInfoEvent.period().start().isBefore(now)) {
            throw new IllegalArgumentException("O evento não pode ser remarcado para uma data que já passou.");
        }
        if (endChanged && !newInfoEvent.period().end().isAfter(now)) {
            throw new IllegalArgumentException("O fim do evento não pode estar no passado.");
        }
        checkDuplicate(u, eventId, newInfoEvent);

        event.setTitle(newInfoEvent.title().trim());
        event.setDescription(newInfoEvent.description());
        event.setPeriod(newInfoEvent.period());

        if (!startChanged && !endChanged) return facadeDbRest.saveEvent(event);

        AllocationInfo newAllocationInfo = new AllocationInfo(event.getId(), event.getAllocation().getVenue().getName(),
                event.getPeriod().start(), event.getPeriod().end());
        allocationService.updateAllocation(u, event.getAllocation(), newAllocationInfo);

        return facadeDbRest.saveEvent(event);
    }

    public Event suspendEvent(User u, String eventId) {
        Event event = getOwnedEvent(u, eventId);
        if (event.getStatus() != EventStatus.ATIVO) {
            throw new IllegalArgumentException("Apenas eventos ativos podem ser suspensos.");
        }
        ensureNotEnded(event, "Não é possível suspender um evento que já passou.");

        event.setStatus(EventStatus.SUSPENSO);
        event.getAllocation().setStatus(AllocationStatus.CANCELED);

        facadeDbRest.saveAllocation(event.getAllocation());

        event.setAllocation(null);

        return facadeDbRest.saveEvent(event);
    }

    public Event reactivateEvent(User u, String eventId) {
        Event event = getOwnedEvent(u, eventId);
        if (event.getStatus() != EventStatus.SUSPENSO) {
            throw new IllegalArgumentException("Apenas eventos suspensos podem ser reativados.");
        }
        ensureNotEnded(event, "A data deste evento já passou. Altere para uma data futura antes de reativar.");

        event.setStatus(EventStatus.SEM_ESPACO);
        return facadeDbRest.saveEvent(event);
    }

    public Event cancelEvent(User u, String eventId) {
        Event event = getOwnedEvent(u, eventId);
        if (event.getStatus() == EventStatus.CANCELADO) {
            throw new IllegalArgumentException("O evento já está cancelado.");
        }
        if (event.getStatus() == EventStatus.ATIVO) {
            ensureNotEnded(event, "Não é possível cancelar um evento que já passou.");
        }

        event.setStatus(EventStatus.CANCELADO);
        event.getAllocation().setStatus(AllocationStatus.CANCELED);

        facadeDbRest.saveAllocation(event.getAllocation());

        return facadeDbRest.saveEvent(event);
    }

    public List<Event> getEligibleEvents(User user) {
        ensureUser(user);
        return facadeDbRest.findEventsByCreator(user).stream()
                .filter(Event::isAllocatable)
                .toList();
    }

    private Event getOwnedEvent(User u, String eventId) {
        Event event = facadeDbRest.findEvent(eventId)
                .orElseThrow(() -> new NoSuchElementException("Evento não encontrado."));
        if (!event.isCreatedBy(u)) {
            throw new SecurityException("Apenas o organizador pode acessar este evento.");
        }
        return event;
    }

    private void ensureNotEnded(Event event, String message) {
        if (!event.getPeriod().end().isAfter(LocalDateTime.now())) {
            throw new IllegalArgumentException(message);
        }
    }

    private void validate(EventInfo ie) {
        if (ie == null) {
            throw new IllegalArgumentException("Os dados do evento não podem ser nulos.");
        }
        if (ie.title() == null || ie.title().isBlank()) {
            throw new IllegalArgumentException("O título do evento é obrigatório.");
        }
        if (ie.title().trim().length() > MAX_TITLE_LENGTH) {
            throw new IllegalArgumentException("O título deve ter no máximo " + MAX_TITLE_LENGTH + " caracteres.");
        }
        if (ie.description() != null && ie.description().length() > MAX_DESCRIPTION_LENGTH) {
            throw new IllegalArgumentException("A descrição deve ter no máximo " + MAX_DESCRIPTION_LENGTH + " caracteres.");
        }
        if (ie.period() == null) {
            throw new IllegalArgumentException("O período do evento é obrigatório.");
        }
    }

    private void checkDuplicate(User u, String ignoredEventId, EventInfo ie) {
        String title = ie.title().trim();
        facadeDbRest.findEventsByCreator(u).stream()
                .filter(e -> !e.getId().equals(ignoredEventId))
                .filter(e -> e.getStatus() != EventStatus.CANCELADO)
                .filter(e -> e.getTitle().equalsIgnoreCase(title))
                .filter(e -> overlaps(e.getPeriod(), ie.period()))
                .findFirst()
                .ifPresent(e -> {
                    throw new DuplicateEventException(e);
                });
    }

    private boolean overlaps(Period a, Period b) {
        return a.start().isBefore(b.end()) && b.start().isBefore(a.end());
    }


    private void ensureUser(User user) {
        if (user == null) {
            throw new SecurityException("Usuário não autenticado.");
        }
    }
}
