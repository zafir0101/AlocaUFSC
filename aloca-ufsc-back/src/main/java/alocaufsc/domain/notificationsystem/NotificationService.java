package alocaufsc.domain.notificationsystem;

import alocaufsc.domain.entities.Entity;
import alocaufsc.domain.entities.User;
import alocaufsc.technicalservices.persistence.FacadeDbRest;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.Comparator;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Objects;

@Service
public class NotificationService {
    private final FacadeDbRest facadeDbRest;

    public NotificationService(FacadeDbRest facadeDbRest) {
        this.facadeDbRest = facadeDbRest;
    }

    public List<Notification> getNotifications(User user) {
        return facadeDbRest.findNotificationsByRecipient(user).stream()
                .sorted(Comparator.comparing(Notification::getCreatedAt).reversed())
                .toList();
    }

    public long countUnread(User user) {
        return facadeDbRest.findNotificationsByRecipient(user).stream()
                .filter(n -> !n.isRead())
                .count();
    }

    public Notification notify(User recipient, NotificationType type, String message, Long eventId) {
        Notification notification = new Notification(null, recipient, type, message, eventId, LocalDateTime.now(), false);
        return facadeDbRest.saveNotification(notification);
    }

    public Notification notify(User recipient, String message, Long eventId) {
        return notify(recipient, NotificationType.GERAL, message, eventId);
    }

    public void notifyOnce(User recipient, NotificationType type, String message, Long eventId) {
        boolean alreadySent = facadeDbRest.findNotificationsByRecipient(recipient).stream()
                .anyMatch(n -> n.getType() == type && Objects.equals(n.getEventId(), eventId));

        if (!alreadySent) {
            notify(recipient, type, message, eventId);
        }
    }

    public void notifyRoles(Collection<Entity> roles, NotificationType type, String message, Long eventId) {
        facadeDbRest.findAllUsers().stream()
                .filter(u -> u.getEntity() != Entity.MANAGER)
                .filter(u -> roles.contains(u.getEntity()))
                .forEach(u -> notify(u, type, message, eventId));
    }

    public Notification markAsRead(User user, Long notificationId) {
        Notification notification = getOwned(user, notificationId);
        notification.setRead(true);
        return facadeDbRest.saveNotification(notification);
    }

    public void markAllAsRead(User user) {
        facadeDbRest.findNotificationsByRecipient(user).forEach(n -> {
            n.setRead(true);
            facadeDbRest.saveNotification(n);
        });
    }

    public void delete(User user, Long notificationId) {
        facadeDbRest.deleteNotification(getOwned(user, notificationId).getId());
    }

    public void deleteRead(User user) {
        facadeDbRest.findNotificationsByRecipient(user).stream()
                .filter(Notification::isRead)
                .forEach(n -> facadeDbRest.deleteNotification(n.getId()));
    }

    private Notification getOwned(User user, Long notificationId) {
        return facadeDbRest.findNotification(notificationId)
                .filter(n -> n.isFor(user))
                .orElseThrow(() -> new NoSuchElementException("Notificação não encontrada."));
    }
}