package alocaufsc.entrypoint;

import alocaufsc.domain.entities.User;
import alocaufsc.domain.notificationsystem.NotificationService;
import alocaufsc.entrypoint.DTO.NotificationResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = "*")
public class NotificationController {

    private final NotificationService notificationService;
    private final AuthenticatedUserResolver userResolver;

    public NotificationController(NotificationService notificationService, AuthenticatedUserResolver userResolver) {
        this.notificationService = notificationService;
        this.userResolver = userResolver;
    }

    @GetMapping
    public List<NotificationResponse> getNotifications(@RequestHeader(value = "Authorization", required = false) String authorization) {
        User user = userResolver.resolve(authorization);
        return notificationService.getNotifications(user).stream().map(NotificationResponse::from).toList();
    }

    @GetMapping("/unread-count")
    public Map<String, Long> countUnread(@RequestHeader(value = "Authorization", required = false) String authorization) {
        User user = userResolver.resolve(authorization);
        return Map.of("naoLidas", notificationService.countUnread(user));
    }

    @PatchMapping("/{id}/read")
    public NotificationResponse markAsRead(@RequestHeader(value = "Authorization", required = false) String authorization,
                                           @PathVariable Long id) {
        User user = userResolver.resolve(authorization);
        return NotificationResponse.from(notificationService.markAsRead(user, id));
    }

    @PatchMapping("/read-all")
    public ResponseEntity<Void> markAllAsRead(@RequestHeader(value = "Authorization", required = false) String authorization) {
        User user = userResolver.resolve(authorization);
        notificationService.markAllAsRead(user);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@RequestHeader(value = "Authorization", required = false) String authorization,
                                       @PathVariable Long id) {
        User user = userResolver.resolve(authorization);
        notificationService.delete(user, id);
        return ResponseEntity.noContent().build();
    }

    // Apaga as notificações já lidas ("Limpar lidas").
    @DeleteMapping("/read")
    public ResponseEntity<Void> deleteRead(@RequestHeader(value = "Authorization", required = false) String authorization) {
        User user = userResolver.resolve(authorization);
        notificationService.deleteRead(user);
        return ResponseEntity.noContent().build();
    }
}