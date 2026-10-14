package alocaufsc.entrypoint.DTO;

import alocaufsc.domain.allocationsystem.Venue;
import alocaufsc.domain.entities.Entity;

import java.util.List;

public record VenueResponse(
        String id,
        String code,
        String name,
        String center,
        String building,
        String location,
        int capacity,
        String description,
        List<Entity> allowedRoles
) {
    public static VenueResponse from(Venue venue) {
        return new VenueResponse(
                venue.getId(),
                venue.getCode(),
                venue.getName(),
                venue.getCenter(),
                venue.getBuilding(),
                venue.getLocation(),
                venue.getCapacity(),
                venue.getDescription(),
                venue.getAllowedRoles().stream().sorted().toList()
        );
    }
}
