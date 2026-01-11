import '../entities/transaction_item_record.dart';
import '../repositories/transaction_repository.dart';

class FetchTransactionItems {
  FetchTransactionItems(this._repository);

  final TransactionRepository _repository;

  Future<List<TransactionItemRecord>> call(String transactionId) {
    return _repository.fetchItems(transactionId);
  }
}
