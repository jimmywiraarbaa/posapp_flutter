import 'package:drift/drift.dart';

import '../../../../core/db/app_database.dart' as db;
import '../../domain/entities/expense.dart';
import '../mappers/expense_mapper.dart';

class ExpenseLocalDataSource {
  ExpenseLocalDataSource(this._db);

  final db.AppDatabase _db;

  Stream<List<Expense>> watchAll() {
    final query = _db.select(_db.expenses)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map((rows) => rows.map(expenseFromDb).toList());
  }

  Future<List<Expense>> fetchAll() async {
    final query = _db.select(_db.expenses)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
      ]);
    final rows = await query.get();
    return rows.map(expenseFromDb).toList();
  }

  Future<Expense?> getById(String id) async {
    final query = _db.select(_db.expenses)..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return expenseFromDb(row);
  }

  Future<void> upsert(Expense expense) async {
    await _db.into(_db.expenses).insertOnConflictUpdate(
          expenseToCompanion(expense),
        );
  }

  Future<void> deleteById(String id) async {
    await (_db.delete(_db.expenses)..where((tbl) => tbl.id.equals(id))).go();
  }
}
