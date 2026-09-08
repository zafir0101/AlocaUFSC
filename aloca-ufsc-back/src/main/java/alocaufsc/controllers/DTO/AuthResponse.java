package alocaufsc.controllers.DTO;

public record AuthResponse(
        String token,
        String refreshToken,
        String tipoPerfil,
        String nomeCompleto
) {}