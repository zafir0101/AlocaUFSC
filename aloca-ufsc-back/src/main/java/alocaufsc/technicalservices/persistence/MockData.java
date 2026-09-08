package alocaufsc.technicalservices.persistence;

import alocaufsc.domain.allocationsystem.Venue;
import alocaufsc.domain.entities.User;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class MockData {
    private final Map<String, User> usersByEmail = new ConcurrentHashMap<>();
    private final Map<String, String> refreshTokens = new ConcurrentHashMap<>();
    private final Map<String, Venue> venues = new HashMap<>();

    public void save(User user) {
        usersByEmail.put(user.getEmail().toLowerCase(), user);
    }

    public void save(Venue venue) {
        venues.put(venue.getId(), venue);
    }

    public Optional<User> findByEmail(String email) {
        return Optional.ofNullable(usersByEmail.get(email.toLowerCase()));
    }

    public boolean existsByEmail(String email) {
        return usersByEmail.containsKey(email.toLowerCase());
    }

    public void saveRefreshToken(String token, String email) {
        refreshTokens.put(token, email);
    }

    public Optional<String> getEmailByRefreshToken(String token) {
        return Optional.ofNullable(refreshTokens.get(token));
    }

    public void removeRefreshToken(String token) {
        refreshTokens.remove(token);
    }

    public List<Venue> findAllVenues() {
        return new ArrayList<>(venues.values());
    }

    public Optional<Venue> findById(String id) {
        return Optional.ofNullable(venues.get(id));
    }

    public void deleteVenueById(String id) {
        venues.remove(id);
    }
}