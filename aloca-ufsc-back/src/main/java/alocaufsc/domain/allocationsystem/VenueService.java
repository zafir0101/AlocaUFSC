package alocaufsc.domain.allocationsystem;

import alocaufsc.technicalservices.persistence.FacadeDbRest;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class VenueService {
    private final FacadeDbRest facadeDbRest;

    public VenueService(FacadeDbRest facadeDbRest) {
        this.facadeDbRest = facadeDbRest;
    }

    public List<Venue> getAllVenues() {
        return facadeDbRest.findAllVenues();
    }

    public Venue createVenue(Venue venue) {
        if (venue == null) {
            throw new IllegalArgumentException("Os dados do espaço (Venue) não podem ser nulos.");
        }

        return facadeDbRest.save(venue);
    }

    public Venue updateVenue(String id, Venue venue) {
        venue.setId(id);
        return facadeDbRest.save(venue);
    }

    public void deleteVenue(String id) {
        facadeDbRest.deleteVenueById(id);
    }
}