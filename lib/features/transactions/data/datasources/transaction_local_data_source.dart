import 'package:drift/drift.dart';

import '../../../../core/db/app_database.dart' as db;
import '../../../../core/utils/id_generator.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/transaction_record.dart';

class TransactionLocalDataSource {
  TransactionLocalDataSource(this._db);

  final db.AppDatabase _db;

  Future<void> createSale(SaleTransaction transaction) async {
    final productIds = transaction.items.map((item) => item.productId).toSet();
    final products = await (_db.select(_db.products)
          ..where((tbl) => tbl.id.isIn(productIds.toList())))
        .get();
    final productById = {for (final product in products) product.id: product};

    for (final item in transaction.items) {
      final product = productById[item.productId];
      if (product == null) {
        throw StateError('Produk tidak ditemukan.');
      }
      if (product.stockQty < item.qty) {
        throw StateError('Stok tidak mencukupi untuk ${product.name}.');
      }
    }

    final createdAt = transaction.createdAt.toIso8601String();

    await _db.transaction(() async {
      await _db.into(_db.transactions).insert(
            db.TransactionsCompanion(
              id: Value(transaction.id),
              trxNumber: Value(transaction.trxNumber),
              total: Value(transaction.total),
              paidAmount: Value(transaction.paidAmount),
              changeAmount: Value(transaction.changeAmount),
              paymentMethod: Value(transaction.paymentMethod),
              status: Value(transaction.status),
              note: Value(transaction.note),
              createdAt: Value(createdAt),
            ),
          );

      for (final item in transaction.items) {
        await _db.into(_db.transactionItems).insert(
              db.TransactionItemsCompanion(
                id: Value(item.id ?? generateId()),
                transactionId: Value(transaction.id),
                productId: Value(item.productId),
                qty: Value(item.qty),
                price: Value(item.price),
                subtotal: Value(item.subtotal),
                note: Value(item.note),
              ),
            );

        await _db.into(_db.stockMovements).insert(
              db.StockMovementsCompanion(
                id: Value(generateId()),
                productId: Value(item.productId),
                type: const Value('out'),
                qty: Value(-item.qty),
                refId: Value(transaction.id),
                note: const Value<String?>(null),
                createdAt: Value(createdAt),
              ),
            );

        final product = productById[item.productId]!;
        final updatedStock = product.stockQty - item.qty;
        await (_db.update(_db.products)
              ..where((tbl) => tbl.id.equals(item.productId)))
            .write(
          db.ProductsCompanion(
            stockQty: Value(updatedStock),
            updatedAt: Value(createdAt),
          ),
        );
      }
    });
  }

  Stream<List<TransactionRecord>> watchAll({bool includeVoid = false}) {
    final query = _db.select(_db.transactions)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
      ]);
    if (!includeVoid) {
      query.where((tbl) => tbl.status.equals('completed'));
    }
    return query.watch().map(
          (rows) => rows.map(_mapRecord).toList(),
        );
  }

  TransactionRecord _mapRecord(db.Transaction data) {
    return TransactionRecord(
      id: data.id,
      trxNumber: data.trxNumber,
      total: data.total,
      paymentMethod: data.paymentMethod,
      status: data.status,
      createdAt: DateTime.parse(data.createdAt),
    );
  }
}
