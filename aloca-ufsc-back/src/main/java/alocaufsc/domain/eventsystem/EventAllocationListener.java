package alocaufsc.domain.eventsystem;

import alocaufsc.domain.allocationsystem.Allocation;
import alocaufsc.domain.allocationsystem.AllocationService;
import alocaufsc.domain.allocationsystem.AllocationStatus;
import alocaufsc.domain.allocationsystem.AllocationStatusListener;
import alocaufsc.domain.notificationsystem.Notification;
import alocaufsc.domain.notificationsystem.NotificationService;
import alocaufsc.domain.notificationsystem.NotificationType;
import alocaufsc.technicalservices.persistence.FacadeDbRest;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;


@Service
public class EventAllocationListener implements AllocationStatusListener {
    private final FacadeDbRest facadeDbRest;
    private final NotificationService notificationService;

    public EventAllocationListener (FacadeDbRest facadeDbRest, AllocationService allocationService,
        NotificationService notificationService) {
        this.facadeDbRest = facadeDbRest;
        this.notificationService = notificationService;
        allocationService.addObserver(this);
    }

    public void onAllocationStatusChanged(Allocation allocation) {
        Event event = facadeDbRest.findEventByAllocationId(allocation.getId())
                .orElseThrow(() -> new NoSuchElementException("Evento não encontrado."));

        switch (allocation.getStatus()) {
            case AllocationStatus.APPROVED:
                event.setStatus(EventStatus.ACTIVE);
                notificationService.notifyAllocationApproved(allocation, event);
                return;

            case AllocationStatus.PENDING:
                event.setStatus(EventStatus.AWAITING_APPROVAL);
                facadeDbRest.saveEvent(event);
                return;

            default:
                if (allocation.getStatus() == AllocationStatus.CANCELED)
                    allocation.setRejectionReason("Conflito de horários com outro evento para o mesmo período e espaço.");
                event.setStatus(EventStatus.NO_ALLOCATIONS);
                facadeDbRest.saveEvent(event);
                notificationService.notifyAllocationRefused(allocation, event);
        }
    }

}
