import '../repositories/stock_repository.dart';

class AddStockIn {
  AddStockIn(this._repository);

  final StockRepository _repository;

  Future<void> call({
    required String productId,
    required double qty,
    String? note,
  }) {
    return _repository.addStockIn(
      productId: productId,
      qty: qty,
      note: note,
    );
  }
}
