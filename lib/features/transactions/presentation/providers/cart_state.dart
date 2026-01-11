class CartItem {
  const CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.qty,
    required this.stockQty,
  });

  final String productId;
  final String name;
  final int price;
  final double qty;
  final double stockQty;

  int get subtotal => (price * qty).round();

  CartItem copyWith({
    String? productId,
    String? name,
    int? price,
    double? qty,
    double? stockQty,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      stockQty: stockQty ?? this.stockQty,
    );
  }
}

class CartState {
  const CartState({this.items = const []});

  final List<CartItem> items;

  int get total => items.fold<int>(0, (sum, item) => sum + item.subtotal);

  int get totalItems => items.fold<int>(0, (sum, item) => sum + item.qty.round());

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}
