import 'universe.dart';
import 'medium.dart';

/// Rappresenta un'opera (film, serie, anime, etc.)
class Opera {
  final int id;
  final String name;
  final int universeId;
  final int mediumId;
  final String? description;
  final int? year;

  // Relazioni opzionali
  Universe? universe;
  Medium? medium;

  Opera({
    required this.id,
    required this.name,
    required this.universeId,
    required this.mediumId,
    this.description,
    this.year,
    this.universe,
    this.medium,
  });

  factory Opera.fromMap(Map<String, dynamic> map) {
    return Opera(
      id: map['opera_id'] as int,
      name: map['name'] as String,
      universeId: map['universe_id'] as int,
      mediumId: map['medium_id'] as int,
      description: map['description'] as String?,
      year: map['year'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'opera_id': id,
      'name': name,
      'universe_id': universeId,
      'medium_id': mediumId,
      'description': description,
      'year': year,
    };
  }
}