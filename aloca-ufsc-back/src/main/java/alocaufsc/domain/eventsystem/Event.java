package alocaufsc.domain.eventsystem;

import alocaufsc.domain.Period;
import alocaufsc.domain.allocationsystem.Allocation;
import alocaufsc.domain.entities.User;


public class Event {
    private String id;
    private String title;
    private String description;
    private Period period;
    private EventStatus status;
    private Allocation allocation;
    private User creator;

    public Event() {}

    public Event(String id, String title, String description, Period period, EventStatus status, Allocation allocation,
                 User creator) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.period = period;
        this.status = status;
        this.allocation = allocation;
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
    public Allocation getAllocation() { return this.allocation; }
    public void setAllocation(Allocation allocation) { this.allocation = allocation; }
    public User getCreator() { return creator; }
    public void setCreator(User creator) { this.creator = creator; }
    public boolean isAllocatable() { return this.status == EventStatus.SEM_ESPACO; }
}