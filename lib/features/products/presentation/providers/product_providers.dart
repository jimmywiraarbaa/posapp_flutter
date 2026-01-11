import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/database_provider.dart';
import '../../data/datasources/product_local_data_source.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/set_product_active.dart';
import '../../domain/usecases/upsert_product.dart';
import '../../domain/usecases/watch_products.dart';

final productLocalDataSourceProvider = Provider<ProductLocalDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProductLocalDataSource(db);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final local = ref.watch(productLocalDataSourceProvider);
  return ProductRepositoryImpl(local);
});

final watchProductsProvider = Provider<WatchProducts>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return WatchProducts(repo);
});

final upsertProductProvider = Provider<UpsertProduct>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return UpsertProduct(repo);
});

final setProductActiveProvider = Provider<SetProductActive>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return SetProductActive(repo);
});

final productsStreamProvider = StreamProvider.family<List<Product>, bool>(
  (ref, includeInactive) {
    final watchProducts = ref.watch(watchProductsProvider);
    return watchProducts(includeInactive: includeInactive);
  },
);
