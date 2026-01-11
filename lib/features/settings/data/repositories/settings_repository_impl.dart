import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

const _autoLockKey = 'auto_lock_minutes';
const _defaultAutoLockMinutes = 5;

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._localDataSource);

  final SettingsLocalDataSource _localDataSource;

  @override
  Future<int> getAutoLockMinutes() async {
    final value = await _localDataSource.getInt(_autoLockKey);
    return value ?? _defaultAutoLockMinutes;
  }

  @override
  Future<void> setAutoLockMinutes(int minutes) {
    return _localDataSource.setInt(_autoLockKey, minutes);
  }
}
