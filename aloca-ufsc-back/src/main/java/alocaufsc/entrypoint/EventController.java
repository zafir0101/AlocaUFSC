package alocaufsc.entrypoint;

import alocaufsc.domain.authenticationservices.AuthService;
import alocaufsc.domain.entities.Period;
import alocaufsc.domain.entities.User;
import alocaufsc.domain.eventsystem.DuplicateEventException;
import alocaufsc.domain.eventsystem.EventService;
import alocaufsc.domain.eventsystem.InfoEvent;
import alocaufsc.entrypoint.DTO.EventRequest;
import alocaufsc.entrypoint.DTO.EventResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

@RestController
@RequestMapping("/api/events")
@CrossOrigin(origins = "*")
public class EventController {

    private static final String BEARER_PREFIX = "Bearer ";

    private final EventService eventService;
    private final AuthService authService;

    public EventController(EventService eventService, AuthService authService) {
        this.eventService = eventService;
        this.authService = authService;
    }

    @GetMapping("/me")
    public List<EventResponse> getMyEvents(@RequestHeader(value = "Authorization", required = false) String authorization) {
        User user = authenticatedUser(authorization);
        return eventService.getEventsByCreator(user).stream().map(EventResponse::from).toList();
    }

    @GetMapping("/{id}")
    public EventResponse getEvent(@RequestHeader(value = "Authorization", required = false) String authorization,
                                  @PathVariable Long id) {
        User user = authenticatedUser(authorization);
        return EventResponse.from(eventService.getEvent(user, id));
    }

    @PostMapping
    public ResponseEntity<EventResponse> createEvent(@RequestHeader(value = "Authorization", required = false) String authorization,
                                                     @RequestBody EventRequest request) {
        User user = authenticatedUser(authorization);
        EventResponse response = EventResponse.from(eventService.createEvent(user, toInfoEvent(request)));
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    public EventResponse editEvent(@RequestHeader(value = "Authorization", required = false) String authorization,
                                   @PathVariable Long id,
                                   @RequestBody EventRequest request) {
        User user = authenticatedUser(authorization);
        return EventResponse.from(eventService.editEvent(user, id, toInfoEvent(request)));
    }

    @PatchMapping("/{id}/cancel")
    public EventResponse cancelEvent(@RequestHeader(value = "Authorization", required = false) String authorization,
                                     @PathVariable Long id) {
        User user = authenticatedUser(authorization);
        return EventResponse.from(eventService.cancelEvent(user, id));
    }

    @PatchMapping("/{id}/suspend")
    public EventResponse suspendEvent(@RequestHeader(value = "Authorization", required = false) String authorization,
                                      @PathVariable Long id) {
        User user = authenticatedUser(authorization);
        return EventResponse.from(eventService.suspendEvent(user, id));
    }

    @PatchMapping("/{id}/reactivate")
    public EventResponse reactivateEvent(@RequestHeader(value = "Authorization", required = false) String authorization,
                                         @PathVariable Long id) {
        User user = authenticatedUser(authorization);
        return EventResponse.from(eventService.reactivateEvent(user, id));
    }

    private User authenticatedUser(String authorization) {
        String token = authorization != null && authorization.startsWith(BEARER_PREFIX)
                ? authorization.substring(BEARER_PREFIX.length())
                : null;
        return authService.findUserByAccessToken(token)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Sessão inválida. Faça login novamente."));
    }

    private InfoEvent toInfoEvent(EventRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("Os dados do evento não podem ser nulos.");
        }
        return new InfoEvent(request.title(), request.description(), new Period(request.start(), request.end()), null);
    }

    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<Map<String, String>> handleStatus(ResponseStatusException e) {
        return ResponseEntity.status(e.getStatusCode()).body(Map.of("mensagem", e.getReason()));
    }

    @ExceptionHandler(DuplicateEventException.class)
    public ResponseEntity<Map<String, Object>> handleDuplicate(DuplicateEventException e) {
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(Map.of("mensagem", e.getMessage(), "eventoId", e.getExistingEvent().getId()));
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, String>> handleBadRequest(IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(Map.of("mensagem", e.getMessage()));
    }

    @ExceptionHandler(NoSuchElementException.class)
    public ResponseEntity<Map<String, String>> handleNotFound(NoSuchElementException e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("mensagem", e.getMessage()));
    }

    @ExceptionHandler(SecurityException.class)
    public ResponseEntity<Map<String, String>> handleForbidden(SecurityException e) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("mensagem", e.getMessage()));
    }
}