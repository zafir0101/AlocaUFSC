package alocaufsc.technicalservices.authentication;

import alocaufsc.controllers.DTO.AuthResponse;
import alocaufsc.controllers.DTO.CadastroRequest;
import alocaufsc.controllers.DTO.LoginRequest;
import alocaufsc.controllers.DTO.RefreshTokenRequest;
import alocaufsc.domain.entities.*;
import alocaufsc.technicalservices.persistence.*;
import org.apache.el.parser.Token;
import org.springframework.stereotype.Service;

import java.util.UUID;

import static alocaufsc.domain.entities.Entity.*;

@Service
public class AuthService {

    private final FacadeDbRest facadeDbRest;
    private final TokenService tokenService;

    public AuthService(FacadeDbRest facadeDbRest, TokenService tokenService) {
        this.facadeDbRest = facadeDbRest;
        this.tokenService = tokenService;
    }

    public AuthResponse cadastrar(CadastroRequest request) {
        if (facadeDbRest.existsByEmail(request.email())) {
            throw new IllegalArgumentException("E-mail já cadastrado.");
        }

        String id = UUID.randomUUID().toString();
        User usuario = switch (request.entity()) {
            case DISCENTE -> new User(id, request.nomeCompleto(), request.email(), request.senha(), DISCENTE);
            case DOCENTE -> new User(id, request.nomeCompleto(), request.email(), request.senha(), DOCENTE);
            case ORGANIZACAO -> new User(id, request.nomeCompleto(), request.email(), request.senha(), ORGANIZACAO);
            case ADMINISTRADOR -> new User(id, request.nomeCompleto(), request.email(), request.senha(), ADMINISTRADOR);
        };

        facadeDbRest.save(usuario);

        return gerarTokens(usuario);
    }

    public AuthResponse login(LoginRequest request) {
        User usuario = facadeDbRest.findByEmail(request.email())
                .orElseThrow(() -> new IllegalArgumentException("Usuário ou senha inválidos."));

        if (!usuario.getSenha().equals(request.senha())) {
            throw new IllegalArgumentException("Usuário ou senha inválidos.");
        }

        return gerarTokens(usuario);
    }

    public AuthResponse refreshToken(RefreshTokenRequest request) {
        String email = facadeDbRest.findEmailByRefreshToken(request.refreshToken())
                .orElseThrow(() -> new IllegalArgumentException("Refresh token inválido ou expirado."));

        User usuario = facadeDbRest.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado."));

        facadeDbRest.deleteRefreshToken(request.refreshToken());
        return gerarTokens(usuario);
    }

    private AuthResponse gerarTokens(User usuario) {
        String accessToken = tokenService.generateAccessToken(usuario.getEmail(), usuario.getTipoPerfil().name());
        String refreshToken = tokenService.generateRefreshToken(usuario.getEmail());

        facadeDbRest.saveRefreshToken(refreshToken, usuario.getEmail());

        return new AuthResponse(
                accessToken,
                refreshToken,
                usuario.getTipoPerfil().name(),
                usuario.getNomeCompleto()
        );
    }
}