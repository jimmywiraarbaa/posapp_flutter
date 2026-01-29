import 'package:drift/drift.dart';

import '../../../../core/db/app_database.dart' as db;
import '../../domain/entities/expense.dart';

Expense expenseFromDb(db.Expense data) {
  return Expense(
    id: data.id,
    title: data.title,
    amount: data.amount,
    note: data.note,
    createdAt: DateTime.parse(data.createdAt),
    updatedAt: DateTime.parse(data.updatedAt),
  );
}

db.ExpensesCompanion expenseToCompanion(Expense expense) {
  return db.ExpensesCompanion(
    id: Value(expense.id),
    title: Value(expense.title),
    amount: Value(expense.amount),
    note: Value(expense.note),
    createdAt: Value(expense.createdAt.toIso8601String()),
    updatedAt: Value(expense.updatedAt.toIso8601String()),
  );
}
