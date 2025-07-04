class Title {
  final int titleId;
  final String internalName;
  final String unlockCondition;
  final int sortOrder;

  Title({
    required this.titleId,
    required this.internalName,
    required this.unlockCondition,
    this.sortOrder = 0,
  });

  factory Title.fromMap(Map<String, dynamic> map) {
    return Title(
      titleId: map['title_id'] as int,
      internalName: map['internal_name'] as String,
      unlockCondition: map['unlock_condition'] as String? ?? '',
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }
}