class Venue {
  String? id;
  String name;
  String location;
  int capacity;
  String description;

  Venue({
    this.id,
    required this.name,
    required this.location,
    required this.capacity,
    required this.description,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'],
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      capacity: json['capacity'] ?? 0,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'capacity': capacity,
      'description': description,
    };
  }
}