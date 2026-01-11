class TransactionItemRecord {
  const TransactionItemRecord({
    required this.id,
    required this.productId,
    required this.productName,
    required this.qty,
    required this.price,
    required this.subtotal,
    this.note,
  });

  final String id;
  final String productId;
  final String productName;
  final double qty;
  final int price;
  final int subtotal;
  final String? note;
}
