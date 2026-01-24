import 'package:flutter/material.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Belum ada data pengeluaran.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
