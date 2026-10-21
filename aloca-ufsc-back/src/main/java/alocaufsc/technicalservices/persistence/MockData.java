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

    public List<Allocation> findAllocationsByEventId(String eventId) {
        return allocations.values().stream()
                .filter(a -> a.getEvent().getId().equals(eventId))
                .toList();
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
                "Auditorium with projector, sound system, and stage.", Entity.PROFESSOR, Entity.ORGANIZATION);

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

        LocalDate today = LocalDate.now();
        LocalDateTime currentHour = LocalDateTime.now().truncatedTo(ChronoUnit.HOURS);

        seedEvent(maria, "Oficina de Design de Interfaces",
                "Oficina prática de prototipação de telas.",
                new Period(currentHour.minusHours(1), currentHour.plusHours(2)), EventStatus.ATIVO);
        Event flutterTalk = seedEvent(maria, "Palestra: Introdução ao Flutter",
                "Palestra introdutória sobre desenvolvimento mobile com Flutter.",
                new Period(today.plusDays(2).atTime(19, 0), today.plusDays(2).atTime(21, 0)), EventStatus.ATIVO);
        // Começa em ~20 horas: gera o lembrete de 24 horas sem espaço.
        seedEvent(maria, "Reunião de Planejamento da Semana Acadêmica",
                "Reunião com a comissão organizadora.",
                new Period(currentHour.plusHours(20), currentHour.plusHours(22)), EventStatus.ATIVO);
        Event academicWeek = seedEvent(maria, "Semana Acadêmica de Computação",
                "Uma semana de palestras, minicursos e competições.",
                new Period(today.plusDays(10).atTime(9, 0), today.plusDays(14).atTime(18, 0)), EventStatus.ATIVO);
        seedEvent(maria, "Workshop de Spring Boot",
                "Workshop prático de APIs REST com Spring Boot.",
                new Period(today.minusDays(7).atTime(14, 0), today.minusDays(7).atTime(17, 0)), EventStatus.ATIVO);
        seedEvent(maria, "Palestra: Carreira em Tecnologia",
                "Bate-papo com profissionais da área sobre mercado de trabalho.",
                new Period(today.minusDays(30).atTime(19, 0), today.minusDays(30).atTime(21, 0)), EventStatus.ATIVO);
        seedEvent(maria, "Minicurso de Git e GitHub",
                "Minicurso prático de versionamento de código.",
                new Period(today.minusDays(15).atTime(9, 0), today.minusDays(15).atTime(12, 0)), EventStatus.ATIVO);
        seedEvent(maria, "Feira de Projetos",
                "Exposição dos projetos finais das disciplinas.",
                new Period(today.minusDays(45).atTime(13, 0), today.minusDays(45).atTime(18, 0)), EventStatus.CANCELADO);
        seedEvent(maria, "Hackathon UFSC",
                "Maratona de programação de 24 horas.",
                new Period(today.plusDays(20).atTime(8, 0), today.plusDays(21).atTime(8, 0)), EventStatus.SUSPENSO);
        seedEvent(maria, "Semana de Recepção dos Calouros",
                "Atividades de boas-vindas para os ingressantes.",
                new Period(today.minusDays(10).atTime(9, 0), today.minusDays(8).atTime(17, 0)), EventStatus.SUSPENSO);
        seedEvent(maria, "Visita Técnica ao Sapiens Parque",
                "Visita guiada às empresas do parque tecnológico.",
                new Period(today.plusDays(25).atTime(8, 0), today.plusDays(25).atTime(12, 0)), EventStatus.CANCELADO);

        seedAllocation(auditorium, flutterTalk, maria,
                today.plusDays(2).atTime(19, 0), today.plusDays(2).atTime(21, 0), AllocationStatus.PENDING);
        seedAllocation(gym, academicWeek, maria,
                today.plusDays(10).atTime(9, 0), today.plusDays(14).atTime(18, 0), AllocationStatus.APPROVED);
        academicWeek.setStatus(EventStatus.ATIVO);

        seedNotification(maria, NotificationType.NOVO_ESPACO, "Novo espaço disponível: Auditório do CTC (CTC - Bloco A - Direção do CTC).",
                null, LocalDateTime.now().minusDays(1), true);
    }

    private Venue seedVenue(String center, String building, String code, String name, int capacity, String description,
                            Entity... allowedRoles) {
        Venue venue = new Venue(UUID.randomUUID().toString(), code, name, center, building, capacity, description, Set.of(allowedRoles));
        save(venue);
        return venue;
    }

    private Allocation seedAllocation(Venue venue, Event event, User requester, LocalDateTime start, LocalDateTime end,
                                      AllocationStatus status) {
        Allocation allocation = new Allocation(UUID.randomUUID().toString(), venue, event,
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