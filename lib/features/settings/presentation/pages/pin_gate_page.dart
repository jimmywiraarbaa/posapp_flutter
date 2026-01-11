import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';

class PinGatePage extends ConsumerStatefulWidget {
  const PinGatePage({super.key, required this.isSetup});

  final bool isSetup;

  @override
  ConsumerState<PinGatePage> createState() => _PinGatePageState();
}

class _PinGatePageState extends ConsumerState<PinGatePage> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      if (widget.isSetup) {
        await ref.read(authControllerProvider.notifier).setPin(
              _pinController.text.trim(),
            );
      } else {
        await ref.read(authControllerProvider.notifier).verifyPin(
              _pinController.text.trim(),
            );
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
    if (value.trim() != _pinController.text.trim()) {
      return 'Konfirmasi PIN tidak cocok.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.isSetup ? 'Buat PIN' : 'Masukkan PIN',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pinController,
                    decoration: const InputDecoration(labelText: 'PIN'),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    validator: _validatePin,
                  ),
                  if (widget.isSetup) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmController,
                      decoration: const InputDecoration(labelText: 'Konfirmasi PIN'),
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      validator: _validateConfirm,
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submit,
                    child: Text(widget.isSetup ? 'Simpan PIN' : 'Masuk'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
