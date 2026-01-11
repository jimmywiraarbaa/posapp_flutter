import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/database_provider.dart';
import '../../data/datasources/unit_local_data_source.dart';
import '../../data/repositories/unit_repository_impl.dart';
import '../../domain/entities/unit.dart';
import '../../domain/repositories/unit_repository.dart';
import '../../domain/usecases/set_unit_active.dart';
import '../../domain/usecases/upsert_unit.dart';
import '../../domain/usecases/watch_units.dart';

final unitLocalDataSourceProvider = Provider<UnitLocalDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return UnitLocalDataSource(db);
});

final unitRepositoryProvider = Provider<UnitRepository>((ref) {
  final local = ref.watch(unitLocalDataSourceProvider);
  return UnitRepositoryImpl(local);
});

final watchUnitsProvider = Provider<WatchUnits>((ref) {
  final repo = ref.watch(unitRepositoryProvider);
  return WatchUnits(repo);
});

final upsertUnitProvider = Provider<UpsertUnit>((ref) {
  final repo = ref.watch(unitRepositoryProvider);
  return UpsertUnit(repo);
});

final setUnitActiveProvider = Provider<SetUnitActive>((ref) {
  final repo = ref.watch(unitRepositoryProvider);
  return SetUnitActive(repo);
});

final unitsStreamProvider = StreamProvider.family<List<Unit>, bool>(
  (ref, includeInactive) {
    final watchUnits = ref.watch(watchUnitsProvider);
    return watchUnits(includeInactive: includeInactive);
  },
);
