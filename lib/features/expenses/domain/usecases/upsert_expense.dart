import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class UpsertExpense {
  UpsertExpense(this._repository);

  final ExpenseRepository _repository;

  Future<void> call(Expense expense) {
    return _repository.upsert(expense);
  }
}
