package alocaufsc.domain.eventsystem;

import alocaufsc.domain.allocationsystem.Allocation;
import alocaufsc.domain.allocationsystem.AllocationStatus;
import alocaufsc.domain.notificationsystem.Notification;
import alocaufsc.domain.notificationsystem.NotificationType;
import alocaufsc.technicalservices.persistence.FacadeDbRest;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;


@Service
public class EventObserver {
    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final Map<String, Event> events = new ConcurrentHashMap<>();

    private final FacadeDbRest facadeDbRest;

    public EventObserver(FacadeDbRest facadeDbRest) { this.facadeDbRest = facadeDbRest; }

    public void addObserver(String allocationId, Event event) {
        this.events.put(allocationId, event);
    }

    public void removeObserver(String allocationId) {
        this.events.remove(allocationId);
    }

    public void updateEventStatus(String allocationId) {
        Event event = events.get(allocationId);
        Allocation allocation = event.getAllocation();

        switch (allocation.getStatus()) {
            case AllocationStatus.APPROVED:
                event.setStatus(EventStatus.ATIVO);
                notifyRequester(allocation, event.getId(), NotificationType.ALOCACAO_APROVADA,
                        "Seu pedido de alocação do evento \"" + event.getTitle() + "\" foi aprovado: "
                                + allocation.getVenue().getName() + " (" + allocation.getVenue().getLocation() + "), "
                                + allocation.getStart().format(FMT) + " a " + allocation.getEnd().format(FMT) + ".");
                facadeDbRest.saveEvent(event);
                return;

            case AllocationStatus.PENDING:
                event.setStatus(EventStatus.AGUARDANDO_APROVACAO);
                facadeDbRest.saveEvent(event);
                return;

            default:
                if (allocation.getStatus() == AllocationStatus.CANCELED)
                    allocation.setRejectionReason("Conflito de horários com outro evento para o mesmo período e espaço.");
                event.setStatus(EventStatus.SEM_ESPACO);
                String msg = "Seu pedido de alocação do evento \"" + event.getTitle() + "\" em "
                        + allocation.getVenue().getName() + " foi recusado.";
                if (allocation.getRejectionReason() != null) {
                    msg += " Motivo: " + allocation.getRejectionReason();
                }
                notifyRequester(allocation, event.getId(), NotificationType.ALOCACAO_RECUSADA, msg);
                facadeDbRest.saveEvent(event);
        }
    }

    private void notifyRequester(Allocation allocation, String eventId, NotificationType type, String message) {
        facadeDbRest.saveNotification(new Notification(UUID.randomUUID().toString(), allocation.getRequester(), type, message,
                eventId, LocalDateTime.now(), false));
    }
}
