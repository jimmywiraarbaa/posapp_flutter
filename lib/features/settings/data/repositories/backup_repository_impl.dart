import '../../domain/entities/backup_file.dart';
import '../../domain/repositories/backup_repository.dart';
import '../datasources/backup_local_data_source.dart';

class BackupRepositoryImpl implements BackupRepository {
  BackupRepositoryImpl(this._localDataSource);

  final BackupLocalDataSource _localDataSource;

  @override
  Future<String> createBackup() {
    return _localDataSource.createBackup();
  }

  @override
  Future<void> restoreBackup(String path) {
    return _localDataSource.restoreBackup(path);
  }

  @override
  Future<List<BackupFile>> listBackups() {
    return _localDataSource.listBackups();
  }
}
