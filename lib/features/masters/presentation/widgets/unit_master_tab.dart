import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../units/domain/entities/unit.dart';
import '../../../units/presentation/pages/unit_form_page.dart';
import '../../../units/presentation/providers/unit_providers.dart';
import '../../../products/presentation/providers/product_providers.dart';

class UnitMasterTab extends ConsumerWidget {
  const UnitMasterTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(unitsStreamProvider(true));
    final activeProductsAsync = ref.watch(productsStreamProvider(false));

    if (unitsAsync.isLoading || activeProductsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (unitsAsync.hasError) {
      return const Center(child: Text('Gagal memuat satuan.'));
    }

    if (activeProductsAsync.hasError) {
      return const Center(child: Text('Gagal memuat produk aktif.'));
    }

    final units = unitsAsync.value ?? const <Unit>[];
    final activeProducts = activeProductsAsync.value ?? const [];
    final activeUnitIds = {
      for (final product in activeProducts) product.unitId,
    };

    if (units.isEmpty) {
      return const Center(child: Text('Belum ada satuan.'));
    }

    return ListView.separated(
      itemCount: units.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final unit = units[index];
        return _UnitTile(
          unit: unit,
          isInUse: activeUnitIds.contains(unit.id),
        );
      },
    );
  }
}

class _UnitTile extends ConsumerWidget {
  const _UnitTile({required this.unit, required this.isInUse});

  final Unit unit;
  final bool isInUse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = <String>[
      unit.symbol,
      if (!unit.isActive) 'Nonaktif',
      if (isInUse) 'Dipakai produk aktif',
    ].join(' • ');

    return ListTile(
      title: Text(unit.name),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: unit.isActive,
        onChanged: (value) {
          if (!value && isInUse) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tidak bisa menonaktifkan satuan yang dipakai.'),
              ),
            );
            return;
          }
          ref.read(setUnitActiveProvider)(unit.id, value);
        },
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => UnitFormPage(initialUnit: unit),
          ),
        );
      },
    );
  }
}
