import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class WatchExpenses {
  WatchExpenses(this._repository);

  final ExpenseRepository _repository;

  Stream<List<Expense>> call() {
    return _repository.watchAll();
  }
}
