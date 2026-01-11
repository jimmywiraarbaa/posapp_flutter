import '../entities/category.dart';
import '../repositories/category_repository.dart';

class UpsertCategory {
  UpsertCategory(this._repository);

  final CategoryRepository _repository;

  Future<void> call(Category category) {
    return _repository.upsert(category);
  }
}
