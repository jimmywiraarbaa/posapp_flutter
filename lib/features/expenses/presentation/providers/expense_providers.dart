import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/database_provider.dart';
import '../../data/datasources/expense_local_data_source.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/upsert_expense.dart';
import '../../domain/usecases/watch_expenses.dart';

final expenseLocalDataSourceProvider = Provider<ExpenseLocalDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ExpenseLocalDataSource(db);
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final local = ref.watch(expenseLocalDataSourceProvider);
  return ExpenseRepositoryImpl(local);
});

final watchExpensesProvider = Provider<WatchExpenses>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return WatchExpenses(repo);
});

final upsertExpenseProvider = Provider<UpsertExpense>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return UpsertExpense(repo);
});

final deleteExpenseProvider = Provider<DeleteExpense>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return DeleteExpense(repo);
});

final expensesStreamProvider = StreamProvider<List<Expense>>((ref) {
  final watchExpenses = ref.watch(watchExpensesProvider);
  return watchExpenses();
});
