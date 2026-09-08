package alocaufsc.Controllers.DTO;

public record AuthResponse(
        String token,
        String refreshToken,
        String tipoPerfil,
        String nomeCompleto
) {}