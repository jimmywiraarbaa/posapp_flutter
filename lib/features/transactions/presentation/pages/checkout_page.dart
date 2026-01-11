import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../domain/entities/sale.dart';
import '../providers/cart_provider.dart';
import '../providers/cart_state.dart';
import '../providers/transaction_providers.dart';

const _paymentMethods = ['Cash', 'QRIS', 'Transfer'];

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _paidController = TextEditingController();
  String _paymentMethod = _paymentMethods.first;

  @override
  void dispose() {
    _paidController.dispose();
    super.dispose();
  }

  Future<void> _submit(List<CartItem> items) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final productsAsync = ref.read(productsStreamProvider(true));
    if (productsAsync.isLoading) {
      _showMessage('Data produk sedang dimuat.');
      return;
    }
    if (productsAsync.hasError) {
      _showMessage('Gagal memuat data produk.');
      return;
    }
    final products = productsAsync.value ?? const <Product>[];
    final stockById = {for (final product in products) product.id: product};

    for (final item in items) {
      final product = stockById[item.productId];
      if (product == null) {
        _showMessage('Produk tidak ditemukan.');
        return;
      }
      if (item.qty > product.stockQty) {
        _showMessage('Stok tidak mencukupi untuk ${product.name}.');
        return;
      }
    }

    final paidAmount = int.parse(_paidController.text.trim());
    final saleItems = items
        .map(
          (item) => SaleItem(
            productId: item.productId,
            qty: item.qty,
            price: item.price,
            subtotal: item.subtotal,
          ),
        )
        .toList();

    try {
      await ref.read(createSaleProvider)(
            items: saleItems,
            paidAmount: paidAmount,
            paymentMethod: _paymentMethod,
          );
      ref.read(cartProvider.notifier).clear();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? _validatePaid(String? value, int total) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi.';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < total) {
      return 'Pembayaran kurang.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    if (cart.items.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Keranjang kosong.')),
      );
    }

    final total = cart.total;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Item', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...cart.items.map((item) => _CheckoutItemRow(item: item)),
            const Divider(height: 32),
            Text('Total: Rp $total'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(labelText: 'Metode Bayar'),
              items: _paymentMethods
                  .map(
                    (method) => DropdownMenuItem(
                      value: method,
                      child: Text(method),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _paymentMethod = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _paidController,
              decoration: const InputDecoration(labelText: 'Jumlah Bayar'),
              keyboardType: TextInputType.number,
              validator: (value) => _validatePaid(value, total),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => _submit(cart.items),
              child: const Text('Bayar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutItemRow extends StatelessWidget {
  const _CheckoutItemRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(item.name)),
          Text('${item.qty} x ${item.price}'),
          const SizedBox(width: 12),
          Text('Rp ${item.subtotal}'),
        ],
      ),
    );
  }
}
