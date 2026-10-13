package alocaufsc.entrypoint;

import alocaufsc.domain.authenticationservices.AuthService;
import alocaufsc.domain.entities.User;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

// Transforma o header "Authorization: Bearer <token>" no usuário logado.
// Ponto único da autenticação provisória: ao implementar o token definitivo, basta trocar este método.
@Component
public class AuthenticatedUserResolver {
    private static final String BEARER_PREFIX = "Bearer ";

    private final AuthService authService;

    public AuthenticatedUserResolver(AuthService authService) {
        this.authService = authService;
    }

    public User resolve(String authorization) {
        String token = authorization != null && authorization.startsWith(BEARER_PREFIX)
                ? authorization.substring(BEARER_PREFIX.length())
                : null;
        return authService.findUserByAccessToken(token)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Sessão inválida. Faça login novamente."));
    }
}
