import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../../shared/formatters/currency.dart';
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
  int _paidAmount = 0;

  @override
  void initState() {
    super.initState();
    _paidController.addListener(_handlePaidChange);
  }

  @override
  void dispose() {
    _paidController.removeListener(_handlePaidChange);
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
      return const Scaffold(body: Center(child: Text('Keranjang kosong.')));
    }

    final total = cart.total;
    final change = _paidAmount - total;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SummaryCard(total: total, totalItems: cart.totalItems),
            const SizedBox(height: 16),
            _ItemsCard(items: cart.items),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pembayaran',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _paymentMethod,
                      decoration: const InputDecoration(labelText: 'Metode'),
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
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Bayar',
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) => _validatePaid(value, total),
                    ),
                    const SizedBox(height: 16),
                    _ChangeRow(change: change),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _submit(cart.items),
                      child: const Text('Bayar'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePaidChange() {
    final parsed = int.tryParse(_paidController.text.trim()) ?? 0;
    if (parsed != _paidAmount) {
      setState(() => _paidAmount = parsed);
    }
  }
}

class _CheckoutItemRow extends StatelessWidget {
  const _CheckoutItemRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${formatQty(item.qty)} x ${formatRupiah(item.price)}',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                formatRupiah(item.subtotal),
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.total, required this.totalItems});

  final int total;
  final int totalItems;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ringkasan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('Item: $totalItems'),
              ],
            ),
            const Spacer(),
            Text(
              formatRupiah(total),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.items});

  final List<CartItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (var index = 0; index < items.length; index++) ...[
              _CheckoutItemRow(item: items[index]),
              if (index != items.length - 1) const Divider(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChangeRow extends StatelessWidget {
  const _ChangeRow({required this.change});

  final int change;

  @override
  Widget build(BuildContext context) {
    if (change >= 0) {
      return Row(
        children: [
          const Text('Kembalian'),
          const Spacer(),
          Text(formatRupiah(change)),
        ],
      );
    }

    return Row(
      children: [
        const Text('Kurang'),
        const Spacer(),
        Text(
          formatRupiah(change.abs()),
          style: const TextStyle(color: Colors.red),
        ),
      ],
    );
  }
}
