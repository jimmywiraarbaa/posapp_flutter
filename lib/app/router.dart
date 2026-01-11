import 'package:flutter/material.dart';

import '../features/transactions/presentation/pages/pos_page.dart';

class AppRoutes {
  static const home = '/';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const PosPage());
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
