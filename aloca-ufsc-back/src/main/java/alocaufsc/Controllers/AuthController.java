package alocaufsc.Controllers;

import alocaufsc.Controllers.DTO.*;
import alocaufsc.technicalservices.authentication.AuthService;
import alocaufsc.technicalservices.persistence.FacadeDbRest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;
    private final FacadeDbRest facadeDbRest;

    public AuthController(AuthService authService, FacadeDbRest facadeDbRest) {
        this.authService = authService;
        this.facadeDbRest = facadeDbRest;
    }

    @PostMapping("/cadastro")
    public ResponseEntity<?> cadastrar(@RequestBody CadastroRequest request) {
        try {
            AuthResponse response = authService.cadastrar(request);
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
            AuthResponse response = authService.refreshToken(request);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("mensagem", e.getMessage()));
        }
    }

    @GetMapping("/debug")
    public ResponseEntity<?> listarUsuarios() {
        return ResponseEntity.ok(facadeDbRest.findAllUsers());
    }
}