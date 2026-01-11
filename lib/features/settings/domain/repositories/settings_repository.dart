abstract class SettingsRepository {
  Future<int> getAutoLockMinutes();
  Future<void> setAutoLockMinutes(int minutes);
}
