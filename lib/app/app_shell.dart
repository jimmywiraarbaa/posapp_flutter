import 'package:flutter/material.dart';

import '../features/reports/presentation/pages/reports_page.dart';
import '../features/expenses/presentation/pages/expenses_page.dart';
import '../features/stock/presentation/pages/stock_page.dart';
import '../features/transactions/presentation/pages/pos_page.dart';
import 'more_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const _pages = <Widget>[
    PosPage(),
    StockPage(),
    ExpensesPage(),
    ReportsPage(),
    MorePage(),
  ];

  static const _navItems = <_NavItem>[
    _NavItem(icon: Icons.point_of_sale, label: 'Transaksi'),
    _NavItem(icon: Icons.inventory_2, label: 'Stok'),
    _NavItem(icon: Icons.payments, label: 'Pengeluaran'),
    _NavItem(icon: Icons.bar_chart, label: 'Laporan'),
    _NavItem(icon: Icons.more_horiz, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_navItems[_currentIndex].label)),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var index = 0; index < items.length; index++)
                  Expanded(
                    child: _BottomNavItem(
                      item: items[index],
                      isActive: index == currentIndex,
                      onTap: () => onTap(index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const activeDiameter = 64.0;
    const inactiveDiameter = 36.0;
    final iconColor =
        isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant;
    final labelColor =
        isActive ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: isActive ? activeDiameter : inactiveDiameter,
                height: isActive ? activeDiameter : inactiveDiameter,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? colorScheme.primary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: isActive
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item.icon, size: 22, color: iconColor),
                          const SizedBox(height: 2),
                          SizedBox(
                            width: activeDiameter - 12,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: iconColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Icon(item.icon, size: 20, color: iconColor),
              ),
              const SizedBox(height: 4),
              AnimatedOpacity(
                opacity: isActive ? 0 : 1,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
