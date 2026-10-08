enum Entity { student, professor, organization, manager }

extension EntityInfo on Entity {
String get label {
    switch (this) {
        case Entity.student:
            return 'Discente';
        case Entity.professor:
            return 'Docente';
        case Entity.organization:
            return 'Organização';
        case Entity.manager:
            return 'Administrador';
    }
}
}

typedef AccessToken = String;
typedef RefreshToken = String;

class LoginRequest {
    final String email;
    final String password;

    LoginRequest({required this.email, required this.password});

    Map<String, dynamic> toJson() {
        return {
            'email': email,
            'senha': password,
        };
    }
}

class SignUpRequest {
    final String fullName;
    final String email;
    final String password;
    final String entity;
    final String id;

    SignUpRequest({
        required this.fullName,
        required this.email,
        required this.password,
        required this.entity,
        required this.id,
    });

    Map<String, dynamic> toJson() {
        return {
            'nomeCompleto': fullName,
            'email': email,
            'senha': password,
            'entity': entity,
            'identificador': id,
        };
    }
}

class AuthInfo {
    final String? accessToken;
    final String? refreshToken;
    final String? id;
    final String? entity;

    AuthInfo({
        this.accessToken,
        this.refreshToken,
        this.id,
        this.entity,
    });

    factory AuthInfo.fromJson(Map<String, dynamic> json) {
        return AuthInfo(
            accessToken: json['token'],
            refreshToken: json['refreshToken'],
            entity: json['tipoPerfil'],
        );
    }
}

