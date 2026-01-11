import '../../domain/repositories/stock_repository.dart';
import '../datasources/stock_local_data_source.dart';

class StockRepositoryImpl implements StockRepository {
  StockRepositoryImpl(this._localDataSource);

  final StockLocalDataSource _localDataSource;

  @override
  Future<void> addStockIn({
    required String productId,
    required double qty,
    String? note,
  }) {
    return _localDataSource.addStockIn(
      productId: productId,
      qty: qty,
      note: note,
    );
  }

  @override
  Future<void> adjustStock({
    required String productId,
    required double qty,
    required bool increase,
    required String note,
  }) {
    return _localDataSource.adjustStock(
      productId: productId,
      qty: qty,
      increase: increase,
      note: note,
    );
  }
}
