package alocaufsc.entrypoint.DTO;

import alocaufsc.domain.allocationsystem.AllocationStatus;
import alocaufsc.domain.eventsystem.Event;
import alocaufsc.domain.eventsystem.EventStatus;

import java.time.LocalDateTime;

public record EventResponse(
        // Event Information
        String id,
        String title,
        String description,
        LocalDateTime start,
        LocalDateTime end,
        String creatorName,
        String status,
        // Allocation Information
        String allocationId,
        String venueName,
        String requesterName
) {
    public static EventResponse from(Event event) {
        return new EventResponse(
                event.getId(),
                event.getTitle(),
                event.getDescription(),
                event.getPeriod().start(),
                event.getPeriod().end(),
                event.getCreator().getFullName(),
                event.getStatus().name(),
                event.getAllocation() != null ? event.getAllocation().getId() : null,
                event.getAllocation() != null && event.getAllocation().getStatus() != AllocationStatus.REJECTED
                        ? event.getAllocation().getVenue().getName()
                        : null,
                event.getAllocation() != null ? event.getAllocation().getRequester().getFullName() : null
        );
    }
}