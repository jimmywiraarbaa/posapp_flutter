import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._localDataSource);

  final CategoryLocalDataSource _localDataSource;

  @override
  Stream<List<Category>> watchAll({bool includeInactive = false}) {
    return _localDataSource.watchAll(includeInactive: includeInactive);
  }

  @override
  Future<List<Category>> fetchAll({bool includeInactive = false}) {
    return _localDataSource.fetchAll(includeInactive: includeInactive);
  }

  @override
  Future<Category?> getById(String id) {
    return _localDataSource.getById(id);
  }

  @override
  Future<void> upsert(Category category) {
    return _localDataSource.upsert(category);
  }

  @override
  Future<void> setActive(String id, bool isActive) {
    return _localDataSource.setActive(id, isActive);
  }
}
