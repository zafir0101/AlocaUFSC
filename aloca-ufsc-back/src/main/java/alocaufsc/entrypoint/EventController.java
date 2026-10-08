package alocaufsc.entrypoint;

import alocaufsc.domain.authenticationservices.AuthService;
import alocaufsc.domain.Period;
import alocaufsc.domain.entities.User;
import alocaufsc.domain.eventsystem.DuplicateEventException;
import alocaufsc.domain.eventsystem.EventService;
import alocaufsc.domain.eventsystem.InfoEvent;
import alocaufsc.entrypoint.DTO.EventRequest;
import alocaufsc.entrypoint.DTO.EventResponse;
import alocaufsc.technicalservices.persistence.FacadeDbRest;
import alocaufsc.technicalservices.security.JwtService;
import org.springframework.beans.factory.annotation.Autowired;
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
    @Autowired
    private EventService eventService;

    @Autowired
    private FacadeDbRest facadeDbRest;

    @Autowired
    private JwtService jwtService;

    @GetMapping("/me")
    public List<EventResponse> getMyEvents(@RequestHeader(value = "Authorization", required = false) String authorization) {
        return facadeDbRest.findUserbyAccessToken(jwtService.getTokenFromBody(authorization))
                .map(user -> eventService.getEventsByCreator(user).stream().map(EventResponse::from).toList() )
                .orElse(null);
    }

    @GetMapping("/{id}")
    public EventResponse getEvent(@RequestHeader(value = "Authorization", required = false) String authorization,
        @PathVariable Long id) {
        return facadeDbRest.findUserbyAccessToken(jwtService.getTokenFromBody(authorization))
                .map(user -> EventResponse.from(eventService.getEvent(user, id)) )
                .orElse(null);
    }

    @PostMapping
    public ResponseEntity<EventResponse> createEvent(@RequestHeader(value = "Authorization", required = false) String authorization,
        @RequestBody EventRequest request) {
        EventResponse response = facadeDbRest.findUserbyAccessToken(jwtService.getTokenFromBody(authorization))
                .map(user -> EventResponse.from(eventService.createEvent(user, toInfoEvent(request))))
                .orElse(null);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    public EventResponse editEvent(@RequestHeader(value = "Authorization", required = false) String authorization,
        @PathVariable Long id,
        @RequestBody EventRequest request) {
        return facadeDbRest.findUserbyAccessToken(jwtService.getTokenFromBody(authorization))
                .map(user -> EventResponse.from(eventService.editEvent(user, id, toInfoEvent(request))))
                .orElse(null);
    }

    @PatchMapping("/{id}/cancel")
    public EventResponse cancelEvent(@RequestHeader(value = "Authorization", required = false) String authorization,
        @PathVariable Long id) {
        return facadeDbRest.findUserbyAccessToken(jwtService.getTokenFromBody(authorization))
                .map(user -> EventResponse.from(eventService.cancelEvent(user, id)))
                .orElse(null);
    }

    @PatchMapping("/{id}/suspend")
    public EventResponse suspendEvent(@RequestHeader(value = "Authorization", required = false) String authorization,
        @PathVariable Long id) {
        return facadeDbRest.findUserbyAccessToken(jwtService.getTokenFromBody(authorization))
                .map(user -> EventResponse.from(eventService.suspendEvent(user, id)))
                .orElse(null);
    }

    @PatchMapping("/{id}/reactivate")
    public EventResponse reactivateEvent(@RequestHeader(value = "Authorization", required = false) String authorization,
        @PathVariable Long id) {
        return facadeDbRest.findUserbyAccessToken(jwtService.getTokenFromBody(authorization))
                .map(user -> EventResponse.from(eventService.reactivateEvent(user, id)))
                .orElse(null);
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
