import 'package:drift/drift.dart';

import '../../../../core/db/app_database.dart' as db;
import '../../domain/entities/category.dart';

Category categoryFromDb(db.Category data) {
  return Category(
    id: data.id,
    name: data.name,
    isActive: data.isActive,
    createdAt: DateTime.parse(data.createdAt),
    updatedAt: DateTime.parse(data.updatedAt),
  );
}

db.CategoriesCompanion categoryToCompanion(Category category) {
  return db.CategoriesCompanion(
    id: Value(category.id),
    name: Value(category.name),
    isActive: Value(category.isActive),
    createdAt: Value(category.createdAt.toIso8601String()),
    updatedAt: Value(category.updatedAt.toIso8601String()),
  );
}
