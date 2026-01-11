import '../entities/unit.dart';
import '../repositories/unit_repository.dart';

class UpsertUnit {
  UpsertUnit(this._repository);

  final UnitRepository _repository;

  Future<void> call(Unit unit) {
    return _repository.upsert(unit);
  }
}
