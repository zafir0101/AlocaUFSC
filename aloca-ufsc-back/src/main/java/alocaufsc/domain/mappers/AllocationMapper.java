package alocaufsc.domain.mappers;

import alocaufsc.domain.allocationsystem.Allocation;
import alocaufsc.domain.allocationsystem.AllocationInfo;
import alocaufsc.domain.eventsystem.Event;
import alocaufsc.entrypoint.DTO.AllocationRequest;
import alocaufsc.entrypoint.DTO.AllocationResponse;
import alocaufsc.entrypoint.DTO.EventOptionResponse;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class AllocationMapper {

    public AllocationInfo toInfo(AllocationRequest request) {
        if (request == null) return null;
        return new AllocationInfo(request.eventId(), request.venueId(), request.start(), request.end());
    }

    public AllocationResponse toResponse(Allocation a) {
        return new AllocationResponse(
                a.getId(), a.getStatus(),
                a.getVenue().getId(), a.getVenue().getName(), a.getVenue().getLocation(),
                a.getEvent().getId(), a.getEvent().getTitle(),
                a.getRequester().getId(), a.getRequester().getFullName(),
                a.getStart(), a.getEnd(),
                a.getCreatedAt(), a.getReviewedAt(), a.getRejectionReason());
    }

    public List<AllocationResponse> toResponseList(List<Allocation> allocations) {
        return allocations.stream().map(this::toResponse).toList();
    }

    public EventOptionResponse toEventOption(Event e) {
        return new EventOptionResponse(e.getId(), e.getTitle(), String.valueOf(e.getStatus()));
    }

    public List<EventOptionResponse> toEventOptionList(List<Event> events) {
        return events.stream().map(this::toEventOption).toList();
    }
}
