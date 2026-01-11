import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/database_provider.dart';
import '../../data/datasources/category_local_data_source.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/set_category_active.dart';
import '../../domain/usecases/upsert_category.dart';
import '../../domain/usecases/watch_categories.dart';

final categoryLocalDataSourceProvider = Provider<CategoryLocalDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CategoryLocalDataSource(db);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final local = ref.watch(categoryLocalDataSourceProvider);
  return CategoryRepositoryImpl(local);
});

final watchCategoriesProvider = Provider<WatchCategories>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return WatchCategories(repo);
});

final upsertCategoryProvider = Provider<UpsertCategory>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return UpsertCategory(repo);
});

final setCategoryActiveProvider = Provider<SetCategoryActive>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return SetCategoryActive(repo);
});

final categoriesStreamProvider = StreamProvider.family<List<Category>, bool>(
  (ref, includeInactive) {
    final watchCategories = ref.watch(watchCategoriesProvider);
    return watchCategories(includeInactive: includeInactive);
  },
);
