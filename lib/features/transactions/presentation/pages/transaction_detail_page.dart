import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/transaction_item_record.dart';
import '../../domain/entities/transaction_record.dart';
import '../providers/transaction_providers.dart';

class TransactionDetailPage extends ConsumerWidget {
  const TransactionDetailPage({super.key, required this.record});

  final TransactionRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(transactionItemsProvider(record.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Transaksi')),
      body: itemsAsync.when(
        data: (items) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryCard(record: record),
              const SizedBox(height: 16),
              Text('Item', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (items.isEmpty)
                const Text('Belum ada item.')
              else
                ...items.map((item) => _ItemRow(item: item)),
              if (record.status == 'completed') ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _confirmVoid(context, ref, record),
                  icon: const Icon(Icons.block),
                  label: const Text('Void Transaksi'),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Gagal memuat detail.')),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.record});

  final TransactionRecord record;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.trxNumber,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Tanggal: ${_formatDateTime(record.createdAt)}'),
            const SizedBox(height: 4),
            Text('Metode: ${record.paymentMethod}'),
            const SizedBox(height: 4),
            Text('Status: ${record.status}'),
            const SizedBox(height: 4),
            Text('Total: Rp ${record.total}'),
            const SizedBox(height: 4),
            Text('Bayar: Rp ${record.paidAmount}'),
            const SizedBox(height: 4),
            Text('Kembalian: Rp ${record.changeAmount}'),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmVoid(
  BuildContext context,
  WidgetRef ref,
  TransactionRecord record,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Void Transaksi'),
      content: const Text('Yakin ingin membatalkan transaksi ini?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Void'),
        ),
      ],
    ),
  );

  if (confirmed != true) {
    return;
  }

  try {
    await ref.read(voidTransactionProvider)(record.id);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil dibatalkan.')),
    );
    Navigator.of(context).pop();
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString())),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final TransactionItemRecord item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(item.productName)),
          Text('${item.qty} x ${item.price}'),
          const SizedBox(width: 12),
          Text('Rp ${item.subtotal}'),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString().padLeft(4, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}
