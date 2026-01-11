import '../entities/unit.dart';

abstract class UnitRepository {
  Stream<List<Unit>> watchAll({bool includeInactive = false});
  Future<List<Unit>> fetchAll({bool includeInactive = false});
  Future<Unit?> getById(String id);
  Future<void> upsert(Unit unit);
  Future<void> setActive(String id, bool isActive);
}
