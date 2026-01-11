import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/pages/product_form_page.dart';
import '../../../products/presentation/providers/product_providers.dart';

class ProductMasterTab extends ConsumerWidget {
  const ProductMasterTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider(true));

    return productsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('Belum ada produk.'));
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
      if (!product.isActive) 'Nonaktif',
    ].join(' • ');

    return ListTile(
      title: Text(product.name),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: product.isActive,
        onChanged: (value) {
          ref.read(setProductActiveProvider)(product.id, value);
        },
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductFormPage(initialProduct: product),
          ),
        );
      },
    );
  }
}
