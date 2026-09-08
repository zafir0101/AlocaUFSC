package alocaufsc.technicalservices.persistence;

import alocaufsc.domain.allocationsystem.Venue;
import alocaufsc.domain.entities.User;
import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public class FacadeDbRest {
    private final MockData mockData;

    public FacadeDbRest(MockData mockData) {
        this.mockData = mockData;
    }

    public User save(User user) {
        mockData.save(user);
        return user;
    }

    public Venue save(Venue venue) {
        if (venue.getId() == null || venue.getId().isEmpty()) {
            venue.setId(UUID.randomUUID().toString());
        }
        mockData.save(venue);
        return venue;
    }

    public List<Venue> findAllVenues() {
        return mockData.findAllVenues();
    }

    public Optional<User> findByEmail(String email) {
        return mockData.findByEmail(email);
    }

    public boolean existsByEmail(String email) {
        return mockData.existsByEmail(email);
    }

    public void saveRefreshToken(String refreshToken, String email) {
        mockData.saveRefreshToken(refreshToken, email);
    }

    public Optional<String> findEmailByRefreshToken(String refreshToken) {
        return mockData.getEmailByRefreshToken(refreshToken);
    }

    public void deleteRefreshToken(String refreshToken) {
        mockData.removeRefreshToken(refreshToken);
    }

    public void deleteVenueById(String id) {
        mockData.deleteVenueById(id);
    }
}