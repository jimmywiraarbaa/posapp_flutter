import 'package:flutter/material.dart';

import '../../../categories/presentation/pages/category_form_page.dart';
import '../../../products/presentation/pages/product_form_page.dart';
import '../../../units/presentation/pages/unit_form_page.dart';
import '../widgets/category_master_tab.dart';
import '../widgets/product_master_tab.dart';
import '../widgets/unit_master_tab.dart';

class DataMasterPage extends StatefulWidget {
  const DataMasterPage({super.key});

  @override
  State<DataMasterPage> createState() => _DataMasterPageState();
}

class _DataMasterPageState extends State<DataMasterPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openForm() {
    final route = switch (_tabController.index) {
      0 => MaterialPageRoute(builder: (_) => const ProductFormPage()),
      1 => MaterialPageRoute(builder: (_) => const UnitFormPage()),
      _ => MaterialPageRoute(builder: (_) => const CategoryFormPage()),
    };
    Navigator.of(context).push(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Master'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Produk'),
            Tab(text: 'Satuan'),
            Tab(text: 'Kategori'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ProductMasterTab(),
          UnitMasterTab(),
          CategoryMasterTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
