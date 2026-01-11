import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../units/domain/entities/unit.dart';
import '../../../units/presentation/pages/unit_form_page.dart';
import '../../../units/presentation/providers/unit_providers.dart';

class UnitMasterTab extends ConsumerWidget {
  const UnitMasterTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(unitsStreamProvider(true));

    return unitsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('Belum ada satuan.'));
        }
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final unit = items[index];
            return _UnitTile(unit: unit);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Gagal memuat satuan.')),
    );
  }
}

class _UnitTile extends ConsumerWidget {
  const _UnitTile({required this.unit});

  final Unit unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = <String>[
      unit.symbol,
      if (!unit.isActive) 'Nonaktif',
    ].join(' • ');

    return ListTile(
      title: Text(unit.name),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: unit.isActive,
        onChanged: (value) {
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
