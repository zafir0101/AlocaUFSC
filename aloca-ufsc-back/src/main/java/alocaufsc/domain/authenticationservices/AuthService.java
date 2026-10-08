package alocaufsc.domain.authenticationservices;

import alocaufsc.domain.entities.User;
import alocaufsc.entrypoint.DTO.*;
import alocaufsc.entrypoint.DTO.UserDto;
import alocaufsc.technicalservices.persistence.*;
import alocaufsc.technicalservices.security.JwtService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;


import java.util.Optional;

import static alocaufsc.domain.mappers.UserMapper.toEntity;

@Service
public class AuthService {
    @Autowired
    private final FacadeDbRest facadeDbRest;

    @Autowired
    public PasswordEncoder passwordEncoder;

    @Autowired
    public JwtService jwtService;

    public AuthService(FacadeDbRest facadeDbRest) {
        this.facadeDbRest = facadeDbRest;
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

    public AuthResponse login(LoginRequest request) throws IllegalArgumentException {
        User user = facadeDbRest.findUserByEmail(request.email())
                .orElseThrow(() -> new IllegalArgumentException("Usuário ou senha inválidos."));

        if (!passwordEncoder.matches(request.password(), user.getPassword()))
            throw new IllegalArgumentException("Usuário ou senha inválidos");
        return generateTokens(user);
    }

    public AuthResponse getNewAccessToken(RefreshTokenRequest request) {
        User user = facadeDbRest.findUserbyRefreshToken(request.refreshToken())
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado."));

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