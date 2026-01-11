abstract class StockRepository {
  Future<void> addStockIn({
    required String productId,
    required double qty,
    String? note,
  });

  Future<void> adjustStock({
    required String productId,
    required double qty,
    required bool increase,
    required String note,
  });
}
