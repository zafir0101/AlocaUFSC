package alocaufsc.technicalservices.authentication;

import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class TokenService {

    public String generateAccessToken(String email, String role) {
        return "access_token_" + UUID.randomUUID() + "_" + email;
    }

    public String generateRefreshToken(String email) {
        return "refresh_token_" + UUID.randomUUID();
    }
}