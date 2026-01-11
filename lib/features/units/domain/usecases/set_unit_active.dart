import '../repositories/unit_repository.dart';

class SetUnitActive {
  SetUnitActive(this._repository);

  final UnitRepository _repository;

  Future<void> call(String id, bool isActive) {
    return _repository.setActive(id, isActive);
  }
}
