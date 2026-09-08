package alocaufsc.Controllers.DTO;

import alocaufsc.domain.entities.Entity;

public record CadastroRequest(
        String nomeCompleto,
        String email,
        String senha,
        Entity entity
        ) {}