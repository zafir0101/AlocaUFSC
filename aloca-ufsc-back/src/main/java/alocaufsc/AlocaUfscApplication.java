package alocaufsc;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling // lembretes automáticos de eventos (EventReminderService)
public class AlocaUfscApplication {

    public static void main(String[] args) {
        SpringApplication.run(AlocaUfscApplication.class, args);
    }
}