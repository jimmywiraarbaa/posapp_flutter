import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/entities/product.dart';
import 'cart_state.dart';

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  String? addProduct(Product product) {
    if (product.stockQty <= 0) {
      return 'Stok habis.';
    }
    final items = [...state.items];
    final index = items.indexWhere((item) => item.productId == product.id);
    if (index >= 0) {
      final existing = items[index];
      final nextQty = existing.qty + 1;
      if (nextQty > product.stockQty) {
        return 'Stok tidak mencukupi.';
      }
      items[index] = existing.copyWith(
        qty: nextQty,
        stockQty: product.stockQty,
      );
    } else {
      items.add(
        CartItem(
          productId: product.id,
          name: product.name,
          price: product.price,
          qty: 1,
          stockQty: product.stockQty,
        ),
      );
    }
    state = state.copyWith(items: items);
    return null;
  }

  String? updateQty({
    required String productId,
    required double qty,
    required double maxQty,
  }) {
    if (qty <= 0) {
      remove(productId);
      return null;
    }
    if (qty > maxQty) {
      return 'Stok tidak mencukupi.';
    }
    final items = [...state.items];
    final index = items.indexWhere((item) => item.productId == productId);
    if (index == -1) {
      return null;
    }
    items[index] = items[index].copyWith(qty: qty, stockQty: maxQty);
    state = state.copyWith(items: items);
    return null;
  }

  void remove(String productId) {
    state = state.copyWith(
      items: state.items.where((item) => item.productId != productId).toList(),
    );
  }

  void clear() {
    state = const CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);
