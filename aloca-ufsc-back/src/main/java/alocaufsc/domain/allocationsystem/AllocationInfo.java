package alocaufsc.domain.allocationsystem;

import java.time.LocalDateTime;

public record AllocationInfo(Long eventId, String venueId, LocalDateTime start, LocalDateTime end) {}