import 'package:flutter/material.dart';

import 'router.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.storage),
          title: const Text('Data Master'),
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.dataMaster),
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Pengaturan'),
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
        ),
      ],
    );
  }
}
