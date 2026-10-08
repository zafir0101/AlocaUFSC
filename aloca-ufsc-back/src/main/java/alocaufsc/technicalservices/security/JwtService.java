package alocaufsc.technicalservices.security;

import alocaufsc.domain.entities.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Service;

import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Service
public class JwtService {
    private String secretKey = "";

    private static final int REFRESH_TOKEN_EXP_TIME = 518000000;
    private static final int ACCESS_TOKEN_EXP_TIME = 6000000;
    private static final String BEARER_PREFIX = "Bearer ";

    public JwtService() throws NoSuchAlgorithmException {
        KeyGenerator keyGenerator = KeyGenerator.getInstance("HmacSHA256");
        SecretKey secretKey1 = keyGenerator.generateKey();
        secretKey = Base64.getEncoder().encodeToString(secretKey1.getEncoded());
    }

    public String getTokenFromBody(String body) {
        return body != null && body.startsWith(BEARER_PREFIX)
        ? body.substring(BEARER_PREFIX.length())
        : null;
    }

    public String generateToken(String email, boolean isRefreshToken) {
        int expTime = isRefreshToken ? REFRESH_TOKEN_EXP_TIME : ACCESS_TOKEN_EXP_TIME;
        Map<String, Object> claims = new HashMap<>();
        return Jwts.builder()
                .claims()
                .add(claims)
                .subject(email)
                .issuedAt(new Date(System.currentTimeMillis()))
                .expiration(new Date(System.currentTimeMillis() + expTime))
                .and()
                .signWith(getKey())
                .compact();
    }

    public boolean isTokenValid(String jwtToken) {
        return (!isTokenExpired(jwtToken));
    }

    private boolean isTokenExpired(String jwtToken) {
        return (extractExpiration(jwtToken).before(new Date()));
    }

    private Date extractExpiration(String jwtToken) {
        return extractClaim(jwtToken, Claims::getExpiration);
    }

    public String extractSubject(String jwtToken) {
        return extractClaim(jwtToken, Claims::getSubject);
    }

    private <T> T extractClaim(String jwtToken, Function<Claims, T> claimResolver) {
        final Claims claims = extractAllClaims(jwtToken);
        return claimResolver.apply(claims);
    }

    private Claims extractAllClaims(String jwtToken) {
        return Jwts.parser()
                .verifyWith(getKey())
                .build()
                .parseSignedClaims(jwtToken)
                .getPayload();
    }

    private SecretKey getKey() {
        byte[] keyValue = Decoders.BASE64.decode(secretKey);
        return Keys.hmacShaKeyFor(keyValue);
    }
}
