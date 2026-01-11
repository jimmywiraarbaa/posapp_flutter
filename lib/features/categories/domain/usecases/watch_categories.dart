import '../entities/category.dart';
import '../repositories/category_repository.dart';

class WatchCategories {
  WatchCategories(this._repository);

  final CategoryRepository _repository;

  Stream<List<Category>> call({bool includeInactive = false}) {
    return _repository.watchAll(includeInactive: includeInactive);
  }
}
