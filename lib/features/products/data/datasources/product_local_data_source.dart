import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart' as db;
import '../../domain/entities/product.dart';
import '../mappers/product_mapper.dart';

class ProductLocalDataSource {
  ProductLocalDataSource(this._db);

  final db.AppDatabase _db;

  Stream<List<Product>> watchAll({bool includeInactive = false}) {
    final query = _db.select(_db.products);
    if (!includeInactive) {
      query.where((tbl) => tbl.isActive.equals(true));
    }
    return query.watch().map((rows) => rows.map(productFromDb).toList());
  }

  Future<List<Product>> fetchAll({bool includeInactive = false}) async {
    final query = _db.select(_db.products);
    if (!includeInactive) {
      query.where((tbl) => tbl.isActive.equals(true));
    }
    final rows = await query.get();
    return rows.map(productFromDb).toList();
  }

  Future<Product?> getById(String id) async {
    final query = _db.select(_db.products)..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return productFromDb(row);
  }

  Future<void> upsert(Product product) async {
    await _db.into(_db.products).insertOnConflictUpdate(
          productToCompanion(product),
        );
  }

  Future<void> setActive(String id, bool isActive) async {
    final now = DateTime.now().toIso8601String();
    await (_db.update(_db.products)..where((tbl) => tbl.id.equals(id))).write(
      db.ProductsCompanion(
        isActive: Value(isActive),
        updatedAt: Value(now),
      ),
    );
  }
}
