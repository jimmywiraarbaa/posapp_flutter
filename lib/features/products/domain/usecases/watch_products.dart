import '../entities/product.dart';
import '../repositories/product_repository.dart';

class WatchProducts {
  WatchProducts(this._repository);

  final ProductRepository _repository;

  Stream<List<Product>> call({bool includeInactive = false}) {
    return _repository.watchAll(includeInactive: includeInactive);
  }
}
