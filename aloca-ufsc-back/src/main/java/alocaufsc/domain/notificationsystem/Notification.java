package alocaufsc.domain.notificationsystem;

import alocaufsc.domain.entities.User;

import java.time.LocalDateTime;

public class Notification {
    private Long id;
    private User recipient;
    private NotificationType type;
    private String message;
    private Long eventId;
    private LocalDateTime createdAt;
    private boolean read;

    public Notification() {}

    public Notification(Long id, User recipient, NotificationType type, String message, Long eventId,
                        LocalDateTime createdAt, boolean read) {
        this.id = id;
        this.recipient = recipient;
        this.type = type;
        this.message = message;
        this.eventId = eventId;
        this.createdAt = createdAt;
        this.read = read;
    }

    public boolean isFor(User user) {
        return recipient != null && user != null && recipient.getId().equals(user.getId());
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public User getRecipient() { return recipient; }
    public void setRecipient(User recipient) { this.recipient = recipient; }
    public NotificationType getType() { return type; }
    public void setType(NotificationType type) { this.type = type; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public Long getEventId() { return eventId; }
    public void setEventId(Long eventId) { this.eventId = eventId; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public boolean isRead() { return read; }
    public void setRead(boolean read) { this.read = read; }
}