import 'package:flutter/material.dart';

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

  /// Ottiene il colore associato al medium
  Color getColor() {
    switch (name.toLowerCase()) {
      case 'anime':
        return const Color(0xFFFF00FF); // Fucsia neon
      case 'manga':
        return const Color(0xFFFF0000); // Rosso brillante
      case 'fumetti':
      case 'comics':
        return const Color(0xFF0080FF); // Blu elettrico
      case 'videogiochi':
      case 'giochi':
      case 'games':
        return const Color(0xFFFFD700); // Giallo oro
      case 'film':
      case 'movies':
        return const Color(0xFF9400D3); // Viola neon
      case 'serie tv':
      case 'tv series':
        return const Color(0xFF00FF7F); // Verde menta
      case 'libri':
      case 'books':
        return const Color(0xFF8B4513); // Marrone vivido
      default:
        return Colors.purple; // Colore default
    }
  }

  /// Ottiene l'ordine di visualizzazione del medium
  int getDisplayOrder() {
    switch (name.toLowerCase()) {
      case 'anime':
        return 1;
      case 'manga':
        return 2;
      case 'fumetti':
      case 'comics':
        return 3;
      case 'videogiochi':
      case 'giochi':
      case 'games':
        return 4;
      case 'film':
      case 'movies':
        return 5;
      case 'serie tv':
      case 'tv series':
        return 6;
      case 'libri':
      case 'books':
        return 7;
      default:
        return 99; // In fondo se non riconosciuto
    }
  }
}