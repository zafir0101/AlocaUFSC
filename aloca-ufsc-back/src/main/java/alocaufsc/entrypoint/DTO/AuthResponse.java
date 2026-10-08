package alocaufsc.entrypoint.DTO;

public record AuthResponse(
    String accessToken,
    String refreshToken,
    String entity,
    String fullName
) {}
