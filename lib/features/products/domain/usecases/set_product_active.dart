import '../repositories/product_repository.dart';

class SetProductActive {
  SetProductActive(this._repository);

  final ProductRepository _repository;

  Future<void> call(String id, bool isActive) {
    return _repository.setActive(id, isActive);
  }
}
