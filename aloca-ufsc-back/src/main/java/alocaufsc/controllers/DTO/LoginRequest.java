package alocaufsc.controllers.DTO;

public record LoginRequest(
        String email,
        String senha
) {}