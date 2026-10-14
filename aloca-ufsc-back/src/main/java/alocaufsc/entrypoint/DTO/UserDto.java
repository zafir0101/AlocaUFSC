package alocaufsc.entrypoint.DTO;

import alocaufsc.domain.entities.Entity;

public record UserDto(
    String fullName,
    String email,
    String password,
    Entity entity
) {}
