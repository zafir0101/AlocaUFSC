package alocaufsc.technicalservices.authentication;

import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.UUID;

@Service
public class JwtService {

    // Simulação simplificada de geração de tokens JWT e Refresh Tokens
    public String generateAccessToken(String email, String role) {
        return "access_token_" + UUID.randomUUID() + "_" + email;
    }

    public String generateRefreshToken(String email) {
        return "refresh_token_" + UUID.randomUUID();
    }
}