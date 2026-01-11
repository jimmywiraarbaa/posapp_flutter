import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/pages/category_form_page.dart';
import '../../../categories/presentation/providers/category_providers.dart';

class CategoryMasterTab extends ConsumerWidget {
  const CategoryMasterTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider(true));

    return categoriesAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('Belum ada kategori.'));
        }
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final category = items[index];
            return _CategoryTile(category: category);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Gagal memuat kategori.')),
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = !category.isActive ? 'Nonaktif' : null;

    return ListTile(
      title: Text(category.name),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: Switch(
        value: category.isActive,
        onChanged: (value) {
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
