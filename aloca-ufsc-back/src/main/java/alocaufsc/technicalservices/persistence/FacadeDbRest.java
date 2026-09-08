package alocaufsc.technicalservices.persistence;

import alocaufsc.domain.entities.User;
import org.springframework.stereotype.Repository;

import java.util.Map;
import java.util.Optional;

@Repository
public class FacadeDbRest {
    private final MockData mockData;

    public FacadeDbRest(MockData mockData) {
        this.mockData = mockData;
    }

    public User save(User user) {
        mockData.saveUser(user);
        return user;
    }

    public Optional<User> findByEmail(String email) {
        return mockData.findByEmail(email);
    }

    public boolean existsByEmail(String email) {
        return mockData.existsByEmail(email);
    }

    public void saveRefreshToken(String refreshToken, String email) {
        mockData.saveRefreshToken(refreshToken, email);
    }

    public Optional<String> findEmailByRefreshToken(String refreshToken) {
        return mockData.getEmailByRefreshToken(refreshToken);
    }

    public void deleteRefreshToken(String refreshToken) {
        mockData.removeRefreshToken(refreshToken);
    }

    public Map<String, User> findAllUsers() {
        return mockData.getUsersByEmail();
    }
}