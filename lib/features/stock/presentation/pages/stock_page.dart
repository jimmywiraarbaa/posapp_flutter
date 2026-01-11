import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/presentation/providers/product_providers.dart';
import 'stock_adjustment_page.dart';
import 'stock_in_page.dart';

class StockPage extends ConsumerWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider(true));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const StockInPage()),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Stok Masuk'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const StockAdjustmentPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.tune),
                  label: const Text('Penyesuaian'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: productsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Text('Belum ada produk.'));
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final product = items[index];
                  final isLowStock = product.stockQty <= product.minStock;
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                      'Stok ${product.stockQty} • Min ${product.minStock}',
                    ),
                    trailing: isLowStock
                        ? const Text(
                            'Menipis',
                            style: TextStyle(color: Colors.red),
                          )
                        : null,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Gagal memuat stok.')),
          ),
        ),
      ],
    );
  }
}
