import 'package:flutter/material.dart';

class DataMasterPage extends StatelessWidget {
  const DataMasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Data Master'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Produk'),
              Tab(text: 'Satuan'),
              Tab(text: 'Kategori'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MasterListPlaceholder(
              title: 'Produk',
              emptyMessage: 'Belum ada produk.',
            ),
            MasterListPlaceholder(
              title: 'Satuan',
              emptyMessage: 'Belum ada satuan.',
            ),
            MasterListPlaceholder(
              title: 'Kategori',
              emptyMessage: 'Belum ada kategori.',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class MasterListPlaceholder extends StatelessWidget {
  const MasterListPlaceholder({
    super.key,
    required this.title,
    required this.emptyMessage,
  });

  final String title;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox, size: 40, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            emptyMessage,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
