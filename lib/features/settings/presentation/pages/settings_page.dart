import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import 'change_pin_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final autoLockLabel = _formatAutoLock(authState.autoLockMinutes);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Ganti PIN'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangePinPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Auto-lock'),
            subtitle: Text(autoLockLabel),
            onTap: () => _showAutoLockPicker(context, ref),
          ),
        ],
      ),
    );
  }
}

String _formatAutoLock(int minutes) {
  if (minutes <= 0) {
    return 'Nonaktif';
  }
  return '$minutes menit';
}

Future<void> _showAutoLockPicker(BuildContext context, WidgetRef ref) async {
  const options = <int>[0, 1, 3, 5, 10, 30];
  final selected = await showModalBottomSheet<int>(
    context: context,
    builder: (sheetContext) => ListView(
      children: options
          .map(
            (value) => ListTile(
              title: Text(value == 0 ? 'Nonaktif' : '$value menit'),
              onTap: () => Navigator.of(sheetContext).pop(value),
            ),
          )
          .toList(),
    ),
  );

  if (selected == null) {
    return;
  }
  await ref.read(authControllerProvider.notifier).updateAutoLockMinutes(selected);
}
