package alocaufsc.domain.notificationsystem;

import alocaufsc.domain.entities.User;

import java.time.LocalDateTime;

public class AppNotificationBuilder implements Builder {
    private Notification notification;

    AppNotificationBuilder() {
       reset();
    }

    @Override
    public void reset() {
       this.notification = new Notification();
    }

    @Override
    public void setId(String id) {
       this.notification.setId(id);
    }

    @Override
    public void setRecipient(User user) {
        this.notification.setRecipient(user);
    }

    @Override
    public void setType(NotificationType type) {
        this.notification.setType(type);
    }

    @Override
    public void setMessage(String message) {
        this.notification.setMessage(message);
    }

    @Override
    public void setEventId(String id) {
        this.notification.setEventId(id);
    }

    @Override
    public void setCreatedAt(LocalDateTime date) {
        this.notification.setCreatedAt(date);
    }

    @Override
    public void setRead() {
       this.notification.setRead(false);
    }

    public Notification getNotification() {
        return notification;
    }
}
