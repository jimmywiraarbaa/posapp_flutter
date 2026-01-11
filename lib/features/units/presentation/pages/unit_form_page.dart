import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/id_generator.dart';
import '../../domain/entities/unit.dart';
import '../providers/unit_providers.dart';

class UnitFormPage extends ConsumerStatefulWidget {
  const UnitFormPage({super.key, this.initialUnit});

  final Unit? initialUnit;

  @override
  ConsumerState<UnitFormPage> createState() => _UnitFormPageState();
}

class _UnitFormPageState extends ConsumerState<UnitFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _symbolController;

  @override
  void initState() {
    super.initState();
    final unit = widget.initialUnit;
    _nameController = TextEditingController(text: unit?.name ?? '');
    _symbolController = TextEditingController(text: unit?.symbol ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final name = _nameController.text.trim();
    if (await _isNameDuplicate(name)) {
      _showMessage('Nama satuan sudah digunakan.');
      return;
    }
    final now = DateTime.now();
    final existing = widget.initialUnit;
    final unit = Unit(
      id: existing?.id ?? generateId(),
      name: name,
      symbol: _symbolController.text.trim(),
      isActive: existing?.isActive ?? true,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    await ref.read(upsertUnitProvider)(unit);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<bool> _isNameDuplicate(String name) async {
    final repo = ref.read(unitRepositoryProvider);
    final items = await repo.fetchAll(includeInactive: true);
    final normalized = name.toLowerCase();
    return items.any(
      (item) =>
          item.id != widget.initialUnit?.id &&
          item.name.trim().toLowerCase() == normalized,
    );
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialUnit == null ? 'Tambah Satuan' : 'Edit Satuan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Satuan'),
              validator: _validateRequired,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _symbolController,
              decoration: const InputDecoration(labelText: 'Simbol'),
              validator: _validateRequired,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
