    package alocaufsc.entrypoint;

    import alocaufsc.entrypoint.DTO.*;
    import alocaufsc.domain.authenticationservices.AuthService;
    import org.springframework.http.HttpStatus;
    import org.springframework.http.ResponseEntity;
    import org.springframework.web.bind.annotation.*;

    import java.util.Map;

    @RestController
    @RequestMapping("/api/auth")
    @CrossOrigin(origins = "*")
    public class AuthController {

        private final AuthService authService;

        public AuthController(AuthService authService) {
            this.authService = authService;
        }

        @PostMapping("/register")
        public ResponseEntity<?> register(@RequestBody UserDto request) {
            try {
                AuthResponse response = authService.register(request);
                return ResponseEntity.status(HttpStatus.CREATED).body(response);
            } catch (IllegalArgumentException e) {
                return ResponseEntity.badRequest().body(Map.of("mensagem", e.getMessage()));
            }
        }

        @PostMapping("/login")
        public ResponseEntity<?> login(@RequestBody LoginRequest request) {
            try {
                AuthResponse response = authService.login(request);
                return ResponseEntity.ok(response);
            } catch (IllegalArgumentException e) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("mensagem", e.getMessage()));
            }
        }

        @PostMapping("/refresh")
        public ResponseEntity<?> refresh(@RequestBody RefreshTokenRequest request) {
            try {
                AuthResponse response = authService.getNewAccessToken(request);
                return ResponseEntity.ok(response);
            } catch (Exception e) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("mensagem", e.getMessage()));
            }
        }
    }