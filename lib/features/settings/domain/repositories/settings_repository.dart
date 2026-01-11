abstract class SettingsRepository {
  Future<int> getAutoLockMinutes();
  Future<void> setAutoLockMinutes(int minutes);
  Future<double> getFontScale();
  Future<void> setFontScale(double scale);
}
