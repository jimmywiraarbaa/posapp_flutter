import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart' as db;
import '../../domain/entities/unit.dart';
import '../mappers/unit_mapper.dart';

class UnitLocalDataSource {
  UnitLocalDataSource(this._db);

  final db.AppDatabase _db;

  Stream<List<Unit>> watchAll({bool includeInactive = false}) {
    final query = _db.select(_db.units);
    if (!includeInactive) {
      query.where((tbl) => tbl.isActive.equals(true));
    }
    return query.watch().map((rows) => rows.map(unitFromDb).toList());
  }

  Future<List<Unit>> fetchAll({bool includeInactive = false}) async {
    final query = _db.select(_db.units);
    if (!includeInactive) {
      query.where((tbl) => tbl.isActive.equals(true));
    }
    final rows = await query.get();
    return rows.map(unitFromDb).toList();
  }

  Future<Unit?> getById(String id) async {
    final query = _db.select(_db.units)..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return unitFromDb(row);
  }

  Future<void> upsert(Unit unit) async {
    await _db.into(_db.units).insertOnConflictUpdate(
          unitToCompanion(unit),
        );
  }

  Future<void> setActive(String id, bool isActive) async {
    final now = DateTime.now().toIso8601String();
    await (_db.update(_db.units)..where((tbl) => tbl.id.equals(id))).write(
      db.UnitsCompanion(
        isActive: Value(isActive),
        updatedAt: Value(now),
      ),
    );
  }
}
