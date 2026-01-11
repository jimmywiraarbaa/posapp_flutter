import '../entities/sale.dart';
import '../entities/transaction_record.dart';

abstract class TransactionRepository {
  Future<void> createSale(SaleTransaction transaction);

  Stream<List<TransactionRecord>> watchAll({bool includeVoid = false});
}
