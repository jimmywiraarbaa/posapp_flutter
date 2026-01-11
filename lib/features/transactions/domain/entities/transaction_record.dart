class TransactionRecord {
  const TransactionRecord({
    required this.id,
    required this.trxNumber,
    required this.total,
    required this.paidAmount,
    required this.changeAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String trxNumber;
  final int total;
  final int paidAmount;
  final int changeAmount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
}
