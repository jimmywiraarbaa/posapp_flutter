import 'package:drift/drift.dart';

import '../../../../core/db/app_database.dart' as db;
import '../../../../core/utils/id_generator.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/transaction_item_record.dart';
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
    final stockById = {
      for (final product in products) product.id: product.stockQty,
    };

    for (final item in transaction.items) {
      final product = productById[item.productId];
      if (product == null) {
        throw StateError('Produk tidak ditemukan.');
      }
      final currentStock = stockById[item.productId] ?? 0;
      if (currentStock < item.qty) {
        throw StateError('Stok tidak mencukupi untuk ${product.name}.');
      }
      stockById[item.productId] = currentStock - item.qty;
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

        final updatedStock = stockById[item.productId]!;
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
      paidAmount: data.paidAmount,
      changeAmount: data.changeAmount,
      paymentMethod: data.paymentMethod,
      status: data.status,
      createdAt: DateTime.parse(data.createdAt),
    );
  }

  Future<List<TransactionItemRecord>> fetchItems(String transactionId) async {
    final items = await (_db.select(_db.transactionItems)
          ..where((tbl) => tbl.transactionId.equals(transactionId)))
        .get();
    if (items.isEmpty) {
      return [];
    }
    final productIds = items.map((item) => item.productId).toSet().toList();
    final products = await (_db.select(_db.products)
          ..where((tbl) => tbl.id.isIn(productIds)))
        .get();
    final productById = {for (final product in products) product.id: product};

    return items
        .map(
          (item) => TransactionItemRecord(
            id: item.id,
            productId: item.productId,
            productName: productById[item.productId]?.name ?? '-',
            qty: item.qty,
            price: item.price,
            subtotal: item.subtotal,
            note: item.note,
          ),
        )
        .toList();
  }

  Future<void> voidTransaction(String transactionId) async {
    final trxQuery = _db.select(_db.transactions)
      ..where((tbl) => tbl.id.equals(transactionId));
    final trx = await trxQuery.getSingleOrNull();
    if (trx == null) {
      throw StateError('Transaksi tidak ditemukan.');
    }
    if (trx.status == 'void') {
      throw StateError('Transaksi sudah dibatalkan.');
    }

    final items = await (_db.select(_db.transactionItems)
          ..where((tbl) => tbl.transactionId.equals(transactionId)))
        .get();
    if (items.isEmpty) {
      throw StateError('Item transaksi tidak ditemukan.');
    }

    final productIds = items.map((item) => item.productId).toSet();
    final products = await (_db.select(_db.products)
          ..where((tbl) => tbl.id.isIn(productIds.toList())))
        .get();
    final stockById = {
      for (final product in products) product.id: product.stockQty,
    };
    final productNameById = {
      for (final product in products) product.id: product.name,
    };

    for (final item in items) {
      final currentStock = stockById[item.productId];
      if (currentStock == null) {
        final name = productNameById[item.productId] ?? item.productId;
        throw StateError('Produk $name tidak ditemukan.');
      }
      stockById[item.productId] = currentStock + item.qty;
    }

    final now = DateTime.now().toIso8601String();

    await _db.transaction(() async {
      await (_db.update(_db.transactions)
            ..where((tbl) => tbl.id.equals(transactionId)))
          .write(const db.TransactionsCompanion(status: Value('void')));

      for (final item in items) {
        await _db.into(_db.stockMovements).insert(
              db.StockMovementsCompanion(
                id: Value(generateId()),
                productId: Value(item.productId),
                type: const Value('void'),
                qty: Value(item.qty),
                refId: Value(transactionId),
                note: const Value<String?>(null),
                createdAt: Value(now),
              ),
            );

        final updatedStock = stockById[item.productId]!;
        await (_db.update(_db.products)
              ..where((tbl) => tbl.id.equals(item.productId)))
            .write(
          db.ProductsCompanion(
            stockQty: Value(updatedStock),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }
}
