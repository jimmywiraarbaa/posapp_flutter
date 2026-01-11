import 'package:drift/drift.dart';

import '../../../../core/db/app_database.dart' as db;
import '../../domain/entities/unit.dart';

Unit unitFromDb(db.Unit data) {
  return Unit(
    id: data.id,
    name: data.name,
    symbol: data.symbol,
    isActive: data.isActive,
    createdAt: DateTime.parse(data.createdAt),
    updatedAt: DateTime.parse(data.updatedAt),
  );
}

db.UnitsCompanion unitToCompanion(Unit unit) {
  return db.UnitsCompanion(
    id: Value(unit.id),
    name: Value(unit.name),
    symbol: Value(unit.symbol),
    isActive: Value(unit.isActive),
    createdAt: Value(unit.createdAt.toIso8601String()),
    updatedAt: Value(unit.updatedAt.toIso8601String()),
  );
}
