package alocaufsc.entrypoint.DTO;

import java.time.LocalDateTime;

public record AllocationRequest(String eventId, String venueId, LocalDateTime start, LocalDateTime end) {}