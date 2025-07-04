class Badge {
  final int badgeId;
  final String internalName;
  final String iconEmoji;
  final String category;
  final String rarity;
  final int sortOrder;

  Badge({
    required this.badgeId,
    required this.internalName,
    required this.iconEmoji,
    required this.category,
    required this.rarity,
    this.sortOrder = 0,
  });

  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      badgeId: map['badge_id'] as int,
      internalName: map['internal_name'] as String,
      iconEmoji: map['icon_emoji'] as String,
      category: map['category'] as String,
      rarity: map['rarity'] as String,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  // Getter per colore rarità
  int get rarityColor {
    switch (rarity) {
      case 'bronze':
        return 0xFFCD7F32;  // Bronzo
      case 'silver':
        return 0xFFC0C0C0;  // Argento
      case 'gold':
        return 0xFFFFD700;  // Oro
      case 'platinum':
        return 0xFFE5E4E2;  // Platino
      default:
        return 0xFF808080;  // Grigio default
    }
  }
}