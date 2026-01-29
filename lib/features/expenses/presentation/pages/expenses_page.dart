import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/formatters/currency.dart';
import '../../domain/entities/expense.dart';
import '../providers/expense_providers.dart';
import 'expense_form_page.dart';

class ExpensesPage extends ConsumerWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesStreamProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ExpenseFormPage()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Pengeluaran'),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: expensesAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Text('Belum ada pengeluaran.'));
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final expense = items[index];
                  return _ExpenseTile(expense: expense);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) =>
                const Center(child: Text('Gagal memuat pengeluaran.')),
          ),
        ),
      ],
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      _formatDateTime(expense.createdAt),
      if (expense.note != null && expense.note!.trim().isNotEmpty)
        expense.note!.trim(),
    ];

    return ListTile(
      title: Text(expense.title),
      subtitle: Text(subtitleParts.join(' • ')),
      trailing: Text(formatRupiah(expense.amount)),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ExpenseFormPage(initialExpense: expense),
          ),
        );
      },
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
