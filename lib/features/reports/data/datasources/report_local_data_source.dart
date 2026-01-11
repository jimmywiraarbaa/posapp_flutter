import 'package:drift/drift.dart';

import '../../../../core/db/app_database.dart' as db;
import '../../domain/entities/top_product.dart';

class ReportLocalDataSource {
  ReportLocalDataSource(this._db);

  final db.AppDatabase _db;

  Future<List<TopProduct>> fetchTopProducts({
    required DateTime start,
    required DateTime end,
    int limit = 5,
  }) async {
    final startIso = start.toIso8601String();
    final endIso = end.toIso8601String();

    final qtySum = _db.transactionItems.qty.sum();
    final totalSum = _db.transactionItems.subtotal.sum();

    final query = _db.select(_db.transactionItems).join([
      innerJoin(
        _db.transactions,
        _db.transactions.id.equalsExp(_db.transactionItems.transactionId),
      ),
      innerJoin(
        _db.products,
        _db.products.id.equalsExp(_db.transactionItems.productId),
      ),
    ])
      ..where(_db.transactions.status.equals('completed'))
      ..where(_db.transactions.createdAt.isBetweenValues(startIso, endIso))
      ..addColumns([qtySum, totalSum, _db.products.name])
      ..groupBy([
        _db.transactionItems.productId,
        _db.products.name,
      ])
      ..orderBy([
        OrderingTerm(expression: totalSum, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    final rows = await query.get();
    return rows
        .map(
          (row) => TopProduct(
            productId: row.read(_db.transactionItems.productId)!,
            name: row.read(_db.products.name)!,
            qty: row.read(qtySum) ?? 0,
            total: row.read(totalSum) ?? 0,
          ),
        )
        .toList();
  }
}
