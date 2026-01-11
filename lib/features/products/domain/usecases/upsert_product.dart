import '../entities/product.dart';
import '../repositories/product_repository.dart';

class UpsertProduct {
  UpsertProduct(this._repository);

  final ProductRepository _repository;

  Future<void> call(Product product) {
    return _repository.upsert(product);
  }
}
