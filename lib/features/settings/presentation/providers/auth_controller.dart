import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/pin_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import 'auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._pinRepository, this._settingsRepository)
      : super(AuthState.loading()) {
    _initialize();
  }

  final PinRepository _pinRepository;
  final SettingsRepository _settingsRepository;
  Timer? _timer;

  Future<void> _initialize() async {
    final minutes = await _settingsRepository.getAutoLockMinutes();
    final hasPin = await _pinRepository.hasPin();

    state = AuthState(
      stage: hasPin ? AuthStage.locked : AuthStage.setupPin,
      autoLockMinutes: minutes,
    );
  }

  Future<void> verifyPin(String pin) async {
    final valid = await _pinRepository.verifyPin(pin);
    if (!valid) {
      throw StateError('PIN salah.');
    }
    _unlock();
  }

  Future<void> setPin(String pin) async {
    await _pinRepository.setPin(pin);
    _unlock();
  }

  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    final valid = await _pinRepository.verifyPin(currentPin);
    if (!valid) {
      throw StateError('PIN lama salah.');
    }
    await _pinRepository.setPin(newPin);
  }

  void lock() {
    if (state.stage == AuthStage.unlocked) {
      _timer?.cancel();
      state = state.copyWith(stage: AuthStage.locked);
    }
  }

  void registerActivity() {
    if (state.stage != AuthStage.unlocked) {
      return;
    }
    _resetTimer();
  }

  Future<void> updateAutoLockMinutes(int minutes) async {
    await _settingsRepository.setAutoLockMinutes(minutes);
    state = state.copyWith(autoLockMinutes: minutes);
    if (state.stage == AuthStage.unlocked) {
      _resetTimer();
    }
  }

  void _unlock() {
    state = state.copyWith(stage: AuthStage.unlocked);
    _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    final minutes = state.autoLockMinutes;
    if (minutes <= 0) {
      return;
    }
    _timer = Timer(Duration(minutes: minutes), lock);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
