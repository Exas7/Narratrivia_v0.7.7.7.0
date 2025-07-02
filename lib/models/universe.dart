/// Rappresenta un universo narrativo
class Universe {
  final int id;
  final int mediumId;
  final String name;
  final String? description;

  Universe({
    required this.id,
    required this.mediumId,
    required this.name,
    this.description,
  });

  factory Universe.fromMap(Map<String, dynamic> map) {
    return Universe(
      id: map['universe_id'] as int,
      mediumId: map['medium_id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'universe_id': id,
      'medium_id': mediumId,
      'name': name,
      'description': description,
    };
  }
}