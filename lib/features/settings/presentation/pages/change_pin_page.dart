import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';

class ChangePinPage extends ConsumerStatefulWidget {
  const ChangePinPage({super.key});

  @override
  ConsumerState<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends ConsumerState<ChangePinPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref.read(authControllerProvider.notifier).changePin(
            currentPin: _currentController.text.trim(),
            newPin: _newController.text.trim(),
          );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? _validatePin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi.';
    }
    if (!RegExp(r'^\d{4,6}$').hasMatch(value.trim())) {
      return 'PIN harus 4-6 digit angka.';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi.';
    }
    if (value.trim() != _newController.text.trim()) {
      return 'Konfirmasi PIN tidak cocok.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ganti PIN')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _currentController,
              decoration: const InputDecoration(labelText: 'PIN Lama'),
              obscureText: true,
              keyboardType: TextInputType.number,
              validator: _validatePin,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newController,
              decoration: const InputDecoration(labelText: 'PIN Baru'),
              obscureText: true,
              keyboardType: TextInputType.number,
              validator: _validatePin,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmController,
              decoration: const InputDecoration(labelText: 'Konfirmasi PIN Baru'),
              obscureText: true,
              keyboardType: TextInputType.number,
              validator: _validateConfirm,
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
