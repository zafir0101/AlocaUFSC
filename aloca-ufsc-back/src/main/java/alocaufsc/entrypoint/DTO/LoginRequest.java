package alocaufsc.entrypoint.DTO;

public record LoginRequest(
        String email,
        String senha
) {}