import '../repositories/stock_repository.dart';

class AdjustStock {
  AdjustStock(this._repository);

  final StockRepository _repository;

  Future<void> call({
    required String productId,
    required double qty,
    required bool increase,
    required String note,
  }) {
    return _repository.adjustStock(
      productId: productId,
      qty: qty,
      increase: increase,
      note: note,
    );
  }
}
