import '../entities/product.dart';

abstract class ProductRepository {
  Stream<List<Product>> watchAll({bool includeInactive = false});
  Future<List<Product>> fetchAll({bool includeInactive = false});
  Future<Product?> getById(String id);
  Future<void> upsert(Product product);
  Future<void> setActive(String id, bool isActive);
}
