class Unit {
  const Unit({
    required this.id,
    required this.name,
    required this.symbol,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String symbol;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Unit copyWith({
    String? id,
    String? name,
    String? symbol,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Unit(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
