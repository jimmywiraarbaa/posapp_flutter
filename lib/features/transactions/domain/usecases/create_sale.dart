import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/trx_number.dart';
import '../entities/sale.dart';
import '../repositories/transaction_repository.dart';

class CreateSale {
  CreateSale(this._repository);

  final TransactionRepository _repository;

  Future<void> call({
    required List<SaleItem> items,
    required int paidAmount,
    required String paymentMethod,
    String? note,
  }) async {
    if (items.isEmpty) {
      throw StateError('Keranjang masih kosong.');
    }
    final total = items.fold<int>(0, (sum, item) => sum + item.subtotal);
    if (paidAmount < total) {
      throw StateError('Pembayaran kurang.');
    }

    final transaction = SaleTransaction(
      id: generateId(),
      trxNumber: generateTrxNumber(),
      items: items,
      total: total,
      paidAmount: paidAmount,
      changeAmount: paidAmount - total,
      paymentMethod: paymentMethod,
      status: 'completed',
      note: note,
      createdAt: DateTime.now(),
    );

    await _repository.createSale(transaction);
  }
}
