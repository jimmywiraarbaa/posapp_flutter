import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/database_provider.dart';
import '../../data/datasources/stock_local_data_source.dart';
import '../../data/repositories/stock_repository_impl.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../domain/usecases/add_stock_in.dart';
import '../../domain/usecases/adjust_stock.dart';

final stockLocalDataSourceProvider = Provider<StockLocalDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return StockLocalDataSource(db);
});

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  final local = ref.watch(stockLocalDataSourceProvider);
  return StockRepositoryImpl(local);
});

final addStockInProvider = Provider<AddStockIn>((ref) {
  final repo = ref.watch(stockRepositoryProvider);
  return AddStockIn(repo);
});

final adjustStockProvider = Provider<AdjustStock>((ref) {
  final repo = ref.watch(stockRepositoryProvider);
  return AdjustStock(repo);
});
