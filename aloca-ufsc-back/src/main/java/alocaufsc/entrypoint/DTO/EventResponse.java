package alocaufsc.entrypoint.DTO;

import alocaufsc.domain.eventsystem.Event;

import java.time.LocalDateTime;

// Não expõe o User criador inteiro (evita vazar a senha no JSON).
public record EventResponse(
        Long id,
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
                event.getCreator().getNomeCompleto()
        );
    }
}