import '../../domain/entities/unit.dart';
import '../../domain/repositories/unit_repository.dart';
import '../datasources/unit_local_data_source.dart';

class UnitRepositoryImpl implements UnitRepository {
  UnitRepositoryImpl(this._localDataSource);

  final UnitLocalDataSource _localDataSource;

  @override
  Stream<List<Unit>> watchAll({bool includeInactive = false}) {
    return _localDataSource.watchAll(includeInactive: includeInactive);
  }

  @override
  Future<List<Unit>> fetchAll({bool includeInactive = false}) {
    return _localDataSource.fetchAll(includeInactive: includeInactive);
  }

  @override
  Future<Unit?> getById(String id) {
    return _localDataSource.getById(id);
  }

  @override
  Future<void> upsert(Unit unit) {
    return _localDataSource.upsert(unit);
  }

  @override
  Future<void> setActive(String id, bool isActive) {
    return _localDataSource.setActive(id, isActive);
  }
}
