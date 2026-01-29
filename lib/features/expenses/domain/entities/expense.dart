class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final int amount;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense copyWith({
    String? id,
    String? title,
    int? amount,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
