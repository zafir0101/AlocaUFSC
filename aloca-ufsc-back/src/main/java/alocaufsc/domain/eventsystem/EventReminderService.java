package alocaufsc.domain.eventsystem;

import alocaufsc.domain.notificationsystem.NotificationService;
import alocaufsc.domain.notificationsystem.NotificationType;
import alocaufsc.technicalservices.persistence.FacadeDbRest;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;

// cada lembrete é enviado uma vez só por evento.
@Service
public class EventReminderService {
    private final FacadeDbRest facadeDbRest;
    private final EventService eventService;
    private final NotificationService notificationService;

    public EventReminderService(FacadeDbRest facadeDbRest, EventService eventService,
                                NotificationService notificationService) {
        this.facadeDbRest = facadeDbRest;
        this.eventService = eventService;
        this.notificationService = notificationService;
    }

    @Scheduled(initialDelay = 5_000, fixedDelay = 600_000)
    public void sendReminders() {
        LocalDateTime now = LocalDateTime.now();
        for (Event event : facadeDbRest.findAllEvents()) {
            if (event.getStatus() == EventStatus.ATIVO) {
                remindMissingVenue(event, now);
            } else if (event.getStatus() == EventStatus.SUSPENSO && !event.getPeriod().end().isAfter(now)) {
                notificationService.notifyOnce(event.getCreator(), NotificationType.EVENTO_SUSPENSO_DATA_PASSADA,
                        "Seu evento suspenso \"" + event.getTitle() + "\" já passou da data. "
                                + "Edite a data para poder reativá-lo.", event.getId());
            }
        }
    }

    private void remindMissingVenue(Event event, LocalDateTime now) {
        LocalDateTime start = event.getPeriod().start();
        if (!start.isAfter(now)) return;

        EventStatus eventStatus = event.getStatus();
        if (eventStatus == EventStatus.ATIVO) return;

        String situation = eventStatus == EventStatus.AGUARDANDO_APROVACAO
                ? "o espaço ainda não foi confirmado."
                : "ainda não tem espaço definido.";
        Duration untilStart = Duration.between(now, start);

        if (untilStart.compareTo(Duration.ofHours(24)) <= 0) {
            notificationService.notifyOnce(event.getCreator(), NotificationType.EVENTO_SEM_ESPACO_24_HORAS,
                    "Seu evento \"" + event.getTitle() + "\" começa em menos de 24 horas e " + situation, event.getId());
        } else if (untilStart.compareTo(Duration.ofDays(3)) <= 0) {
            notificationService.notifyOnce(event.getCreator(), NotificationType.EVENTO_SEM_ESPACO_3_DIAS,
                    "Seu evento \"" + event.getTitle() + "\" é em até 3 dias e " + situation, event.getId());
        }
    }
}