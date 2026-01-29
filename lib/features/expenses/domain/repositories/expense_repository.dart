import '../entities/expense.dart';

abstract class ExpenseRepository {
  Stream<List<Expense>> watchAll();
  Future<List<Expense>> fetchAll();
  Future<Expense?> getById(String id);
  Future<void> upsert(Expense expense);
  Future<void> deleteById(String id);
}
