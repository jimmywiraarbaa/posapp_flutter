import '../repositories/category_repository.dart';

class SetCategoryActive {
  SetCategoryActive(this._repository);

  final CategoryRepository _repository;

  Future<void> call(String id, bool isActive) {
    return _repository.setActive(id, isActive);
  }
}
