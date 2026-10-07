package alocaufsc.domain.entities;

import java.time.LocalDateTime;

public record Period(LocalDateTime start, LocalDateTime end) {
    public Period {
        if (start == null || end == null) {
            throw new IllegalArgumentException("Informe o início e o fim do período.");
        }
        if (!end.isAfter(start)) {
            throw new IllegalArgumentException("O fim do período deve ser depois do início.");
        }
    }
}