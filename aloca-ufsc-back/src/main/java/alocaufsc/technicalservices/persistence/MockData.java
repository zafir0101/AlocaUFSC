package alocaufsc.technicalservices.persistence;

import alocaufsc.domain.allocationsystem.Venue;
import alocaufsc.domain.entities.Entity;
import alocaufsc.domain.entities.Period;
import alocaufsc.domain.entities.User;
import alocaufsc.domain.eventsystem.Event;
import alocaufsc.domain.eventsystem.EventStatus;
import alocaufsc.domain.notificationsystem.Notification;
import alocaufsc.domain.notificationsystem.NotificationType;
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
    private final Map<Long, Event> events = new ConcurrentHashMap<>();
    private final AtomicLong eventIdSequence = new AtomicLong();
    private final Map<Long, Notification> notifications = new ConcurrentHashMap<>();
    private final AtomicLong notificationIdSequence = new AtomicLong();

    public MockData() {
        seed();
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

    public void removeRefreshToken(String token) {
        refreshTokens.remove(token);
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

    public Long nextEventId() {
        return eventIdSequence.incrementAndGet();
    }

    public Optional<Event> findEventById(Long id) {
        return Optional.ofNullable(events.get(id));
    }

    public List<Event> findEventsByCreatorId(String creatorId) {
        return events.values().stream()
                .filter(e -> e.getCreator().getId().equals(creatorId))
                .toList();
    }

    public Long nextNotificationId() {
        return notificationIdSequence.incrementAndGet();
    }

    public void deleteNotificationById(Long id) {
        notifications.remove(id);
    }

    public List<Event> findAllEvents() {
        return new ArrayList<>(events.values());
    }

    public Optional<Notification> findNotificationById(Long id) {
        return Optional.ofNullable(notifications.get(id));
    }

    public List<Notification> findNotificationsByRecipientId(String recipientId) {
        return notifications.values().stream()
                .filter(n -> n.getRecipient().getId().equals(recipientId))
                .toList();
    }

    // maria@ufsc.br -> docente com eventos | joao@ufsc.br -> discente sem eventos | admin@ufsc.br -> administrador
    private void seed() {
        User maria = new User(UUID.randomUUID().toString(), "Maria Silva", "maria@ufsc.br", "123456", Entity.DOCENTE);
        User joao = new User(UUID.randomUUID().toString(), "João Souza", "joao@ufsc.br", "123456", Entity.DISCENTE);
        User admin = new User(UUID.randomUUID().toString(), "Administrador", "admin@ufsc.br", "123456", Entity.ADMINISTRADOR);
        save(maria);
        save(joao);
        save(admin);

        seedVenue("CTC", "Bloco A - Direção do CTC", "AUD-01", "Auditório do CTC", 250,
                "Auditório com projetor, sistema de som e palco.", Entity.DOCENTE, Entity.ORGANIZACAO);
        seedVenue("CTC", "INE - Informática e Estatística", "LAB-01", "Laboratório de Informática 1", 40,
                "40 computadores com Linux e projetor.", Entity.DOCENTE);
        seedVenue("CTC", "INE - Informática e Estatística", "LAB-02", "Laboratório de Informática 2", 30,
                "30 computadores com Windows.", Entity.DOCENTE);
        seedVenue("CTC", "INE - Informática e Estatística", "SALA-205", "Sala de Reuniões do INE", 12,
                "Mesa de reunião e TV para apresentações.", Entity.DISCENTE, Entity.DOCENTE, Entity.ORGANIZACAO);
        seedVenue("CTC", "EFI - Espaço Físico Integrado", "SALA-101", "Sala 101", 50,
                "Sala de aula com quadro branco e projetor.", Entity.DISCENTE, Entity.DOCENTE, Entity.ORGANIZACAO);
        seedVenue("CDS", "Ginásio 1", "GIN-01", "Ginásio de Esportes", 300,
                "Quadra poliesportiva com arquibancada.", Entity.DOCENTE, Entity.ORGANIZACAO);
        seedVenue("OUTRO", "Biblioteca Universitária (BU)", "ESP-01", "Espaço de Convivência da BU", 80,
                "Espaço aberto para exposições e feiras.", Entity.DISCENTE, Entity.DOCENTE, Entity.ORGANIZACAO);

        LocalDate today = LocalDate.now();
        LocalDateTime currentHour = LocalDateTime.now().truncatedTo(ChronoUnit.HOURS);
        seedEvent(maria, "Oficina de Design de Interfaces",
                "Oficina prática de prototipação de telas.",
                new Period(currentHour.minusHours(1), currentHour.plusHours(2)), EventStatus.ATIVO);
        seedEvent(maria, "Palestra: Introdução ao Flutter",
                "Palestra introdutória sobre desenvolvimento mobile com Flutter.",
                new Period(today.plusDays(2).atTime(19, 0), today.plusDays(2).atTime(21, 0)), EventStatus.ATIVO);
        // Começa em ~20 horas: gera o lembrete de 24 horas sem espaço.
        seedEvent(maria, "Reunião de Planejamento da Semana Acadêmica",
                "Reunião com a comissão organizadora.",
                new Period(currentHour.plusHours(20), currentHour.plusHours(22)), EventStatus.ATIVO);
        seedEvent(maria, "Semana Acadêmica de Computação",
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

        seedNotification(maria, NotificationType.NOVO_ESPACO, "Novo espaço disponível: Auditório do CTC (CTC - Bloco A - Direção do CTC).",
                null, LocalDateTime.now().minusDays(1), true);
    }

    private void seedVenue(String center, String building, String code, String name, int capacity, String description,
                           Entity... allowedRoles) {
        save(new Venue(UUID.randomUUID().toString(), code, name, center, building, capacity, description, Set.of(allowedRoles)));
    }

    private void seedNotification(User recipient, NotificationType type, String message, Long eventId,
                                  LocalDateTime createdAt, boolean read) {
        save(new Notification(nextNotificationId(), recipient, type, message, eventId, createdAt, read));
    }

    private Event seedEvent(User creator, String title, String description, Period period, EventStatus status) {
        Event event = new Event(nextEventId(), title, description, period, status, null, creator);
        save(event);
        return event;
    }
}