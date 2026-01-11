import 'package:drift/drift.dart';

import '../../../../core/db/app_database.dart' as db;
import '../../../../core/utils/id_generator.dart';

class StockLocalDataSource {
  StockLocalDataSource(this._db);

  final db.AppDatabase _db;

  Future<void> addStockIn({
    required String productId,
    required double qty,
    String? note,
  }) async {
    final product = await _getProduct(productId);
    if (product == null) {
      throw StateError('Produk tidak ditemukan.');
    }

    final now = DateTime.now().toIso8601String();
    final updatedStock = product.stockQty + qty;

    await _db.transaction(() async {
      await _db.into(_db.stockMovements).insert(
            db.StockMovementsCompanion(
              id: Value(generateId()),
              productId: Value(productId),
              type: const Value('in'),
              qty: Value(qty),
              refId: const Value<String?>(null),
              note: Value(note),
              createdAt: Value(now),
            ),
          );
      await (_db.update(_db.products)..where((tbl) => tbl.id.equals(productId)))
          .write(
        db.ProductsCompanion(
          stockQty: Value(updatedStock),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<void> adjustStock({
    required String productId,
    required double qty,
    required bool increase,
    required String note,
  }) async {
    final product = await _getProduct(productId);
    if (product == null) {
      throw StateError('Produk tidak ditemukan.');
    }

    if (!increase && product.stockQty < qty) {
      throw StateError('Stok tidak mencukupi.');
    }

    final now = DateTime.now().toIso8601String();
    final updatedStock = increase ? product.stockQty + qty : product.stockQty - qty;
    final movementQty = increase ? qty : -qty;

    await _db.transaction(() async {
      await _db.into(_db.stockMovements).insert(
            db.StockMovementsCompanion(
              id: Value(generateId()),
              productId: Value(productId),
              type: const Value('adjust'),
              qty: Value(movementQty),
              refId: const Value<String?>(null),
              note: Value(note),
              createdAt: Value(now),
            ),
          );
      await (_db.update(_db.products)..where((tbl) => tbl.id.equals(productId)))
          .write(
        db.ProductsCompanion(
          stockQty: Value(updatedStock),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<db.Product?> _getProduct(String productId) {
    final query = _db.select(_db.products)
      ..where((tbl) => tbl.id.equals(productId));
    return query.getSingleOrNull();
  }
}
