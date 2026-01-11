import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/database_provider.dart';
import '../../data/datasources/backup_local_data_source.dart';
import '../../data/repositories/backup_repository_impl.dart';
import '../../domain/entities/backup_file.dart';
import '../../domain/repositories/backup_repository.dart';

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BackupRepositoryImpl(BackupLocalDataSource(db));
});

final backupFilesProvider = FutureProvider<List<BackupFile>>((ref) {
  final repo = ref.watch(backupRepositoryProvider);
  return repo.listBackups();
});
