package alocaufsc.entrypoint;

import alocaufsc.domain.entities.User;
import alocaufsc.domain.notificationsystem.NotificationService;
import alocaufsc.entrypoint.DTO.NotificationResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = "*")
public class NotificationController {

    private final NotificationService notificationService;

    // Injeção de dependência via construtor
    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping
    public List<NotificationResponse> getNotifications(@AuthenticationPrincipal User user) {
        return notificationService.getNotifications(user).stream().map(NotificationResponse::from).toList();
    }

    @GetMapping("/unread-count")
    public Map<String, Long> countUnread(@AuthenticationPrincipal User user) {
        return Map.of("naoLidas", notificationService.countUnread(user));
    }

    @PatchMapping("/{id}/read")
    public NotificationResponse markAsRead(@AuthenticationPrincipal User user, @PathVariable String id) {
        return NotificationResponse.from(notificationService.markAsRead(user, id));
    }

    @PatchMapping("/read-all")
    public ResponseEntity<Void> markAllAsRead(@AuthenticationPrincipal User user) {
        notificationService.markAllAsRead(user);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@AuthenticationPrincipal User user, @PathVariable String id) {
        notificationService.delete(user, id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/read")
    public ResponseEntity<Void> deleteRead(@AuthenticationPrincipal User user) {
        notificationService.deleteRead(user);
        return ResponseEntity.noContent().build();
    }
}