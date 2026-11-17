package alocaufsc.domain.mappers;

import alocaufsc.domain.allocationsystem.Allocation;
import alocaufsc.domain.allocationsystem.AllocationInfo;
import alocaufsc.entrypoint.DTO.AllocationRequest;
import alocaufsc.entrypoint.DTO.AllocationResponse;
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
                a.getRequester().getId(), a.getRequester().getFullName(),
                a.getStart(), a.getEnd(),
                a.getCreatedAt(), a.getReviewedAt(), a.getRejectionReason());
    }

    public List<AllocationResponse> toResponseList(List<Allocation> allocations) {
        return allocations.stream().map(this::toResponse).toList();
    }
}
