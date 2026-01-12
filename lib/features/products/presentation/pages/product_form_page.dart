import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../units/domain/entities/unit.dart';
import '../../../units/presentation/providers/unit_providers.dart';
import '../../domain/entities/product.dart';
import '../providers/product_providers.dart';
import '../../../../shared/widgets/product_image.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  const ProductFormPage({super.key, this.initialProduct});

  final Product? initialProduct;

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _minStockController;

  String? _categoryId;
  String? _unitId;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final product = widget.initialProduct;
    _nameController = TextEditingController(text: product?.name ?? '');
    _priceController = TextEditingController(
      text: product == null ? '' : product.price.toString(),
    );
    _stockController = TextEditingController(
      text: product == null ? '' : product.stockQty.toString(),
    );
    _minStockController = TextEditingController(
      text: product == null ? '' : product.minStock.toString(),
    );
    _categoryId = product?.categoryId;
    _unitId = product?.unitId;
    _imagePath = product?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_categoryId == null || _unitId == null) {
      _showMessage('Kategori dan satuan wajib dipilih.');
      return;
    }
    final name = _nameController.text.trim();
    if (await _isNameDuplicate(name)) {
      _showMessage('Nama produk sudah digunakan.');
      return;
    }

    final now = DateTime.now();
    final existing = widget.initialProduct;

    final product = Product(
      id: existing?.id ?? generateId(),
      name: name,
      imagePath: _imagePath,
      categoryId: _categoryId!,
      unitId: _unitId!,
      price: int.parse(_priceController.text.trim()),
      stockQty: _parseDouble(_stockController.text),
      minStock: _parseDouble(_minStockController.text),
      isActive: existing?.isActive ?? true,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    await ref.read(upsertProductProvider)(product);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _isNameDuplicate(String name) async {
    final repo = ref.read(productRepositoryProvider);
    final items = await repo.fetchAll(includeInactive: true);
    final normalized = name.toLowerCase();
    return items.any(
      (item) =>
          item.id != widget.initialProduct?.id &&
          item.name.trim().toLowerCase() == normalized,
    );
  }

  double _parseDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    return double.parse(normalized);
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi.';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi.';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return 'Harga harus lebih dari 0.';
    }
    return null;
  }

  String? _validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi.';
    }
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null || parsed < 0) {
      return 'Masukkan angka yang valid.';
    }
    return null;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) {
      return;
    }

    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'product_images'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final extension = p.extension(picked.path);
    final fileName = '${generateId()}${extension.isEmpty ? '.jpg' : extension}';
    final target = File(p.join(dir.path, fileName));
    final copied = await File(picked.path).copy(target.path);

    await _deleteLocalImage(_imagePath);
    if (!mounted) {
      return;
    }
    setState(() => _imagePath = copied.path);
  }

  Future<void> _removeImage() async {
    await _deleteLocalImage(_imagePath);
    if (!mounted) {
      return;
    }
    setState(() => _imagePath = null);
  }

  Future<void> _deleteLocalImage(String? path) async {
    if (path == null || path.isEmpty) {
      return;
    }
    if (!path.contains('${p.separator}product_images${p.separator}')) {
      return;
    }
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider(true));
    final unitsAsync = ref.watch(unitsStreamProvider(true));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialProduct == null ? 'Tambah Produk' : 'Edit Produk',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Produk'),
              validator: _validateRequired,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(_imagePath == null ? 'Pilih Gambar' : 'Ganti Gambar'),
            ),
            if (_imagePath != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _removeImage,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus Gambar'),
              ),
            ],
            const SizedBox(height: 12),
            ProductImage(
              imagePath: _imagePath,
              aspectRatio: 16 / 9,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
              validator: _validatePrice,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(labelText: 'Stok Awal'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _validateNumber,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _minStockController,
              decoration: const InputDecoration(labelText: 'Stok Minimal'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _validateNumber,
            ),
            const SizedBox(height: 12),
            _CategoryField(
              categoriesAsync: categoriesAsync,
              value: _categoryId,
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: 12),
            _UnitField(
              unitsAsync: unitsAsync,
              value: _unitId,
              onChanged: (value) => setState(() => _unitId = value),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({
    required this.categoriesAsync,
    required this.value,
    required this.onChanged,
  });

  final AsyncValue<List<Category>> categoriesAsync;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return categoriesAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Text('Belum ada kategori.');
        }
        return DropdownButtonFormField<String>(
          initialValue: value,
          decoration: const InputDecoration(labelText: 'Kategori'),
          items: items
              .map(
                (category) => DropdownMenuItem(
                  value: category.id,
                  child: Text(_formatLabel(category.name, category.isActive)),
                ),
              )
              .toList(),
          onChanged: onChanged,
          validator: (selected) {
            if (selected == null || selected.isEmpty) {
              return 'Pilih kategori.';
            }
            return null;
          },
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Gagal memuat kategori.'),
    );
  }
}

class _UnitField extends StatelessWidget {
  const _UnitField({
    required this.unitsAsync,
    required this.value,
    required this.onChanged,
  });

  final AsyncValue<List<Unit>> unitsAsync;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return unitsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Text('Belum ada satuan.');
        }
        return DropdownButtonFormField<String>(
          initialValue: value,
          decoration: const InputDecoration(labelText: 'Satuan'),
          items: items
              .map(
                (unit) => DropdownMenuItem(
                  value: unit.id,
                  child: Text(_formatLabel(unit.name, unit.isActive)),
                ),
              )
              .toList(),
          onChanged: onChanged,
          validator: (selected) {
            if (selected == null || selected.isEmpty) {
              return 'Pilih satuan.';
            }
            return null;
          },
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Gagal memuat satuan.'),
    );
  }
}

String _formatLabel(String name, bool isActive) {
  if (isActive) {
    return name;
  }
  return '$name (nonaktif)';
}
