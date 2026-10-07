package alocaufsc.entrypoint.DTO;

import java.time.LocalDateTime;

public record EventRequest(
        String title,
        String description,
        LocalDateTime start,
        LocalDateTime end
) {}