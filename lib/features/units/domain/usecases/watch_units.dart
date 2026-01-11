import '../entities/unit.dart';
import '../repositories/unit_repository.dart';

class WatchUnits {
  WatchUnits(this._repository);

  final UnitRepository _repository;

  Stream<List<Unit>> call({bool includeInactive = false}) {
    return _repository.watchAll(includeInactive: includeInactive);
  }
}
