package alocaufsc.entrypoint.DTO;

import alocaufsc.domain.allocationsystem.AllocationStatus;

import java.time.LocalDateTime;

public record AllocationResponse(String id, AllocationStatus status,
                                 String venueId, String venueName, String venueLocation,
                                 String requesterId, String requesterName,
                                 LocalDateTime start, LocalDateTime end,
                                 LocalDateTime createdAt, LocalDateTime reviewedAt, String rejectionReason) {}