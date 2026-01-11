import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._localDataSource);

  final ProductLocalDataSource _localDataSource;

  @override
  Stream<List<Product>> watchAll({bool includeInactive = false}) {
    return _localDataSource.watchAll(includeInactive: includeInactive);
  }

  @override
  Future<List<Product>> fetchAll({bool includeInactive = false}) {
    return _localDataSource.fetchAll(includeInactive: includeInactive);
  }

  @override
  Future<Product?> getById(String id) {
    return _localDataSource.getById(id);
  }

  @override
  Future<void> upsert(Product product) {
    return _localDataSource.upsert(product);
  }

  @override
  Future<void> setActive(String id, bool isActive) {
    return _localDataSource.setActive(id, isActive);
  }
}
