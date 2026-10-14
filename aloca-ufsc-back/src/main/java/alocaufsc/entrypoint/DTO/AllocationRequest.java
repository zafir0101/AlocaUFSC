package alocaufsc.entrypoint.DTO;

import java.time.LocalDateTime;

public record AllocationRequest(Long eventId, String venueId, LocalDateTime start, LocalDateTime end) {}