import 'package:drift/drift.dart';

import '../../../../core/db/app_database.dart' as db;
import '../../domain/entities/product.dart';

Product productFromDb(db.Product data) {
  return Product(
    id: data.id,
    name: data.name,
    categoryId: data.categoryId,
    unitId: data.unitId,
    price: data.price,
    stockQty: data.stockQty,
    minStock: data.minStock,
    isActive: data.isActive,
    createdAt: DateTime.parse(data.createdAt),
    updatedAt: DateTime.parse(data.updatedAt),
  );
}

db.ProductsCompanion productToCompanion(Product product) {
  return db.ProductsCompanion(
    id: Value(product.id),
    name: Value(product.name),
    categoryId: Value(product.categoryId),
    unitId: Value(product.unitId),
    price: Value(product.price),
    stockQty: Value(product.stockQty),
    minStock: Value(product.minStock),
    isActive: Value(product.isActive),
    createdAt: Value(product.createdAt.toIso8601String()),
    updatedAt: Value(product.updatedAt.toIso8601String()),
  );
}
