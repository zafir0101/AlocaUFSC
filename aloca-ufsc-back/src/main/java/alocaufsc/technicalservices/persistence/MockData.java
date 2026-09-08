package alocaufsc.technicalservices.persistence;

import alocaufsc.domain.entities.User;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class MockData {
    private final Map<String, User> usersByEmail = new ConcurrentHashMap<>();
    private final Map<String, String> refreshTokens = new ConcurrentHashMap<>(); // RefreshToken -> Email

    public void saveUser(User user) {
        usersByEmail.put(user.getEmail().toLowerCase(), user);
    }

    public Optional<User> findByEmail(String email) {
        return Optional.ofNullable(usersByEmail.get(email.toLowerCase()));
    }

    public boolean existsByEmail(String email) {
        return usersByEmail.containsKey(email.toLowerCase());
    }

    public void saveRefreshToken(String token, String email) {
        refreshTokens.put(token, email);
    }

    public Optional<String> getEmailByRefreshToken(String token) {
        return Optional.ofNullable(refreshTokens.get(token));
    }

    public void removeRefreshToken(String token) {
        refreshTokens.remove(token);
    }

    public Map<String, User> getUsersByEmail() {
        return usersByEmail;
    }
}