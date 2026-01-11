import '../../domain/entities/sale.dart';
import '../../domain/entities/transaction_record.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_data_source.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._localDataSource);

  final TransactionLocalDataSource _localDataSource;

  @override
  Future<void> createSale(SaleTransaction transaction) {
    return _localDataSource.createSale(transaction);
  }

  @override
  Stream<List<TransactionRecord>> watchAll({bool includeVoid = false}) {
    return _localDataSource.watchAll(includeVoid: includeVoid);
  }
}
