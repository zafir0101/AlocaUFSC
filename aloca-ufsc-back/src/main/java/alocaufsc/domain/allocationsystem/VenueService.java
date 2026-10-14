package alocaufsc.domain.allocationsystem;

import alocaufsc.domain.entities.Entity;
import alocaufsc.domain.entities.User;
import alocaufsc.domain.notificationsystem.NotificationService;
import alocaufsc.domain.notificationsystem.NotificationType;
import alocaufsc.technicalservices.persistence.FacadeDbRest;
import org.springframework.stereotype.Service;

import java.text.Normalizer;
import java.util.Comparator;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.UUID;

@Service
public class VenueService {
    public static final int MAX_CODE_LENGTH = 20;
    public static final int MAX_NAME_LENGTH = 100;
    public static final int MAX_BUILDING_LENGTH = 100;
    public static final int MAX_DESCRIPTION_LENGTH = 1000;
    public static final int MAX_CAPACITY = 10000;

    private final FacadeDbRest facadeDbRest;
    private final NotificationService notificationService;

    public VenueService(FacadeDbRest facadeDbRest, NotificationService notificationService) {
        this.facadeDbRest = facadeDbRest;
        this.notificationService = notificationService;
    }

    public List<Venue> getAllVenues(User currentUser) {
        return facadeDbRest.findAllVenues().stream()
                .filter(venue -> currentUser.getEntity() == Entity.MANAGER || venue.allows(currentUser.getEntity()))
                .sorted(Comparator.comparing(Venue::getCenter)
                        .thenComparing(Venue::getBuilding, String.CASE_INSENSITIVE_ORDER)
                        .thenComparing(Venue::getName, String.CASE_INSENSITIVE_ORDER))
                .toList();
    }

    public List<UfscCampus.Center> getCampus() {
        return UfscCampus.CENTERS;
    }

    public Venue getVenue(String id) {
        return facadeDbRest.findVenue(id)
                .orElseThrow(() -> new NoSuchElementException("Espaço não encontrado."));
    }

    public Venue createVenue(User admin, VenueInfo info) {
        ensureAdmin(admin);
        validate(info, null);

        Venue venue = new Venue(UUID.randomUUID().toString(), info.code().trim(), info.name().trim(),
                info.center().trim().toUpperCase(), info.building().trim(), info.capacity(), info.description(),
                info.allowedRoles());
        Venue saved = facadeDbRest.save(venue);

        notificationService.notifyRoles(saved.getAllowedRoles(), NotificationType.NOVO_ESPACO,
                "Novo espaço disponível: " + saved.getName() + " (" + saved.getLocation() + ").", null);
        return saved;
    }

    public Venue updateVenue(User admin, String id, VenueInfo info) {
        ensureAdmin(admin);
        Venue venue = getVenue(id);
        validate(info, id);

        venue.setCode(info.code().trim());
        venue.setName(info.name().trim());
        venue.setCenter(info.center().trim().toUpperCase());
        venue.setBuilding(info.building().trim());
        venue.setCapacity(info.capacity());
        venue.setDescription(info.description());
        venue.setAllowedRoles(info.allowedRoles());
        return facadeDbRest.save(venue);
    }

    public void deleteVenue(User admin, String id) {
        ensureAdmin(admin);
        Venue venue = getVenue(id);
        // TODO(alocação): quando existirem alocações, tratar as alocações futuras deste espaço
        // (cancelar e avisar os organizadores com notificationService.notify(...)) antes de excluir.
        facadeDbRest.deleteVenueById(venue.getId());
    }

    private void ensureAdmin(User user) {
        if (user == null || user.getEntity() != Entity.MANAGER) {
            throw new SecurityException("Apenas administradores podem gerenciar espaços físicos.");
        }
    }

    private void validate(VenueInfo info, String ignoredVenueId) {
        if (info == null) {
            throw new IllegalArgumentException("Os dados do espaço não podem ser nulos.");
        }
        if (info.center() == null || !UfscCampus.isKnownCenter(info.center().trim())) {
            throw new IllegalArgumentException("Selecione o centro do espaço.");
        }
        requireText(info.building(), "prédio", MAX_BUILDING_LENGTH);
        requireText(info.code(), "código", MAX_CODE_LENGTH);
        requireText(info.name(), "nome", MAX_NAME_LENGTH);
        if (info.description() != null && info.description().length() > MAX_DESCRIPTION_LENGTH) {
            throw new IllegalArgumentException("A descrição deve ter no máximo " + MAX_DESCRIPTION_LENGTH + " caracteres.");
        }
        if (info.capacity() == null || info.capacity() < 1) {
            throw new IllegalArgumentException("A capacidade deve ser maior que zero.");
        }
        if (info.capacity() > MAX_CAPACITY) {
            throw new IllegalArgumentException("A capacidade deve ser no máximo " + MAX_CAPACITY + ".");
        }
        if (info.allowedRoles() == null || info.allowedRoles().isEmpty()) {
            throw new IllegalArgumentException("Selecione pelo menos um perfil que pode usar o espaço.");
        }

        List<Venue> sameBuilding = facadeDbRest.findAllVenues().stream()
                .filter(v -> !v.getId().equals(ignoredVenueId))
                .filter(v -> v.getCenter().equalsIgnoreCase(info.center().trim()))
                .filter(v -> normalize(v.getBuilding()).equals(normalize(info.building())))
                .toList();
        for (Venue v : sameBuilding) {
            if (normalize(v.getCode()).equals(normalize(info.code()))) {
                throw new IllegalArgumentException("Já existe em " + v.getLocation() + " um espaço com o código "
                        + v.getCode() + " (" + v.getName() + ").");
            }
            if (normalize(v.getName()).equals(normalize(info.name()))) {
                throw new IllegalArgumentException("Já existe em " + v.getLocation() + " um espaço com o nome \""
                        + v.getName() + "\" (" + v.getCode() + ").");
            }
        }
    }

    private String normalize(String text) {
        if (text == null) return "";
        return Normalizer.normalize(text, Normalizer.Form.NFD).replaceAll("\\p{M}", "").toLowerCase()
                .replaceAll("[^a-z0-9]", "");
    }

    private void requireText(String value, String field, int maxLength) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("O campo " + field + " é obrigatório.");
        }
        if (value.trim().length() > maxLength) {
            throw new IllegalArgumentException("O campo " + field + " deve ter no máximo " + maxLength + " caracteres.");
        }
    }
}