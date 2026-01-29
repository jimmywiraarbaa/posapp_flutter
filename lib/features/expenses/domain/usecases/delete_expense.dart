import '../repositories/expense_repository.dart';

class DeleteExpense {
  DeleteExpense(this._repository);

  final ExpenseRepository _repository;

  Future<void> call(String id) {
    return _repository.deleteById(id);
  }
}
