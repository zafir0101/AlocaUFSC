// Perfis que podem usar um espaço, na ordem em que aparecem na tela.
const Map<String, String> venueRoleLabels = {
  'DISCENTE': 'Discente',
  'DOCENTE': 'Docente',
  'ORGANIZACAO': 'Organização',
  'ADMINISTRADOR': 'Administrador',
};

// Código do centro usado para espaços fora dos centros da lista (ex.: BU, RU).
const String otherCenterCode = 'OUTRO';

class Venue {
  final String? id;
  final String code;
  final String name;
  final String center;
  final String building;
  // Montada pelo backend a partir do centro e do prédio (ex.: "CTC - INE - Informática e Estatística").
  final String location;
  final int capacity;
  final String description;
  final List<String> allowedRoles;

  Venue({
    this.id,
    required this.code,
    required this.name,
    required this.center,
    required this.building,
    this.location = '',
    required this.capacity,
    required this.description,
    required this.allowedRoles,
  });

  String get allowedRolesLabel =>
      venueRoleLabels.keys.where(allowedRoles.contains).map((r) => venueRoleLabels[r]).join(', ');

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'],
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      center: json['center'] ?? '',
      building: json['building'] ?? '',
      location: json['location'] ?? '',
      capacity: json['capacity'] ?? 0,
      description: json['description'] ?? '',
      allowedRoles: List<String>.from(json['allowedRoles'] ?? const []),
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'center': center,
      'building': building,
      'code': code,
      'name': name,
      'capacity': capacity,
      'description': description,
      'allowedRoles': allowedRoles,
    };
  }
}

class CampusCenter {
  final String code;
  final String name;
  final List<String> buildings;

  CampusCenter({required this.code, required this.name, required this.buildings});

  String get label => code == otherCenterCode ? name : '$code - $name';

  factory CampusCenter.fromJson(Map<String, dynamic> json) {
    return CampusCenter(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      buildings: List<String>.from(json['buildings'] ?? const []),
    );
  }
}
