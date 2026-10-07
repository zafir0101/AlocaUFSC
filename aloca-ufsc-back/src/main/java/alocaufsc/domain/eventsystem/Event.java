package alocaufsc.domain.eventsystem;

import alocaufsc.domain.allocationsystem.Venue;
import alocaufsc.domain.entities.Period;
import alocaufsc.domain.entities.User;

public class Event {
    private Long id;
    private String title;
    private String description;
    private Period period;
    private EventStatus status;
    private Venue venue;
    private User creator;

    public Event() {}

    public Event(Long id, String title, String description, Period period, EventStatus status, Venue venue, User creator) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.period = period;
        this.status = status;
        this.venue = venue;
        this.creator = creator;
    }

    public boolean isCreatedBy(User user) {
        return creator != null && user != null && creator.getId().equals(user.getId());
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Period getPeriod() { return period; }
    public void setPeriod(Period period) { this.period = period; }
    public EventStatus getStatus() { return status; }
    public void setStatus(EventStatus status) { this.status = status; }
    public Venue getVenue() { return venue; }
    public void setVenue(Venue venue) { this.venue = venue; }
    public User getCreator() { return creator; }
    public void setCreator(User creator) { this.creator = creator; }
}