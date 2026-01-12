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
  static const _pinLength = 6;
  String _pin = '';
  String _confirm = '';
  bool _isConfirming = false;
  bool _isSubmitting = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _appendDigit(String digit) {
    if (_isSubmitting) {
      return;
    }
    final current = _isConfirming ? _confirm : _pin;
    if (current.length >= _pinLength) {
      return;
    }
    final next = '$current$digit';
    setState(() {
      if (_isConfirming) {
        _confirm = next;
      } else {
        _pin = next;
      }
    });
    if (next.length == _pinLength) {
      widget.isSetup ? _handleSetupComplete() : _submitVerify(next);
    }
  }

  void _removeDigit() {
    if (_isSubmitting) {
      return;
    }
    final current = _isConfirming ? _confirm : _pin;
    if (current.isEmpty) {
      return;
    }
    final next = current.substring(0, current.length - 1);
    setState(() {
      if (_isConfirming) {
        _confirm = next;
      } else {
        _pin = next;
      }
    });
  }

  void _handleSetupComplete() {
    if (!_isConfirming) {
      setState(() {
        _isConfirming = true;
        _confirm = '';
      });
      return;
    }

    if (_confirm != _pin) {
      _showMessage('Konfirmasi PIN tidak cocok.');
      setState(() {
        _pin = '';
        _confirm = '';
        _isConfirming = false;
      });
      return;
    }
    _submitSetup(_pin);
  }

  Future<void> _submitSetup(String pin) async {
    try {
      setState(() => _isSubmitting = true);
      await ref.read(authControllerProvider.notifier).setPin(pin);
    } catch (error) {
      _showMessage(error.toString());
      setState(() {
        _pin = '';
        _confirm = '';
        _isConfirming = false;
        _isSubmitting = false;
      });
      return;
    }
  }

  Future<void> _submitVerify(String pin) async {
    try {
      setState(() => _isSubmitting = true);
      await ref.read(authControllerProvider.notifier).verifyPin(pin);
    } catch (error) {
      _showMessage(error.toString());
      setState(() {
        _pin = '';
        _isSubmitting = false;
      });
    }
  }

  String get _activeInput => _isConfirming ? _confirm : _pin;

  String get _titleText {
    if (widget.isSetup) {
      return _isConfirming ? 'Konfirmasi PIN' : 'Buat PIN';
    }
    return 'Masukkan PIN';
  }

  String get _subtitleText {
    if (widget.isSetup) {
      return _isConfirming
          ? 'Masukkan ulang PIN 6 digit.'
          : 'Buat PIN 6 digit untuk keamanan.';
    }
    return 'Masukkan PIN 6 digit untuk melanjutkan.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LockHeader(title: _titleText, subtitle: _subtitleText),
                        const SizedBox(height: 20),
                        _PinDots(
                          length: _pinLength,
                          filled: _activeInput.length,
                        ),
                        const SizedBox(height: 24),
                        _PinKeypad(
                          onDigit: _appendDigit,
                          onBackspace: _removeDigit,
                          disabled: _isSubmitting,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LockHeader extends StatelessWidget {
  const _LockHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_rounded,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({required this.length, required this.filled});

  final int length;
  final int filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.outlineVariant;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isFilled = index < filled;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? activeColor : Colors.transparent,
            border: Border.all(color: inactiveColor, width: 1.5),
          ),
        );
      }),
    );
  }
}

class _PinKeypad extends StatelessWidget {
  const _PinKeypad({
    required this.onDigit,
    required this.onBackspace,
    required this.disabled,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _KeyRow(
          children: [
            _KeyButton(label: '1', onTap: () => onDigit('1'), disabled: disabled),
            _KeyButton(label: '2', onTap: () => onDigit('2'), disabled: disabled),
            _KeyButton(label: '3', onTap: () => onDigit('3'), disabled: disabled),
          ],
        ),
        const SizedBox(height: 12),
        _KeyRow(
          children: [
            _KeyButton(label: '4', onTap: () => onDigit('4'), disabled: disabled),
            _KeyButton(label: '5', onTap: () => onDigit('5'), disabled: disabled),
            _KeyButton(label: '6', onTap: () => onDigit('6'), disabled: disabled),
          ],
        ),
        const SizedBox(height: 12),
        _KeyRow(
          children: [
            _KeyButton(label: '7', onTap: () => onDigit('7'), disabled: disabled),
            _KeyButton(label: '8', onTap: () => onDigit('8'), disabled: disabled),
            _KeyButton(label: '9', onTap: () => onDigit('9'), disabled: disabled),
          ],
        ),
        const SizedBox(height: 12),
        _KeyRow(
          children: [
            const SizedBox(width: 80, height: 80),
            _KeyButton(label: '0', onTap: () => onDigit('0'), disabled: disabled),
            _KeyButton(
              icon: Icons.backspace_outlined,
              onTap: onBackspace,
              disabled: disabled,
            ),
          ],
        ),
      ],
    );
  }
}

class _KeyRow extends StatelessWidget {
  const _KeyRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children,
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    this.label,
    this.icon,
    required this.onTap,
    required this.disabled,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 72,
      height: 72,
      child: OutlinedButton(
        onPressed: disabled ? null : onTap,
        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: icon != null
            ? Icon(icon, color: theme.colorScheme.onSurface)
            : Text(
                label ?? '',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
