package alocaufsc.Controllers.DTO;

public record LoginRequest(
        String email,
        String senha
) {}