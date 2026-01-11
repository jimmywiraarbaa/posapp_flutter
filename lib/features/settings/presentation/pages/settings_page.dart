import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../providers/backup_providers.dart';
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
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Data'),
            onTap: () => _backupData(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Data'),
            onTap: () => _showRestoreSheet(context, ref),
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

Future<void> _backupData(BuildContext context, WidgetRef ref) async {
  try {
    final path = await ref.read(backupRepositoryProvider).createBackup();
    ref.invalidate(backupFilesProvider);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Backup tersimpan: $path')),
    );
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString())),
    );
  }
}

Future<void> _showRestoreSheet(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      return Consumer(
        builder: (context, ref, _) {
          final backupsAsync = ref.watch(backupFilesProvider);
          return backupsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Belum ada backup.'),
                );
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final backup = items[index];
                  return ListTile(
                    title: Text(backup.name),
                    subtitle: Text(
                      '${_formatDateTime(backup.modifiedAt)} • ${_formatSize(backup.sizeBytes)}',
                    ),
                    onTap: () => _confirmRestore(context, ref, backup.path),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Gagal memuat daftar backup.'),
            ),
          );
        },
      );
    },
  );
}

Future<void> _confirmRestore(
  BuildContext context,
  WidgetRef ref,
  String path,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Restore Data'),
      content: const Text('Restore akan mengganti data saat ini. Lanjutkan?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Restore'),
        ),
      ],
    ),
  );

  if (confirmed != true) {
    return;
  }

  try {
    await ref.read(backupRepositoryProvider).restoreBackup(path);
    ref.invalidate(backupFilesProvider);
    await ref.read(authControllerProvider.notifier).reload();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restore selesai. Silakan masuk PIN lagi.')),
    );
    Navigator.of(context).pop();
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString())),
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString().padLeft(4, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

String _formatSize(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
