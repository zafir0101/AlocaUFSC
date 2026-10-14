package alocaufsc.technicalservices.persistence;

import alocaufsc.domain.allocationsystem.Allocation;
import alocaufsc.domain.allocationsystem.AllocationStatus;
import alocaufsc.domain.allocationsystem.Venue;
import alocaufsc.domain.entities.User;
import alocaufsc.domain.eventsystem.Event;
import alocaufsc.domain.notificationsystem.Notification;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
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
        mockData.save(event);
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

    public List<User> findAllUsers() {
        return mockData.findAllUsers();
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

    public Optional<Venue> findVenue(String id) {
        return mockData.findById(id);
    }


    public Notification saveNotification(Notification notification) {
        if (notification.getId() == null) {
            notification.setId(mockData.nextNotificationId());
        }
        mockData.save(notification);
        return notification;
    }

    public Optional<Notification> findNotification(Long id) {
        return mockData.findNotificationById(id);
    }

    public List<Notification> findNotificationsByRecipient(User recipient) {
        return mockData.findNotificationsByRecipientId(recipient.getId());
    }

    public void deleteNotification(Long id) {
        mockData.deleteNotificationById(id);
    }

    public List<Event> findAllEvents() {
        return mockData.findAllEvents();
    }

    public Allocation saveAllocation(Allocation allocation) {
        if (allocation.getId() == null) {
            allocation.setId(mockData.nextAllocationId());
        }
        mockData.save(allocation);
        return allocation;
    }

    public Optional<Allocation> findAllocation(Long id) {
        return mockData.findAllocationById(id);
    }

    public List<Allocation> findAllocationsByStatus(AllocationStatus status) {
        return mockData.findAllocationsByStatus(status);
    }

    public List<Allocation> findAllocationsByRequester(User requester) {
        return mockData.findAllocationsByRequesterId(requester.getId());
    }

    public List<Allocation> findAllocationsByEvent(Long eventId) {
        return mockData.findAllocationsByEventId(eventId);
    }

    public List<Venue> findAvailableVenues(LocalDateTime start, LocalDateTime end, Long ignoreAllocationId) {
        return mockData.findAvailableVenues(start, end, ignoreAllocationId);
    }
}