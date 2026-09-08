package alocaufsc.domain.allocationsystem;

public class Venue {
    private String id;
    private String name;
    private String location;
    private int capacity;
    private String description;

    public Venue() {}

    public Venue(String id, String name, String location, int capacity, String description) {
        this.id = id;
        this.name = name;
        this.location = location;
        this.capacity = capacity;
        this.description = description;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}