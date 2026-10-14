package alocaufsc.entrypoint;

import alocaufsc.domain.allocationsystem.AllocationService;
import alocaufsc.domain.allocationsystem.AllocationStatus;
import alocaufsc.domain.allocationsystem.Venue;
import alocaufsc.domain.entities.User;
import alocaufsc.entrypoint.DTO.AllocationRequest;
import alocaufsc.entrypoint.DTO.AllocationResponse;
import alocaufsc.entrypoint.DTO.EventOptionResponse;
import alocaufsc.entrypoint.DTO.RejectAllocationRequest;
import alocaufsc.domain.mappers.AllocationMapper;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/allocations")
public class AllocationController {
    private final AllocationService allocationService;
    private final AllocationMapper mapper;

    public AllocationController(AllocationService allocationService, AllocationMapper mapper) {
        this.allocationService = allocationService;
        this.mapper = mapper;
    }

    @GetMapping("/available-venues")
    public List<Venue> searchAvailableVenues(
            @AuthenticationPrincipal User user,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime start,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime end) {
        return allocationService.searchAvailableVenues(user, start, end);
    }

    @GetMapping("/eligible-events")
    public List<EventOptionResponse> eligibleEvents(@AuthenticationPrincipal User user) {
        return mapper.toEventOptionList(allocationService.getEligibleEvents(user));
    }

    @PostMapping
    public ResponseEntity<AllocationResponse> create(@AuthenticationPrincipal User user,
                                                     @RequestBody AllocationRequest request) {
        var created = allocationService.createAllocation(user, mapper.toInfo(request));
        return ResponseEntity.status(HttpStatus.CREATED).body(mapper.toResponse(created));
    }

    @PutMapping("/{id}")
    public AllocationResponse update(@AuthenticationPrincipal User user, @PathVariable Long id,
                                     @RequestBody AllocationRequest request) {
        return mapper.toResponse(allocationService.updateAllocation(user, id, mapper.toInfo(request)));
    }

    @GetMapping("/mine")
    public List<AllocationResponse> mine(@AuthenticationPrincipal User user) {
        return mapper.toResponseList(allocationService.getMyAllocations(user));
    }

    @GetMapping("/{id}")
    public AllocationResponse get(@AuthenticationPrincipal User user, @PathVariable Long id) {
        return mapper.toResponse(allocationService.getAllocation(user, id));
    }

    @GetMapping
    public List<AllocationResponse> listByStatus(@AuthenticationPrincipal User admin,
                                                 @RequestParam(defaultValue = "PENDING") AllocationStatus status) {
        return mapper.toResponseList(allocationService.getAllocationByStatus(admin, status));
    }

    @PostMapping("/{id}/approve")
    public AllocationResponse approve(@AuthenticationPrincipal User admin, @PathVariable Long id) {
        return mapper.toResponse(allocationService.approveAllocation(admin, id));
    }

    @PostMapping("/{id}/reject")
    public AllocationResponse reject(@AuthenticationPrincipal User admin, @PathVariable Long id,
                                     @RequestBody(required = false) RejectAllocationRequest request) {
        String reason = request == null ? null : request.reason();
        return mapper.toResponse(allocationService.rejectAllocation(admin, id, reason));
    }
}