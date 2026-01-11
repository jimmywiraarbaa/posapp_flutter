import '../entities/sale.dart';

abstract class TransactionRepository {
  Future<void> createSale(SaleTransaction transaction);
}
