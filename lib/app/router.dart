import 'package:flutter/material.dart';

import '../features/masters/presentation/pages/data_master_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import 'app_shell.dart';

class AppRoutes {
  static const home = '/';
  static const dataMaster = '/data-master';
  static const settings = '/settings';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const AppShell());
      case AppRoutes.dataMaster:
        return MaterialPageRoute(builder: (_) => const DataMasterPage());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      default:
        return MaterialPageRoute(builder: (_) => const UnknownRoutePage());
    }
  }
}

class UnknownRoutePage extends StatelessWidget {
  const UnknownRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Page not found')),
    );
  }
}
