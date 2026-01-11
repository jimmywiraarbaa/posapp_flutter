import 'package:drift/drift.dart';

import '../../../../core/db/app_database.dart' as db;
import '../../../../core/utils/id_generator.dart';

class PinLocalDataSource {
  PinLocalDataSource(this._db);

  final db.AppDatabase _db;

  Future<db.Pin?> getActivePin() {
    final query = _db.select(_db.pins)
      ..where((tbl) => tbl.isActive.equals(true));
    return query.getSingleOrNull();
  }

  Future<bool> hasPin() async {
    final pin = await getActivePin();
    return pin != null;
  }

  Future<void> setPin({required String pinHash}) async {
    final now = DateTime.now().toIso8601String();

    await _db.transaction(() async {
      await (_db.update(_db.pins)..where((tbl) => tbl.isActive.equals(true)))
          .write(
        db.PinsCompanion(
          isActive: const Value(false),
          updatedAt: Value(now),
        ),
      );

      await _db.into(_db.pins).insert(
            db.PinsCompanion(
              id: Value(generateId()),
              name: const Value('Owner'),
              pinHash: Value(pinHash),
              role: const Value('owner'),
              isActive: const Value(true),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
    });
  }

  Future<bool> verifyPin({required String pinHash}) async {
    final pin = await getActivePin();
    if (pin == null) {
      return false;
    }
    return pin.pinHash == pinHash;
  }
}
