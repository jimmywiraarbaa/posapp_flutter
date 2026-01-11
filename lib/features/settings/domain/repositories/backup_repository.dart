import '../entities/backup_file.dart';

abstract class BackupRepository {
  Future<String> createBackup();

  Future<void> restoreBackup(String path);

  Future<List<BackupFile>> listBackups();
}
