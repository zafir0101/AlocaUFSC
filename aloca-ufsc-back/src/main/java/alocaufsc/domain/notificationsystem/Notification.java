package alocaufsc.domain.notificationsystem;

import alocaufsc.domain.entities.User;

import java.time.LocalDateTime;

public class Notification {
    private String id;
    private User recipient;
    private NotificationType type;
    private String message;
    private String eventId;
    private LocalDateTime createdAt;
    private boolean read;

    public Notification() {}

    public Notification(String id, User recipient, NotificationType type, String message, String eventId,
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

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public User getRecipient() { return recipient; }
    public void setRecipient(User recipient) { this.recipient = recipient; }
    public NotificationType getType() { return type; }
    public void setType(NotificationType type) { this.type = type; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public String getEventId() { return eventId; }
    public void setEventId(String eventId) { this.eventId = eventId; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public boolean isRead() { return read; }
    public void setRead(boolean read) { this.read = read; }
}