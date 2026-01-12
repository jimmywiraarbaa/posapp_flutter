import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../../shared/formatters/currency.dart';
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
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final product = items[index];
                  return _ProductCard(product: product);
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

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOutOfStock = product.stockQty <= 0;
    final stockLabel = 'Stok ${formatQty(product.stockQty)}';
    final theme = Theme.of(context);
    final stockColor = isOutOfStock
        ? theme.colorScheme.error
        : theme.colorScheme.onSurfaceVariant;

    return Card(
      child: InkWell(
        onTap: isOutOfStock
            ? null
            : () {
                final message =
                    ref.read(cartProvider.notifier).addProduct(product);
                if (message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(
                formatRupiah(product.price),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: stockColor,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      stockLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: stockColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isOutOfStock ? 'Stok habis' : 'Tap untuk tambah',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isOutOfStock
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
        child: Row(
          children: [
            const Icon(Icons.shopping_bag_outlined),
            const SizedBox(width: 8),
            const Text('Keranjang kosong.'),
            const Spacer(),
            Text(formatRupiah(0)),
          ],
        ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Item: ${cart.totalItems}'),
                  Text(
                    formatRupiah(cart.total),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _confirmClear(context, ref),
                icon: const Icon(Icons.delete_outline),
              ),
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
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                final maxQty =
                    stockById[item.productId]?.stockQty ?? item.stockQty;
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
      subtitle: Text(formatRupiah(item.subtotal)),
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
            Text(formatQty(item.qty)),
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

Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Kosongkan Keranjang'),
      content: const Text('Yakin ingin menghapus semua item di keranjang?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    ref.read(cartProvider.notifier).clear();
  }
}
