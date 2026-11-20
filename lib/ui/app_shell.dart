import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import 'app_navigation_rail.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.selectedIndex, required this.child});
  final int selectedIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppNavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) => context.go(switch (index) {
              1 => '/subscribers',
              2 => '/archived',
              3 => '/mailing-list',
              4 => '/settings',
              _ => '/dashboard',
            }),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
