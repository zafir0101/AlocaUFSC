package alocaufsc.domain.allocationsystem;

import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public class VenueRepository {
    private final Map<String, Venue> venues = new HashMap<>();

    public VenueRepository() {
        venues.put("1", new Venue("1", "Auditório", "INE ", 100, "Auditório do Ine para eventos acadêmios"));
        venues.put("2", new Venue("2", "Sala 1 LIICT", "CTC Bloco B", 40, "Sala com PC"));
    }

    public List<Venue> findAll() {
        return new ArrayList<>(venues.values());
    }

    public Optional<Venue> findById(String id) {
        return Optional.ofNullable(venues.get(id));
    }

    public Venue save(Venue venue) {
        if (venue.getId() == null || venue.getId().isEmpty()) {
            venue.setId(UUID.randomUUID().toString());
        }
        venues.put(venue.getId(), venue);
        return venue;
    }

    public void deleteById(String id) {
        venues.remove(id);
    }
}