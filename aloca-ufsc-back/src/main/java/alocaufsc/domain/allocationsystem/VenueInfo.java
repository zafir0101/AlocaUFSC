package alocaufsc.domain.allocationsystem;

import alocaufsc.domain.entities.Entity;

import java.util.Set;

public record VenueInfo(String center, String building, String code, String name, Integer capacity, String description,
                        Set<Entity> allowedRoles) {}
