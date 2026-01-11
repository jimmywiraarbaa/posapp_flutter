enum AuthStage {
  loading,
  setupPin,
  locked,
  unlocked,
}

class AuthState {
  const AuthState({
    required this.stage,
    required this.autoLockMinutes,
  });

  final AuthStage stage;
  final int autoLockMinutes;

  bool get isLocked => stage == AuthStage.locked;
  bool get needsSetup => stage == AuthStage.setupPin;

  AuthState copyWith({AuthStage? stage, int? autoLockMinutes}) {
    return AuthState(
      stage: stage ?? this.stage,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
    );
  }

  static AuthState loading() {
    return const AuthState(stage: AuthStage.loading, autoLockMinutes: 0);
  }
}
