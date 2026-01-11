import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/pages/product_form_page.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../units/domain/entities/unit.dart';
import '../../../units/presentation/providers/unit_providers.dart';

class ProductMasterTab extends ConsumerWidget {
  const ProductMasterTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider(true));
    final categoriesAsync = ref.watch(categoriesStreamProvider(true));
    final unitsAsync = ref.watch(unitsStreamProvider(true));

    if (productsAsync.isLoading ||
        categoriesAsync.isLoading ||
        unitsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productsAsync.hasError) {
      return const Center(child: Text('Gagal memuat produk.'));
    }

    if (categoriesAsync.hasError || unitsAsync.hasError) {
      return const Center(child: Text('Gagal memuat kategori/satuan.'));
    }

    final products = productsAsync.value ?? const <Product>[];
    final categories = categoriesAsync.value ?? const <Category>[];
    final units = unitsAsync.value ?? const <Unit>[];

    if (products.isEmpty) {
      return const Center(child: Text('Belum ada produk.'));
    }

    final categoryById = {
      for (final category in categories) category.id: category,
    };
    final unitById = {
      for (final unit in units) unit.id: unit,
    };

    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final product = products[index];
        final categoryLabel =
            categoryById[product.categoryId]?.name ?? '-';
        final unitLabel = unitById[product.unitId]?.name ?? '-';
        return _ProductTile(
          product: product,
          categoryLabel: categoryLabel,
          unitLabel: unitLabel,
        );
      },
    );
  }
}

class _ProductTile extends ConsumerWidget {
  const _ProductTile({
    required this.product,
    required this.categoryLabel,
    required this.unitLabel,
  });

  final Product product;
  final String categoryLabel;
  final String unitLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = <String>[
      categoryLabel,
      unitLabel,
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
