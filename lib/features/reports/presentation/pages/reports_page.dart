import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transactions/domain/entities/transaction_record.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../transactions/presentation/pages/transaction_detail_page.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider(false));

    return transactionsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('Belum ada transaksi.'));
        }
        final now = DateTime.now();
        final todayTotal = items
            .where((item) => _isSameDay(item.createdAt, now))
            .fold<int>(0, (sum, item) => sum + item.total);

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: items.length + 1,
          separatorBuilder: (_, index) {
            if (index == 0) {
              return const SizedBox(height: 16);
            }
            return const Divider(height: 1);
          },
          itemBuilder: (context, index) {
            if (index == 0) {
              return _SummaryCard(
                totalToday: todayTotal,
                totalTransactions: items.length,
              );
            }
            final record = items[index - 1];
            return _TransactionTile(record: record);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Gagal memuat laporan.')),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalToday,
    required this.totalTransactions,
  });

  final int totalToday;
  final int totalTransactions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total hari ini', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Rp $totalToday'),
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
