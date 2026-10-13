package alocaufsc.entrypoint;

import alocaufsc.domain.entities.Period;
import alocaufsc.domain.entities.User;
import alocaufsc.domain.eventsystem.Event;
import alocaufsc.domain.eventsystem.EventService;
import alocaufsc.domain.eventsystem.InfoEvent;
import alocaufsc.entrypoint.DTO.EventRequest;
import alocaufsc.entrypoint.DTO.EventResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/events")
@CrossOrigin(origins = "*")
public class EventController {

    private final EventService eventService;
    private final AuthenticatedUserResolver userResolver;

    public EventController(EventService eventService, AuthenticatedUserResolver userResolver) {
        this.eventService = eventService;
        this.userResolver = userResolver;
    }

    @GetMapping("/me")
    public List<EventResponse> getMyEvents(@RequestHeader(value = "Authorization", required = false) String authorization) {
        User user = authenticatedUser(authorization);
        return eventService.getEventsByCreator(user).stream().map(this::toResponse).toList();
    }

    @GetMapping("/{id}")
    public EventResponse getEvent(@RequestHeader(value = "Authorization", required = false) String authorization,
                                  @PathVariable Long id) {
        User user = authenticatedUser(authorization);
        return toResponse(eventService.getEvent(user, id));
    }

    @PostMapping
    public ResponseEntity<EventResponse> createEvent(@RequestHeader(value = "Authorization", required = false) String authorization,
                                                     @RequestBody EventRequest request) {
        User user = authenticatedUser(authorization);
        EventResponse response = toResponse(eventService.createEvent(user, toInfoEvent(request)));
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    public EventResponse editEvent(@RequestHeader(value = "Authorization", required = false) String authorization,
                                   @PathVariable Long id,
                                   @RequestBody EventRequest request) {
        User user = authenticatedUser(authorization);
        return toResponse(eventService.editEvent(user, id, toInfoEvent(request)));
    }

    @PatchMapping("/{id}/cancel")
    public EventResponse cancelEvent(@RequestHeader(value = "Authorization", required = false) String authorization,
                                     @PathVariable Long id) {
        User user = authenticatedUser(authorization);
        return toResponse(eventService.cancelEvent(user, id));
    }

    @PatchMapping("/{id}/suspend")
    public EventResponse suspendEvent(@RequestHeader(value = "Authorization", required = false) String authorization,
                                      @PathVariable Long id) {
        User user = authenticatedUser(authorization);
        return toResponse(eventService.suspendEvent(user, id));
    }

    @PatchMapping("/{id}/reactivate")
    public EventResponse reactivateEvent(@RequestHeader(value = "Authorization", required = false) String authorization,
                                         @PathVariable Long id) {
        User user = authenticatedUser(authorization);
        return toResponse(eventService.reactivateEvent(user, id));
    }

    private EventResponse toResponse(Event event) {
        return EventResponse.from(event, eventService.getAllocationStatus(event));
    }

    private User authenticatedUser(String authorization) {
        return userResolver.resolve(authorization);
    }

    private InfoEvent toInfoEvent(EventRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("Os dados do evento não podem ser nulos.");
        }
        return new InfoEvent(request.title(), request.description(), new Period(request.start(), request.end()), null);
    }
}