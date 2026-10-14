package alocaufsc.domain.entities;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class User{
    private String id;
    private String fullName;
    private String email;
    private String password;
    private Entity entity;
    private String role;
}