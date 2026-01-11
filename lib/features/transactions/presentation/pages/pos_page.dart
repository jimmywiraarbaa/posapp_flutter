import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../providers/cart_provider.dart';
import '../providers/cart_state.dart';
import 'checkout_page.dart';

class PosPage extends ConsumerWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider(false));
    final cart = ref.watch(cartProvider);

    return Column(
      children: [
        Expanded(
          child: productsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Text('Belum ada produk aktif.'));
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final product = items[index];
                  return _ProductTile(product: product);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Gagal memuat produk.')),
          ),
        ),
        _CartPanel(cart: cart),
      ],
    );
  }
}

class _ProductTile extends ConsumerWidget {
  const _ProductTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = <String>[
      'Rp ${product.price}',
      'Stok ${product.stockQty}',
    ].join(' • ');

    return ListTile(
      title: Text(product.name),
      subtitle: Text(subtitle),
      trailing: FilledButton(
        onPressed: () {
          final message = ref.read(cartProvider.notifier).addProduct(product);
          if (message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        },
        child: const Text('Tambah'),
      ),
    );
  }
}

class _CartPanel extends ConsumerWidget {
  const _CartPanel({required this.cart});

  final CartState cart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (cart.items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.centerLeft,
        child: const Text('Keranjang kosong.'),
      );
    }

    final productsAsync = ref.watch(productsStreamProvider(true));
    final products = productsAsync.value ?? const <Product>[];
    final stockById = {for (final product in products) product.id: product};

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Total: Rp ${cart.total}'),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CheckoutPage()),
                  );
                },
                child: const Text('Checkout'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: ListView.separated(
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                final maxQty = stockById[item.productId]?.stockQty ?? item.stockQty;
                return _CartItemTile(item: item, maxQty: maxQty);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({required this.item, required this.maxQty});

  final CartItem item;
  final double maxQty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text('Rp ${item.subtotal}'),
      trailing: SizedBox(
        width: 140,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                ref.read(cartProvider.notifier).updateQty(
                      productId: item.productId,
                      qty: item.qty - 1,
                      maxQty: maxQty,
                    );
              },
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(item.qty.toString()),
            IconButton(
              onPressed: () {
                final message = ref.read(cartProvider.notifier).updateQty(
                      productId: item.productId,
                      qty: item.qty + 1,
                      maxQty: maxQty,
                    );
                if (message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              },
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}
