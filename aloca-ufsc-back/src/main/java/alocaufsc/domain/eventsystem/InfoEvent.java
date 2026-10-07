package alocaufsc.domain.eventsystem;

import alocaufsc.domain.allocationsystem.Venue;
import alocaufsc.domain.entities.Period;

public record InfoEvent(String title, String description, Period period, Venue venue) {}