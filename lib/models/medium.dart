/// Rappresenta un medium (anime, manga, film, etc.)
class Medium {
  final int id;
  final String name;
  final String? description;

  Medium({
    required this.id,
    required this.name,
    this.description,
  });

  factory Medium.fromMap(Map<String, dynamic> map) {
    return Medium(
      id: map['medium_id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medium_id': id,
      'name': name,
      'description': description,
    };
  }
}