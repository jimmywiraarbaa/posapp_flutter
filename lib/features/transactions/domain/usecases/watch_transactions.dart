import '../entities/transaction_record.dart';
import '../repositories/transaction_repository.dart';

class WatchTransactions {
  WatchTransactions(this._repository);

  final TransactionRepository _repository;

  Stream<List<TransactionRecord>> call({bool includeVoid = false}) {
    return _repository.watchAll(includeVoid: includeVoid);
  }
}
