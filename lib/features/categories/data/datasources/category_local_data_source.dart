import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart' as db;
import '../../domain/entities/category.dart';
import '../mappers/category_mapper.dart';

class CategoryLocalDataSource {
  CategoryLocalDataSource(this._db);

  final db.AppDatabase _db;

  Stream<List<Category>> watchAll({bool includeInactive = false}) {
    final query = _db.select(_db.categories);
    if (!includeInactive) {
      query.where((tbl) => tbl.isActive.equals(true));
    }
    return query.watch().map((rows) => rows.map(categoryFromDb).toList());
  }

  Future<List<Category>> fetchAll({bool includeInactive = false}) async {
    final query = _db.select(_db.categories);
    if (!includeInactive) {
      query.where((tbl) => tbl.isActive.equals(true));
    }
    final rows = await query.get();
    return rows.map(categoryFromDb).toList();
  }

  Future<Category?> getById(String id) async {
    final query = _db.select(_db.categories)..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return categoryFromDb(row);
  }

  Future<void> upsert(Category category) async {
    await _db.into(_db.categories).insertOnConflictUpdate(
          categoryToCompanion(category),
        );
  }

  Future<void> setActive(String id, bool isActive) async {
    final now = DateTime.now().toIso8601String();
    await (_db.update(_db.categories)..where((tbl) => tbl.id.equals(id))).write(
      db.CategoriesCompanion(
        isActive: Value(isActive),
        updatedAt: Value(now),
      ),
    );
  }
}
