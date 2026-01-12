import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/formatters/currency.dart';
import '../../../../shared/widgets/product_image.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../providers/cart_provider.dart';
import '../providers/cart_state.dart';
import 'checkout_page.dart';

const _unknownCategoryKey = '__unknown__';

final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);

class PosPage extends ConsumerWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider(false));
    final categoriesAsync = ref.watch(categoriesStreamProvider(true));
    final cart = ref.watch(cartProvider);
    final selectedCategoryId = ref.watch(selectedCategoryFilterProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: categoriesAsync.when(
            data: (categories) {
              final names = {
                for (final category in categories) category.id: category.name,
              };
              final items = productsAsync.value ?? const <Product>[];
              final sections = _groupProductsByCategory(items, names);
              final hasSelected = selectedCategoryId != null &&
                  sections.any((section) => section.id == selectedCategoryId);
              final effectiveSelected = hasSelected ? selectedCategoryId : null;
              return _CategoryFilterChips(
                sections: sections,
                selectedId: effectiveSelected,
                onSelected: (id) {
                  ref.read(selectedCategoryFilterProvider.notifier).state = id;
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),
        Expanded(
          child: productsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Text('Belum ada produk aktif.'));
              }
              final categories = categoriesAsync.value ?? const <Category>[];
              final categoryNames = {
                for (final category in categories) category.id: category.name,
              };
              final sections = _groupProductsByCategory(items, categoryNames);
              final hasSelected = selectedCategoryId != null &&
                  sections.any((section) => section.id == selectedCategoryId);
              final effectiveSelected = hasSelected ? selectedCategoryId : null;
              final visibleSections = effectiveSelected == null
                  ? sections
                  : sections
                      .where((section) => section.id == effectiveSelected)
                      .toList();
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: visibleSections.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final section = visibleSections[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CategoryHeader(
                        title: section.name,
                        count: section.products.length,
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: section.products.length,
                        itemBuilder: (context, productIndex) {
                          final product = section.products[productIndex];
                          return _ProductCard(product: product);
                        },
                      ),
                    ],
                  );
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

class _CategorySection {
  const _CategorySection({
    required this.id,
    required this.name,
    required this.products,
  });

  final String id;
  final String name;
  final List<Product> products;
}

List<_CategorySection> _groupProductsByCategory(
  List<Product> products,
  Map<String, String> categoryNames,
) {
  final grouped = <String, List<Product>>{};
  for (final product in products) {
    final hasCategory = categoryNames.containsKey(product.categoryId);
    final key = hasCategory ? product.categoryId : _unknownCategoryKey;
    grouped.putIfAbsent(key, () => []).add(product);
  }

  final sections = grouped.entries.map((entry) {
    final name = entry.key == _unknownCategoryKey
        ? 'Tanpa kategori'
        : categoryNames[entry.key] ?? 'Tanpa kategori';
    final sortedProducts = [...entry.value]
      ..sort((a, b) => a.name.compareTo(b.name));
    return _CategorySection(
      id: entry.key,
      name: name,
      products: sortedProducts,
    );
  }).toList();

  sections.sort((a, b) {
    if (a.name == 'Tanpa kategori') {
      return 1;
    }
    if (b.name == 'Tanpa kategori') {
      return -1;
    }
    return a.name.compareTo(b.name);
  });

  return sections;
}

class _CategoryFilterChips extends StatelessWidget {
  const _CategoryFilterChips({
    required this.sections,
    required this.selectedId,
    required this.onSelected,
  });

  final List<_CategorySection> sections;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      ChoiceChip(
        label: const Text('Semua'),
        selected: selectedId == null,
        onSelected: (_) => onSelected(null),
        shape: const StadiumBorder(),
      ),
    ];

    for (final section in sections) {
      chips.add(const SizedBox(width: 8));
      chips.add(
        ChoiceChip(
          label: Text(section.name),
          selected: selectedId == section.id,
          onSelected: (selected) => onSelected(selected ? section.id : null),
          shape: const StadiumBorder(),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: chips),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          '$count item',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProductImage(imagePath: product.imagePath),
              const SizedBox(height: 8),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(
                formatRupiah(product.price),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                stockLabel,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: stockColor,
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.center,
                child: Text(
                  isOutOfStock ? 'Stok habis' : 'Tap untuk tambah',
                  textAlign: TextAlign.center,
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
                final reversedIndex = cart.items.length - 1 - index;
                final item = cart.items[reversedIndex];
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
