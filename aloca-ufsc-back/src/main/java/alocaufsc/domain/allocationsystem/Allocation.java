package alocaufsc.domain.allocationsystem;

import alocaufsc.domain.Period;
import alocaufsc.domain.entities.User;
import alocaufsc.domain.eventsystem.Event;

import java.time.LocalDateTime;

public class Allocation {
    private Long id;
    private Venue venue;
    private Event event;
    private User requester;
    private LocalDateTime start;
    private LocalDateTime end;
    private AllocationStatus status;
    private LocalDateTime createdAt;
    private User reviewedBy;
    private LocalDateTime reviewedAt;
    private String rejectionReason;

    public Allocation() {}

    public Allocation(Long id, Venue venue, Event event, User requester, LocalDateTime start, LocalDateTime end,
                      AllocationStatus status, LocalDateTime createdAt) {
        this.id = id;
        this.venue = venue;
        this.event = event;
        this.requester = requester;
        this.start = start;
        this.end = end;
        this.status = status;
        this.createdAt = createdAt;
    }

    public void updateData(Venue venue, LocalDateTime start, LocalDateTime end) {
        this.venue = venue;
        this.start = start;
        this.end = end;
    }

    public boolean overlaps(LocalDateTime otherStart, LocalDateTime otherEnd) {
        return start.isBefore(otherEnd) && otherStart.isBefore(end);
    }

    public Period getPeriod() { return new Period(start, end); }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Venue getVenue() { return venue; }
    public Event getEvent() { return event; }
    public User getRequester() { return requester; }
    public LocalDateTime getStart() { return start; }
    public LocalDateTime getEnd() { return end; }
    public AllocationStatus getStatus() { return status; }
    public void setStatus(AllocationStatus status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public User getReviewedBy() { return reviewedBy; }
    public void setReviewedBy(User reviewedBy) { this.reviewedBy = reviewedBy; }
    public LocalDateTime getReviewedAt() { return reviewedAt; }
    public void setReviewedAt(LocalDateTime reviewedAt) { this.reviewedAt = reviewedAt; }
    public String getRejectionReason() { return rejectionReason; }
    public void setRejectionReason(String rejectionReason) { this.rejectionReason = rejectionReason; }
}