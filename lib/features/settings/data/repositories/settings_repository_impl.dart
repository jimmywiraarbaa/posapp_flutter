import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

const _autoLockKey = 'auto_lock_minutes';
const _defaultAutoLockMinutes = 5;
const _fontScaleKey = 'font_scale';
const _defaultFontScale = 1.0;

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

  @override
  Future<double> getFontScale() async {
    final value = await _localDataSource.getDouble(_fontScaleKey);
    return value ?? _defaultFontScale;
  }

  @override
  Future<void> setFontScale(double scale) {
    return _localDataSource.setDouble(_fontScaleKey, scale);
  }
}
