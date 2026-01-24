import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/presentation/pages/pin_gate_page.dart';
import '../features/settings/presentation/providers/auth_providers.dart';
import '../features/settings/presentation/providers/auth_state.dart';
import 'app_shell.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate>
    with WidgetsBindingObserver {
  DateTime? _backgroundedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final authState = ref.read(authControllerProvider);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (authState.stage == AuthStage.unlocked &&
          authState.autoLockMinutes > 0) {
        _backgroundedAt ??= DateTime.now();
      }
      return;
    }
    if (state == AppLifecycleState.resumed) {
      final notifier = ref.read(authControllerProvider.notifier);
      if (_backgroundedAt != null) {
        final elapsed = DateTime.now().difference(_backgroundedAt!);
        notifier.resumeFromBackground(elapsed);
      } else {
        notifier.registerActivity();
      }
      _backgroundedAt = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    if (authState.stage == AuthStage.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authState.needsSetup) {
      return const PinGatePage(isSetup: true);
    }

    if (authState.isLocked) {
      return const PinGatePage(isSetup: false);
    }

    return Listener(
      onPointerDown: (_) {
        ref.read(authControllerProvider.notifier).registerActivity();
      },
      child: const AppShell(),
    );
  }
}
