class SaleItem {
  const SaleItem({
    required this.productId,
    required this.qty,
    required this.price,
    required this.subtotal,
    this.id,
    this.note,
  });

  final String? id;
  final String productId;
  final double qty;
  final int price;
  final int subtotal;
  final String? note;
}

class SaleTransaction {
  const SaleTransaction({
    required this.id,
    required this.trxNumber,
    required this.items,
    required this.total,
    required this.paidAmount,
    required this.changeAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String trxNumber;
  final List<SaleItem> items;
  final int total;
  final int paidAmount;
  final int changeAmount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final String? note;
}
