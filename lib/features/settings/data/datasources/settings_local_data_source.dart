import 'package:drift/drift.dart';

import '../../../../core/db/app_database.dart' as db;

class SettingsLocalDataSource {
  SettingsLocalDataSource(this._db);

  final db.AppDatabase _db;

  Future<int?> getInt(String key) async {
    final query = _db.select(_db.settings)..where((tbl) => tbl.key.equals(key));
    final row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return int.tryParse(row.value);
  }

  Future<void> setInt(String key, int value) async {
    await _db.into(_db.settings).insertOnConflictUpdate(
          db.SettingsCompanion(
            key: Value(key),
            value: Value(value.toString()),
          ),
        );
  }

  Future<double?> getDouble(String key) async {
    final query = _db.select(_db.settings)..where((tbl) => tbl.key.equals(key));
    final row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return double.tryParse(row.value);
  }

  Future<void> setDouble(String key, double value) async {
    await _db.into(_db.settings).insertOnConflictUpdate(
          db.SettingsCompanion(
            key: Value(key),
            value: Value(value.toString()),
          ),
        );
  }
}
