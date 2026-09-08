package alocaufsc.domain.entities;

public class User {
    private String id;
    private String nomeCompleto;
    private String email;
    private String senha;
    private Entity entity;

    public User() {}

    public User(String id, String nomeCompleto, String email, String senha, Entity entity) {
        this.id = id;
        this.nomeCompleto = nomeCompleto;
        this.email = email;
        this.senha = senha;
        this.entity = entity;
    }

    // Getters e Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getNomeCompleto() { return nomeCompleto; }
    public void setNomeCompleto(String nomeCompleto) { this.nomeCompleto = nomeCompleto; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getSenha() { return senha; }
    public void setSenha(String senha) { this.senha = senha; }
    public Entity getTipoPerfil() { return entity; }
    public void setTipoPerfil(Entity tipoPerfil) { this.entity = tipoPerfil; }
}