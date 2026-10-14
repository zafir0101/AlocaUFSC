package alocaufsc.entrypoint;

import alocaufsc.domain.allocationsystem.UfscCampus;
import alocaufsc.domain.allocationsystem.VenueInfo;
import alocaufsc.domain.allocationsystem.VenueService;
import alocaufsc.domain.entities.User;
import alocaufsc.entrypoint.DTO.VenueRequest;
import alocaufsc.entrypoint.DTO.VenueResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/venues")
@CrossOrigin(origins = "*")
public class VenueController {

    private final VenueService venueService;

    public VenueController(VenueService venueService) {
        this.venueService = venueService;
    }

    @GetMapping
    public List<VenueResponse> getAllVenues() {
        return venueService.getAllVenues().stream().map(VenueResponse::from).toList();
    }

    @GetMapping("/campus")
    public List<UfscCampus.Center> getCampus() {
        return venueService.getCampus();
    }

    @GetMapping("/{id}")
    public VenueResponse getVenue(@PathVariable String id) {
        return VenueResponse.from(venueService.getVenue(id));
    }

    @PostMapping
    @PreAuthorize("hasAuthority('ADMINISTRADOR')")
    public ResponseEntity<VenueResponse> createVenue(@AuthenticationPrincipal User admin,
                                                     @RequestBody VenueRequest request) {
        VenueResponse response = VenueResponse.from(venueService.createVenue(admin, toVenueInfo(request)));
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('ADMINISTRADOR')")
    public VenueResponse updateVenue(@AuthenticationPrincipal User admin,
                                     @PathVariable String id,
                                     @RequestBody VenueRequest request) {
        return VenueResponse.from(venueService.updateVenue(admin, id, toVenueInfo(request)));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('ADMINISTRADOR')")
    public ResponseEntity<Void> deleteVenue(@AuthenticationPrincipal User admin,
                                            @PathVariable String id) {
        venueService.deleteVenue(admin, id);
        return ResponseEntity.noContent().build();
    }

    private VenueInfo toVenueInfo(VenueRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("Os dados do espaço não podem ser nulos.");
        }
        return new VenueInfo(request.center(), request.building(), request.code(), request.name(), request.capacity(),
                request.description(), request.allowedRoles());
    }
}