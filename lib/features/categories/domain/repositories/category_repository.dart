import '../entities/category.dart';

abstract class CategoryRepository {
  Stream<List<Category>> watchAll({bool includeInactive = false});
  Future<List<Category>> fetchAll({bool includeInactive = false});
  Future<Category?> getById(String id);
  Future<void> upsert(Category category);
  Future<void> setActive(String id, bool isActive);
}
