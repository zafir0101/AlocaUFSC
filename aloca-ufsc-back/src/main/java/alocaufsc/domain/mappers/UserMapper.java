package alocaufsc.domain.mappers;

import alocaufsc.domain.entities.Entity;
import alocaufsc.domain.entities.User;
import alocaufsc.entrypoint.DTO.UserDto;

import java.util.UUID;

public class UserMapper {
   public static UserDto toDto(User user) {
       return new UserDto(user.getFullName(), user.getEmail(), user.getPassword(), user.getEntity());
   }

   public static User toEntity(UserDto userDto) {
       String role = (userDto.entity() == Entity.MANAGER) ? "ADMIN" : "USER";
       return new User(UUID.randomUUID().toString(), userDto.fullName(),
               userDto.email(), userDto.password(), userDto.entity(), role);
   }
}
