package alocaufsc.domain.eventsystem;

import alocaufsc.domain.Period;
import alocaufsc.domain.allocationsystem.Allocation;

public record EventInfo(String title, String description, Period period, Allocation allocation) {}