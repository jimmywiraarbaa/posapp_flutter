import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../providers/stock_providers.dart';

class StockInPage extends ConsumerStatefulWidget {
  const StockInPage({super.key});

  @override
  ConsumerState<StockInPage> createState() => _StockInPageState();
}

class _StockInPageState extends ConsumerState<StockInPage> {
  final _formKey = GlobalKey<FormState>();

  final _qtyController = TextEditingController();
  final _noteController = TextEditingController();
  String? _productId;

  @override
  void dispose() {
    _qtyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_productId == null) {
      _showMessage('Produk wajib dipilih.');
      return;
    }

    final qty = _parseDouble(_qtyController.text);

    try {
      await ref.read(addStockInProvider)(
        productId: _productId!,
        qty: qty,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  double _parseDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    return double.parse(normalized);
  }

  String? _validateQty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi.';
    }
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      return 'Qty harus lebih dari 0.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider(true));

    return Scaffold(
      appBar: AppBar(title: const Text('Stok Masuk')),
      body: productsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada produk.'));
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ProductDropdown(
                  products: items,
                  value: _productId,
                  onChanged: (value) => setState(() => _productId = value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _qtyController,
                  decoration: const InputDecoration(labelText: 'Qty Masuk'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _validateQty,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'Catatan'),
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: _save, child: const Text('Simpan')),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Gagal memuat produk.')),
      ),
    );
  }
}

class _ProductDropdown extends StatelessWidget {
  const _ProductDropdown({
    required this.products,
    required this.value,
    required this.onChanged,
  });

  final List<Product> products;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Produk'),
      items: products
          .map(
            (product) =>
                DropdownMenuItem(value: product.id, child: Text(product.name)),
          )
          .toList(),
      onChanged: onChanged,
      validator: (selected) {
        if (selected == null || selected.isEmpty) {
          return 'Pilih produk.';
        }
        return null;
      },
    );
  }
}
