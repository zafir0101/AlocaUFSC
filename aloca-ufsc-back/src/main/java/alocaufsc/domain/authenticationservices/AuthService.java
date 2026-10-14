package alocaufsc.domain.authenticationservices;

import alocaufsc.domain.entities.User;
import alocaufsc.entrypoint.DTO.*;
import alocaufsc.technicalservices.persistence.FacadeDbRest;
import alocaufsc.technicalservices.security.JwtService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.server.authentication.InvalidateLeastUsedServerMaximumSessionsExceededHandler;
import org.springframework.stereotype.Service;

import static alocaufsc.domain.mappers.UserMapper.toEntity;

@Service
public class AuthService {

    private final FacadeDbRest facadeDbRest;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthService(FacadeDbRest facadeDbRest, PasswordEncoder passwordEncoder, JwtService jwtService) {
        this.facadeDbRest = facadeDbRest;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    public AuthResponse register(UserDto userDto) {
        if (facadeDbRest.existsByEmail(userDto.email())) {
            throw new IllegalArgumentException("E-mail já cadastrado.");
        }

        User user = toEntity(userDto);
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        facadeDbRest.save(user);

        return generateTokens(user);
    }

    public AuthResponse login(LoginRequest request) {
        User user = facadeDbRest.findUserByEmail(request.email())
                .orElseThrow(() -> new IllegalArgumentException("Usuário ou senha inválidos."));

        if (!passwordEncoder.matches(request.password(), user.getPassword())) {
            throw new IllegalArgumentException("Usuário ou senha inválidos.");
        }

        return generateTokens(user);
    }

    public AuthResponse getNewAccessToken(RefreshTokenRequest request) throws IllegalArgumentException {
        if (request.refreshToken().isBlank() || !jwtService.isTokenValid(request.refreshToken()))
            throw new IllegalArgumentException("Refresh Token Expirado");

        User user = facadeDbRest.findUserbyRefreshToken(request.refreshToken())
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado ou refresh token inválido."));

        String accessToken = jwtService.generateToken(user.getEmail(), false);
        facadeDbRest.saveAccessToken(accessToken, user.getEmail());

        return new AuthResponse(
                accessToken,
                request.refreshToken(),
                user.getEntity().name(),
                user.getFullName()
        );
    }

    private AuthResponse generateTokens(User user) {
        String accessToken = jwtService.generateToken(user.getEmail(), false);
        String refreshToken = jwtService.generateToken(user.getEmail(), true);

        facadeDbRest.saveAccessToken(accessToken, user.getEmail());
        facadeDbRest.saveRefreshToken(refreshToken, user.getEmail());

        return new AuthResponse(
                accessToken,
                refreshToken,
                user.getEntity().name(),
                user.getFullName()
        );
    }
}