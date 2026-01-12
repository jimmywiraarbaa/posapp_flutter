class Product {
  const Product({
    required this.id,
    required this.name,
    this.imagePath,
    required this.categoryId,
    required this.unitId,
    required this.price,
    required this.stockQty,
    required this.minStock,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? imagePath;
  final String categoryId;
  final String unitId;
  final int price;
  final double stockQty;
  final double minStock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product copyWith({
    String? id,
    String? name,
    String? imagePath,
    String? categoryId,
    String? unitId,
    int? price,
    double? stockQty,
    double? minStock,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      categoryId: categoryId ?? this.categoryId,
      unitId: unitId ?? this.unitId,
      price: price ?? this.price,
      stockQty: stockQty ?? this.stockQty,
      minStock: minStock ?? this.minStock,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
