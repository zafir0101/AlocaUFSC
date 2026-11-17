package alocaufsc.technicalservices.persistence;

import alocaufsc.domain.allocationsystem.Allocation;
import alocaufsc.domain.allocationsystem.AllocationStatus;
import alocaufsc.domain.allocationsystem.Venue;
import alocaufsc.domain.entities.Entity;
import alocaufsc.domain.Period;
import alocaufsc.domain.entities.User;
import alocaufsc.domain.eventsystem.Event;
import alocaufsc.domain.eventsystem.EventStatus;
import alocaufsc.domain.notificationsystem.Notification;
import alocaufsc.domain.notificationsystem.NotificationType;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@Component
public class MockData {
    private final Map<String, User> usersByEmail = new ConcurrentHashMap<>();
    private final Map<String, String> refreshTokens = new ConcurrentHashMap<>();
    private final Map<String, String> accessTokens = new ConcurrentHashMap<>();
    private final Map<String, Venue> venues = new ConcurrentHashMap<>();
    private final Map<String, Event> events = new ConcurrentHashMap<>();
    private final Map<String, Notification> notifications = new ConcurrentHashMap<>();
    private final Map<String, Allocation> allocations = new ConcurrentHashMap<>();

    public MockData() {
        seed(); // Popula o banco falso ao iniciar a aplicação
    }

    public void save(User user) {
        usersByEmail.put(user.getEmail().toLowerCase(), user);
    }

    public void save(Venue venue) {
        venues.put(venue.getId(), venue);
    }

    public void save(Event event) {
        events.put(event.getId(), event);
    }

    public void save(Notification notification) {
        notifications.put(notification.getId(), notification);
    }

    public void save(Allocation allocation) {
        allocations.put(allocation.getId(), allocation);
    }

    public Optional<User> findByEmail(String email) {
        return Optional.ofNullable(usersByEmail.get(email.toLowerCase()));
    }

    public List<User> findAllUsers() {
        return new ArrayList<>(usersByEmail.values());
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

    public void saveAccessToken(String token, String email) {
        accessTokens.put(token, email);
    }

    public Optional<String> getEmailByAccessToken(String token) {
        return Optional.ofNullable(accessTokens.get(token));
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

    public Optional<Event> findEventById(String id) {
        return Optional.ofNullable(events.get(id));
    }

    public List<Event> findEventsByCreatorId(String creatorId) {
        return events.values().stream()
                .filter(e -> e.getCreator().getId().equals(creatorId))
                .toList();
    }

    public void deleteNotificationById(String id) {
        notifications.remove(id);
    }

    public List<Event> findAllEvents() {
        return new ArrayList<>(events.values());
    }

    public Optional<Notification> findNotificationById(String id) {
        return Optional.ofNullable(notifications.get(id));
    }

    public List<Notification> findNotificationsByRecipientId(String recipientId) {
        return notifications.values().stream()
                .filter(n -> n.getRecipient().getId().equals(recipientId))
                .toList();
    }

    public Optional<Allocation> findAllocationById(String id) {
        return Optional.ofNullable(allocations.get(id));
    }

    public List<Allocation> findAllocationsByStatus(AllocationStatus status) {
        return allocations.values().stream().filter(a -> a.getStatus() == status).toList();
    }

    public List<Allocation> findAllocationsByRequesterId(String requesterId) {
        return allocations.values().stream()
                .filter(a -> a.getRequester().getId().equals(requesterId))
                .toList();
    }

    public Allocation findAllocationByEventId(String eventId) {
        return events.get(eventId).getAllocation();
    }

    public List<Venue> findAvailableVenues(LocalDateTime start, LocalDateTime end, String ignoreAllocationId) {
        return venues.values().stream()
                .filter(v -> allocations.values().stream().noneMatch(a ->
                        a.getStatus() == AllocationStatus.APPROVED
                                && a.getVenue().getId().equals(v.getId())
                                && !a.getId().equals(ignoreAllocationId)
                                && a.overlaps(start, end)))
                .toList();
    }

    // maria@ufsc.br -> professor with events | joao@ufsc.br -> student without events | admin@ufsc.br -> manager
    private void seed() {
        String password = new BCryptPasswordEncoder().encode("123456");
        User maria = new User(UUID.randomUUID().toString(), "Maria Silva", "maria@ufsc.br", password, Entity.PROFESSOR, "USER");
        User joao = new User(UUID.randomUUID().toString(), "João Souza", "joao@ufsc.br", password, Entity.STUDENT, "USER");
        User admin = new User(UUID.randomUUID().toString(), "Admin", "admin@ufsc.br", password, Entity.MANAGER, "ADMIN");        save(maria);
        save(joao);
        save(admin);

        Venue auditorium = seedVenue("CTC", "Block A - CTC Management", "AUD-01", "CTC Auditorium", 250,
                "Auditorium with projector, sound system, and stage.", Entity.PROFESSOR, Entity.ORGANIZATION, Entity.MANAGER);

        seedVenue("CTC", "INE - Informatics and Statistics", "LAB-01", "Computer Lab 1", 40,
                "40 computers with Linux and a projector.", Entity.PROFESSOR);

        seedVenue("CTC", "INE - Informatics and Statistics", "LAB-02", "Computer Lab 2", 30,
                "30 computers with Windows.", Entity.PROFESSOR);

        seedVenue("CTC", "INE - Informatics and Statistics", "ROOM-205", "INE Meeting Room", 12,
                "Meeting table and TV for presentations.", Entity.STUDENT, Entity.PROFESSOR, Entity.ORGANIZATION);

        seedVenue("CTC", "EFI - Integrated Physical Space", "ROOM-101", "Room 101", 50,
                "Classroom with whiteboard and projector.", Entity.STUDENT, Entity.PROFESSOR, Entity.ORGANIZATION);

        Venue gym = seedVenue("CDS", "Gymnasium 1", "GYM-01", "Sports Gymnasium", 300,
                "Multi-sport court with bleachers.", Entity.PROFESSOR, Entity.ORGANIZATION);

        seedVenue("OTHER", "University Library (BU)", "ESP-01", "BU Lounge Area", 80,
                "Open space for exhibitions and fairs.", Entity.STUDENT, Entity.PROFESSOR, Entity.ORGANIZATION);
    }

    private Venue seedVenue(String center, String building, String code, String name, int capacity, String description,
                            Entity... allowedRoles) {
        Venue venue = new Venue(UUID.randomUUID().toString(), code, name, center, building, capacity, description, Set.of(allowedRoles));
        save(venue);
        return venue;
    }

    private Allocation seedAllocation(Venue venue, Event event, User requester, LocalDateTime start, LocalDateTime end,
                                      AllocationStatus status) {
        Allocation allocation = new Allocation(UUID.randomUUID().toString(), venue,
                requester, start, end, status, LocalDateTime.now().minusHours(3));
        save(allocation);
        return allocation;
    }

    private void seedNotification(User recipient, NotificationType type, String message, String eventId,
                                  LocalDateTime createdAt, boolean read) {
        save(new Notification(UUID.randomUUID().toString(), recipient, type, message, eventId, createdAt, read));
    }

    private Event seedEvent(User creator, String title, String description, Period period, EventStatus status) {
        Event event = new Event(UUID.randomUUID().toString(), title, description, period, status, null, creator);
        save(event);
        return event;
    }
}