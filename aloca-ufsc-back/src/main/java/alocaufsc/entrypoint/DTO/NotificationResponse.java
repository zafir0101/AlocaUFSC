package alocaufsc.entrypoint.DTO;

import alocaufsc.domain.notificationsystem.Notification;

import java.time.LocalDateTime;

public record NotificationResponse(String id, String type, String message, String eventId, LocalDateTime createdAt, boolean read) {
    public static NotificationResponse from(Notification n) {
        return new NotificationResponse(n.getId(), n.getType().name(), n.getMessage(), n.getEventId(), n.getCreatedAt(), n.isRead());
    }
}