package alocaufsc.entrypoint.DTO;

import alocaufsc.domain.entities.Entity;

import java.util.Set;

public record VenueRequest(
        String center,
        String building,
        String code,
        String name,
        Integer capacity,
        String description,
        Set<Entity> allowedRoles
) {}
