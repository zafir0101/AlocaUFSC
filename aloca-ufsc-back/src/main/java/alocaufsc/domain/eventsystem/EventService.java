package alocaufsc.domain.eventsystem;

import alocaufsc.domain.entities.Period;
import alocaufsc.domain.entities.User;
import alocaufsc.technicalservices.persistence.FacadeDbRest;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.NoSuchElementException;

@Service
public class EventService {
    public static final int MAX_TITLE_LENGTH = 100;
    public static final int MAX_DESCRIPTION_LENGTH = 1000;

    private final FacadeDbRest facadeDbRest;

    public EventService(FacadeDbRest facadeDbRest) {
        this.facadeDbRest = facadeDbRest;
    }

    public Event createEvent(User u, InfoEvent ie) {
        validate(ie);
        if (ie.period().start().isBefore(LocalDateTime.now())) {
            throw new IllegalArgumentException("O evento não pode começar no passado.");
        }
        checkDuplicate(u, null, ie);

        Event event = new Event(null, ie.title().trim(), ie.description(), ie.period(), EventStatus.ATIVO, ie.venue(), u);
        return facadeDbRest.saveEvent(event);
    }

    public List<Event> getEventsByCreator(User u) {
        return facadeDbRest.findEventsByCreator(u).stream()
                .sorted(Comparator.comparing((Event e) -> e.getStatus() == EventStatus.CANCELADO)
                        .thenComparing(e -> e.getPeriod().start()))
                .toList();
    }

    public Event getEvent(User u, Long eventId) {
        return getOwnedEvent(u, eventId);
    }

    public Event editEvent(User u, Long eventId, InfoEvent newData) {
        Event event = getOwnedEvent(u, eventId);
        if (event.getStatus() == EventStatus.CANCELADO) {
            throw new IllegalArgumentException("Não é possível editar um evento cancelado.");
        }
        if (event.getStatus() == EventStatus.ATIVO) {
            ensureNotEnded(event, "Não é possível editar um evento que já passou.");
        }
        validate(newData);

        LocalDateTime now = LocalDateTime.now();
        boolean startChanged = !newData.period().start().equals(event.getPeriod().start());
        boolean endChanged = !newData.period().end().equals(event.getPeriod().end());
        if (startChanged && newData.period().start().isBefore(now)) {
            throw new IllegalArgumentException("O evento não pode ser remarcado para uma data que já passou.");
        }
        if (endChanged && !newData.period().end().isAfter(now)) {
            throw new IllegalArgumentException("O fim do evento não pode estar no passado.");
        }
        checkDuplicate(u, eventId, newData);

        event.setTitle(newData.title().trim());
        event.setDescription(newData.description());
        event.setPeriod(newData.period());
        if (newData.venue() != null) {
            event.setVenue(newData.venue());
        }
        return facadeDbRest.saveEvent(event);
    }

    public Event suspendEvent(User u, Long eventId) {
        Event event = getOwnedEvent(u, eventId);
        if (event.getStatus() != EventStatus.ATIVO) {
            throw new IllegalArgumentException("Apenas eventos ativos podem ser suspensos.");
        }
        ensureNotEnded(event, "Não é possível suspender um evento que já passou.");

        event.setStatus(EventStatus.SUSPENSO);
        return facadeDbRest.saveEvent(event);
    }

    public Event reactivateEvent(User u, Long eventId) {
        Event event = getOwnedEvent(u, eventId);
        if (event.getStatus() != EventStatus.SUSPENSO) {
            throw new IllegalArgumentException("Apenas eventos suspensos podem ser reativados.");
        }
        ensureNotEnded(event, "A data deste evento já passou. Altere para uma data futura antes de reativar.");

        event.setStatus(EventStatus.ATIVO);
        return facadeDbRest.saveEvent(event);
    }

    public Event cancelEvent(User u, Long eventId) {
        Event event = getOwnedEvent(u, eventId);
        if (event.getStatus() == EventStatus.CANCELADO) {
            throw new IllegalArgumentException("O evento já está cancelado.");
        }
        if (event.getStatus() == EventStatus.ATIVO) {
            ensureNotEnded(event, "Não é possível cancelar um evento que já passou.");
        }

        event.setStatus(EventStatus.CANCELADO);
        return facadeDbRest.saveEvent(event);
    }

    private Event getOwnedEvent(User u, Long eventId) {
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

    private void validate(InfoEvent ie) {
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

    private void checkDuplicate(User u, Long ignoredEventId, InfoEvent ie) {
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
}