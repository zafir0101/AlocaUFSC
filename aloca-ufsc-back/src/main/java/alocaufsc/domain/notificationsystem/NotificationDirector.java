package alocaufsc.domain.notificationsystem;

import alocaufsc.domain.allocationsystem.Allocation;
import alocaufsc.domain.eventsystem.Event;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

@Component
public class NotificationDirector {
    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    public void buildAllocationApproved(Builder builder, Allocation allocation, Event event) {
        String message = "Seu pedido de alocação do evento \"" + event.getTitle() + "\" foi aprovado: "
                + allocation.getVenue().getName() + " (" + allocation.getVenue().getLocation() + "), "
                + allocation.getStart().format(FMT) + " a " + allocation.getEnd().format(FMT) + ".";

        populateBase(builder, allocation, event, NotificationType.ALLOCATION_APPROVED, message);
    }

    public void buildAllocationRefused(Builder builder, Allocation allocation, Event event) {
        String message = "Seu pedido de alocação do evento \"" + event.getTitle() + "\" em "
                + allocation.getVenue().getName() + " foi recusado.";
        if (allocation.getRejectionReason() != null) {
            message += " Motivo: " + allocation.getRejectionReason();
        }

        populateBase(builder, allocation, event, NotificationType.ALLOCATION_REFUSED, message);
    }

    private void populateBase(Builder builder, Allocation allocation, Event event, NotificationType type, String message) {
        builder.reset();
        builder.setId(UUID.randomUUID().toString());
        builder.setRecipient(allocation.getRequester());
        builder.setType(type);
        builder.setMessage(message);
        builder.setEventId(event.getId());
        builder.setCreatedAt(LocalDateTime.now());
        builder.setRead();
    }
}
