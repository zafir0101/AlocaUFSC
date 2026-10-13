package alocaufsc.entrypoint;

import alocaufsc.domain.allocationsystem.UfscCampus;
import alocaufsc.domain.allocationsystem.VenueInfo;
import alocaufsc.domain.allocationsystem.VenueService;
import alocaufsc.domain.entities.User;
import alocaufsc.entrypoint.DTO.VenueRequest;
import alocaufsc.entrypoint.DTO.VenueResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/venues")
@CrossOrigin(origins = "*") // Allows Flutter calls during local development
public class VenueController {

    private final VenueService venueService;
    private final AuthenticatedUserResolver userResolver;

    public VenueController(VenueService venueService, AuthenticatedUserResolver userResolver) {
        this.venueService = venueService;
        this.userResolver = userResolver;
    }

    @GetMapping
    public List<VenueResponse> getAllVenues(@RequestHeader(value = "Authorization", required = false) String authorization) {
        userResolver.resolve(authorization);
        return venueService.getAllVenues().stream().map(VenueResponse::from).toList();
    }

    // Centros da UFSC e prédios sugeridos, para o cadastro e a navegação por pastas.
    @GetMapping("/campus")
    public List<UfscCampus.Center> getCampus(@RequestHeader(value = "Authorization", required = false) String authorization) {
        userResolver.resolve(authorization);
        return venueService.getCampus();
    }

    @GetMapping("/{id}")
    public VenueResponse getVenue(@RequestHeader(value = "Authorization", required = false) String authorization,
                                  @PathVariable String id) {
        userResolver.resolve(authorization);
        return VenueResponse.from(venueService.getVenue(id));
    }

    @PostMapping
    public ResponseEntity<VenueResponse> createVenue(@RequestHeader(value = "Authorization", required = false) String authorization,
                                                     @RequestBody VenueRequest request) {
        User admin = userResolver.resolve(authorization);
        VenueResponse response = VenueResponse.from(venueService.createVenue(admin, toVenueInfo(request)));
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    public VenueResponse updateVenue(@RequestHeader(value = "Authorization", required = false) String authorization,
                                     @PathVariable String id,
                                     @RequestBody VenueRequest request) {
        User admin = userResolver.resolve(authorization);
        return VenueResponse.from(venueService.updateVenue(admin, id, toVenueInfo(request)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteVenue(@RequestHeader(value = "Authorization", required = false) String authorization,
                                            @PathVariable String id) {
        User admin = userResolver.resolve(authorization);
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
