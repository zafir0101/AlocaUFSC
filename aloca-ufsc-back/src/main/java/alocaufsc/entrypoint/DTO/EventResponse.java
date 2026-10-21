package alocaufsc.entrypoint.DTO;

import alocaufsc.domain.eventsystem.Event;
import alocaufsc.domain.eventsystem.EventStatus;

import java.time.LocalDateTime;

public record EventResponse(
        String id,
        String title,
        String description,
        LocalDateTime start,
        LocalDateTime end,
        String status,
        String venueName,
        String creatorName
) {
    public static EventResponse from(Event event) {
        return new EventResponse(
                event.getId(),
                event.getTitle(),
                event.getDescription(),
                event.getPeriod().start(),
                event.getPeriod().end(),
                event.getStatus().name(),
                event.getVenue() != null ? event.getVenue().getName() : null,
                event.getCreator().getFullName()
        );
    }
}