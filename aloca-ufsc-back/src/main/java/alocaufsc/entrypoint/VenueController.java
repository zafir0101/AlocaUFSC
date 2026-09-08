package alocaufsc.entrypoint;

import alocaufsc.domain.allocationsystem.Venue;
import alocaufsc.domain.allocationsystem.VenueService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/venues")
@CrossOrigin(origins = "*") // Allows Flutter calls during local development
public class VenueController {

    private final VenueService venueService;

    public VenueController(VenueService venueService) {
        this.venueService = venueService;
    }

    @GetMapping
    public List<Venue> getAllVenues() {
        return venueService.getAllVenues();
    }

    @PostMapping
    public Venue createVenue(@RequestBody Venue venue) {
        return venueService.createVenue(venue);
    }

    @PutMapping("/{id}")
    public Venue updateVenue(@PathVariable String id, @RequestBody Venue venue) {
        return venueService.updateVenue(id, venue);
    }

    @DeleteMapping("/{id}")
    public void deleteVenue(@PathVariable String id) {
        venueService.deleteVenue(id);
    }
}