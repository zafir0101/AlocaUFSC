package alocaufsc.domain.eventsystem;

import alocaufsc.domain.Period;
import alocaufsc.domain.allocationsystem.Allocation;
import alocaufsc.domain.allocationsystem.AllocationStatus;
import alocaufsc.domain.allocationsystem.Venue;
import alocaufsc.domain.entities.User;

public class Event {
    private String id;
    private String title;
    private String description;
    private Period period;
    private EventStatus status;
    private Venue venue;
    private User creator;

    public Event() {}

    public Event(String id, String title, String description, Period period, EventStatus status, Venue venue, User creator) {
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

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Period getPeriod() { return period; }
    public void setPeriod(Period period) { this.period = period; }
    public EventStatus getStatus() { return status; }
    public void setStatus(EventStatus status) { this.status = status; }
    public void setStatusWithAllocationStatus(AllocationStatus allocationStatus) {
        switch (allocationStatus) {
            case AllocationStatus.APPROVED -> this.status = EventStatus.ATIVO;
            case AllocationStatus.REJECTED -> this.status = EventStatus.SEM_ESPACO;
            case AllocationStatus.PENDING -> this.status = EventStatus.AGUARDANDO_APROVACAO;
        }
    }
    public Venue getVenue() { return venue; }
    public void setVenue(Venue venue) { this.venue = venue; }
    public User getCreator() { return creator; }
    public void setCreator(User creator) { this.creator = creator; }
    public boolean isAllocatable() { return this.status == EventStatus.SEM_ESPACO; }
}