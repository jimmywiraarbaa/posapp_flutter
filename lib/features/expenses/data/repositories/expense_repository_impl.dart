import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_data_source.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl(this._localDataSource);

  final ExpenseLocalDataSource _localDataSource;

  @override
  Stream<List<Expense>> watchAll() {
    return _localDataSource.watchAll();
  }

  @override
  Future<List<Expense>> fetchAll() {
    return _localDataSource.fetchAll();
  }

  @override
  Future<Expense?> getById(String id) {
    return _localDataSource.getById(id);
  }

  @override
  Future<void> upsert(Expense expense) {
    return _localDataSource.upsert(expense);
  }

  @override
  Future<void> deleteById(String id) {
    return _localDataSource.deleteById(id);
  }
}
