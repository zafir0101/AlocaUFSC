package alocaufsc.controllers;

import alocaufsc.domain.allocationsystem.Venue;
import alocaufsc.technicalservices.persistence.FacadeDbRest;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/venues")
@CrossOrigin(origins = "*") // Allows Flutter calls during local development
public class VenueController {

    private final FacadeDbRest facadeDbRest;

    public VenueController(FacadeDbRest facadeDbRest) {
        this.facadeDbRest = facadeDbRest;
    }

    @GetMapping
    public List<Venue> getAllVenues() {
        return facadeDbRest.findAllVenues();
    }

    @PostMapping
    public Venue createVenue(@RequestBody Venue venue) {
        return facadeDbRest.save(venue);
    }

    @PutMapping("/{id}")
    public Venue updateVenue(@PathVariable String id, @RequestBody Venue venue) {
        venue.setId(id);
        return facadeDbRest.save(venue);
    }

    @DeleteMapping("/{id}")
    public void deleteVenue(@PathVariable String id) {
        facadeDbRest.deleteVenueById(id);
    }
}