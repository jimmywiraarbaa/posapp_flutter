import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/id_generator.dart';
import '../../domain/entities/category.dart';
import '../providers/category_providers.dart';

class CategoryFormPage extends ConsumerStatefulWidget {
  const CategoryFormPage({super.key, this.initialCategory});

  final Category? initialCategory;

  @override
  ConsumerState<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends ConsumerState<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final category = widget.initialCategory;
    _nameController = TextEditingController(text: category?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final name = _nameController.text.trim();
    if (await _isNameDuplicate(name)) {
      _showMessage('Nama kategori sudah digunakan.');
      return;
    }

    final now = DateTime.now();
    final existing = widget.initialCategory;
    final category = Category(
      id: existing?.id ?? generateId(),
      name: name,
      isActive: existing?.isActive ?? true,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    await ref.read(upsertCategoryProvider)(category);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<bool> _isNameDuplicate(String name) async {
    final repo = ref.read(categoryRepositoryProvider);
    final items = await repo.fetchAll(includeInactive: true);
    final normalized = name.toLowerCase();
    return items.any(
      (item) =>
          item.id != widget.initialCategory?.id &&
          item.name.trim().toLowerCase() == normalized,
    );
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialCategory == null ? 'Tambah Kategori' : 'Edit Kategori',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Kategori'),
              validator: _validateRequired,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
