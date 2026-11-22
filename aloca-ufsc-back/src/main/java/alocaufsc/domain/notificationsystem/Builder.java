package alocaufsc.domain.notificationsystem;

import alocaufsc.domain.entities.User;

import java.time.LocalDateTime;

public interface Builder {
    void reset();
    void setId(String Id);
    void setRecipient(User user);
    void setType(NotificationType type);
    void setMessage(String message);
    void setEventId(String Id);
    void setCreatedAt(LocalDateTime now);
    void setRead();
}
