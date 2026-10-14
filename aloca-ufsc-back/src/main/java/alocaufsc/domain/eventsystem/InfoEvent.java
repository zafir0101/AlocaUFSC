package alocaufsc.domain.eventsystem;

import alocaufsc.domain.Period;
import alocaufsc.domain.allocationsystem.Venue;

public record InfoEvent(String title, String description, Period period, Venue venue) {}