import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/database_provider.dart';
import '../../data/datasources/pin_local_data_source.dart';
import '../../data/datasources/settings_local_data_source.dart';
import '../../data/repositories/pin_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/pin_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import 'auth_controller.dart';
import 'auth_state.dart';

final pinRepositoryProvider = Provider<PinRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PinRepositoryImpl(PinLocalDataSource(db));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SettingsRepositoryImpl(SettingsLocalDataSource(db));
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final pinRepository = ref.watch(pinRepositoryProvider);
    final settingsRepository = ref.watch(settingsRepositoryProvider);
    return AuthController(pinRepository, settingsRepository);
  },
);
