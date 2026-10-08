package alocaufsc.technicalservices.persistence;

import alocaufsc.domain.allocationsystem.Venue;
import alocaufsc.domain.entities.User;
import alocaufsc.domain.eventsystem.Event;
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

    public Event saveEvent(Event event) {
        if (event.getId() == null) {
            event.setId(mockData.nextEventId());
        }
        mockData.saveEvent(event);
        return event;
    }

    public void saveRefreshToken(String refreshToken, String email) {
        mockData.saveRefreshToken(refreshToken, email);
    }

    public void saveAccessToken(String accessToken, String email) {
        mockData.saveAccessToken(accessToken, email);
    }

    public List<Venue> findAllVenues() {
        return mockData.findAllVenues();
    }

    public Optional<User> findUserByEmail(String email) {
        return mockData.findByEmail(email);
    }

    public boolean existsByEmail(String email) {
        return mockData.existsByEmail(email);
    }

    public Optional<User> findUserbyAccessToken(String token) {
        Optional<String> email = mockData.getEmailByAccessToken(token);
        return email.map(this::findUserByEmail).orElse(null);
    }

    public Optional<User> findUserbyRefreshToken(String token) {
        Optional<String> email = mockData.getEmailByRefreshToken(token);
        return email.map(this::findUserByEmail).orElse(null);
    }

    public void deleteVenueById(String id) {
        mockData.deleteVenueById(id);
    }

    public Optional<Event> findEvent(Long eventId) {
        return mockData.findEventById(eventId);
    }

    public List<Event> findEventsByCreator(User creator) {
        return mockData.findEventsByCreatorId(creator.getId());
    }
}
