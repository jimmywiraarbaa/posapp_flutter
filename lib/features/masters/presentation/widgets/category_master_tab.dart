import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/pages/category_form_page.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../products/presentation/providers/product_providers.dart';

class CategoryMasterTab extends ConsumerWidget {
  const CategoryMasterTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider(true));
    final activeProductsAsync = ref.watch(productsStreamProvider(false));

    if (categoriesAsync.isLoading || activeProductsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (categoriesAsync.hasError) {
      return const Center(child: Text('Gagal memuat kategori.'));
    }

    if (activeProductsAsync.hasError) {
      return const Center(child: Text('Gagal memuat produk aktif.'));
    }

    final categories = categoriesAsync.value ?? const <Category>[];
    final activeProducts = activeProductsAsync.value ?? const [];
    final activeCategoryIds = {
      for (final product in activeProducts) product.categoryId,
    };

    if (categories.isEmpty) {
      return const Center(child: Text('Belum ada kategori.'));
    }

    return ListView.separated(
      itemCount: categories.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryTile(
          category: category,
          isInUse: activeCategoryIds.contains(category.id),
        );
      },
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({required this.category, required this.isInUse});

  final Category category;
  final bool isInUse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitleItems = <String>[
      'Urutan ${category.sortOrder}',
      if (!category.isActive) 'Nonaktif',
      if (isInUse) 'Dipakai produk aktif',
    ];
    final subtitle = subtitleItems.isEmpty ? null : subtitleItems.join(' • ');

    return ListTile(
      title: Text(category.name),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: Switch(
        value: category.isActive,
        onChanged: (value) {
          if (!value && isInUse) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Tidak bisa menonaktifkan kategori yang dipakai.'),
              ),
            );
            return;
          }
          ref.read(setCategoryActiveProvider)(category.id, value);
        },
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoryFormPage(initialCategory: category),
          ),
        );
      },
    );
  }
}
