import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../reports/domain/entities/top_product.dart';
import '../../../reports/presentation/providers/report_providers.dart';
import '../../../transactions/domain/entities/transaction_record.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../transactions/presentation/pages/transaction_detail_page.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider(false));
    final dateRange = ref.watch(reportDateRangeProvider);
    final topProductsAsync = ref.watch(topProductsProvider(dateRange));

    return transactionsAsync.when(
      data: (items) {
        final filtered = items
            .where((item) => _isWithinRange(item.createdAt, dateRange))
            .toList();
        final totalRange = filtered.fold<int>(
          0,
          (sum, item) => sum + item.total,
        );

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _DateRangeCard(
              range: dateRange,
              onTap: () => _pickDateRange(context, ref, dateRange),
            ),
            const SizedBox(height: 12),
            _SummaryCard(
              totalRange: totalRange,
              totalTransactions: filtered.length,
            ),
            const SizedBox(height: 16),
            _TopProductsCard(topProductsAsync: topProductsAsync),
            const SizedBox(height: 16),
            Text(
              'Transaksi',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (filtered.isEmpty)
              const Center(child: Text('Belum ada transaksi pada periode ini.'))
            else
              ...filtered.map((record) => _TransactionTile(record: record)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Gagal memuat laporan.')),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalRange,
    required this.totalTransactions,
  });

  final int totalRange;
  final int totalTransactions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total periode',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Rp $totalRange'),
            const SizedBox(height: 12),
            Text('Total transaksi: $totalTransactions'),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.record});

  final TransactionRecord record;

  @override
  Widget build(BuildContext context) {
    final timeLabel = _formatDateTime(record.createdAt);
    final subtitle = '${record.paymentMethod} • $timeLabel';

    return ListTile(
      title: Text(record.trxNumber),
      subtitle: Text(subtitle),
      trailing: Text('Rp ${record.total}'),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionDetailPage(record: record),
          ),
        );
      },
    );
  }
}

class _DateRangeCard extends StatelessWidget {
  const _DateRangeCard({required this.range, required this.onTap});

  final DateTimeRange range;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('Periode Laporan'),
        subtitle: Text(_formatRange(range)),
        trailing: const Icon(Icons.date_range),
        onTap: onTap,
      ),
    );
  }
}

class _TopProductsCard extends StatelessWidget {
  const _TopProductsCard({required this.topProductsAsync});

  final AsyncValue<List<TopProduct>> topProductsAsync;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Produk',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            topProductsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Text('Belum ada data produk.');
                }
                return Column(
                  children: items
                      .map((item) => _TopProductRow(item: item))
                      .toList(),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Gagal memuat top produk.'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopProductRow extends StatelessWidget {
  const _TopProductRow({required this.item});

  final TopProduct item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(item.name)),
          Text('${item.qty}'),
          const SizedBox(width: 12),
          Text('Rp ${item.total}'),
        ],
      ),
    );
  }
}

bool _isWithinRange(DateTime date, DateTimeRange range) {
  return (date.isAfter(range.start) || _isSameDay(date, range.start)) &&
      (date.isBefore(range.end) || _isSameDay(date, range.end));
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatDateTime(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString().padLeft(4, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

String _formatRange(DateTimeRange range) {
  final start = _formatDate(range.start);
  final end = _formatDate(range.end);
  return '$start - $end';
}

String _formatDate(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString().padLeft(4, '0');
  return '$day/$month/$year';
}

Future<void> _pickDateRange(
  BuildContext context,
  WidgetRef ref,
  DateTimeRange current,
) async {
  final picked = await showDateRangePicker(
    context: context,
    initialDateRange: current,
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
  );
  if (picked == null) {
    return;
  }
  final end = DateTime(
    picked.end.year,
    picked.end.month,
    picked.end.day,
    23,
    59,
    59,
    999,
  );
  ref.read(reportDateRangeProvider.notifier).state = DateTimeRange(
        start: DateTime(picked.start.year, picked.start.month, picked.start.day),
        end: end,
      );
}
