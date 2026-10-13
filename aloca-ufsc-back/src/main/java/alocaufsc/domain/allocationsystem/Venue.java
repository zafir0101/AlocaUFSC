package alocaufsc.domain.allocationsystem;

import alocaufsc.domain.entities.Entity;

import java.util.EnumSet;
import java.util.Set;

public class Venue {
    private String id;
    private String code;
    private String name;
    private String center;
    private String building;
    private int capacity;
    private String description;
    private Set<Entity> allowedRoles = EnumSet.noneOf(Entity.class);

    public Venue() {}

    public Venue(String id, String code, String name, String center, String building, int capacity, String description,
                 Set<Entity> allowedRoles) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.center = center;
        this.building = building;
        this.capacity = capacity;
        this.description = description;
        setAllowedRoles(allowedRoles);
    }

    public boolean allows(Entity role) {
        return allowedRoles.contains(role);
    }

    public String getLocation() {
        return UfscCampus.OTHER.equals(center) ? building : center + " - " + building;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCenter() { return center; }
    public void setCenter(String center) { this.center = center; }
    public String getBuilding() { return building; }
    public void setBuilding(String building) { this.building = building; }
    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Set<Entity> getAllowedRoles() { return allowedRoles; }
    public void setAllowedRoles(Set<Entity> allowedRoles) {
        this.allowedRoles = allowedRoles == null || allowedRoles.isEmpty()
                ? EnumSet.noneOf(Entity.class)
                : EnumSet.copyOf(allowedRoles);
    }
}
