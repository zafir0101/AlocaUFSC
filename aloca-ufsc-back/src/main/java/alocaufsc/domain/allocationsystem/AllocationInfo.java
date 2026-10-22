package alocaufsc.domain.allocationsystem;

import java.time.LocalDateTime;

public record AllocationInfo(String eventId, String venueId, LocalDateTime start, LocalDateTime end) {}