import '../repositories/transaction_repository.dart';

class VoidTransaction {
  VoidTransaction(this._repository);

  final TransactionRepository _repository;

  Future<void> call(String transactionId) {
    return _repository.voidTransaction(transactionId);
  }
}
