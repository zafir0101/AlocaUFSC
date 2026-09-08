package alocaufsc.technicalservices.rest;

import alocaufsc.domain.allocationsystem.Venue;
import alocaufsc.domain.allocationsystem.VenueRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/venues")
@CrossOrigin(origins = "*") // Allows Flutter calls during local development
public class VenueController {

    private final VenueRepository venueRepository;

    public VenueController(VenueRepository venueRepository) {
        this.venueRepository = venueRepository;
    }

    @GetMapping
    public List<Venue> getAllVenues() {
        return venueRepository.findAll();
    }

    @PostMapping
    public Venue createVenue(@RequestBody Venue venue) {
        return venueRepository.save(venue);
    }

    @PutMapping("/{id}")
    public Venue updateVenue(@PathVariable String id, @RequestBody Venue venue) {
        venue.setId(id);
        return venueRepository.save(venue);
    }

    @DeleteMapping("/{id}")
    public void deleteVenue(@PathVariable String id) {
        venueRepository.deleteById(id);
    }
}