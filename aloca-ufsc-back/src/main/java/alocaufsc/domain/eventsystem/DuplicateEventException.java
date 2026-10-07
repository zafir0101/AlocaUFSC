package alocaufsc.domain.eventsystem;

import java.time.format.DateTimeFormatter;

public class DuplicateEventException extends RuntimeException {
    private static final DateTimeFormatter FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final Event existingEvent;

    public DuplicateEventException(Event existingEvent) {
        super("O evento \"" + existingEvent.getTitle() + "\" já existe em "
                + existingEvent.getPeriod().start().format(FORMAT)
                + (existingEvent.getStatus() == EventStatus.SUSPENSO ? " (suspenso)." : "."));
        this.existingEvent = existingEvent;
    }

    public Event getExistingEvent() {
        return existingEvent;
    }
}