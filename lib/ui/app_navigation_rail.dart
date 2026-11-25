import 'package:material_ui/material_ui.dart';

class AppNavigationRail extends StatelessWidget {
  const AppNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const destinations = [
    _AppDestination(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
    ),
    _AppDestination(
      label: 'Subscribers',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
    ),
    _AppDestination(
      label: 'Archived',
      icon: Icons.archive_outlined,
      selectedIcon: Icons.archive,
    ),
    _AppDestination(
      label: 'Mailing list',
      icon: Icons.local_post_office_outlined,
      selectedIcon: Icons.local_post_office,
    ),
    _AppDestination(
      label: 'Postal offices',
      icon: Icons.markunread_mailbox_outlined,
      selectedIcon: Icons.markunread_mailbox,
    ),
    _AppDestination(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Icon(
          Icons.menu_book_outlined,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
      ),
      destinations: [
        for (final item in destinations)
          NavigationRailDestination(
            icon: _pointerTarget(Icon(item.icon)),
            selectedIcon: _pointerTarget(Icon(item.selectedIcon)),
            label: Text(item.label),
          ),
      ],
    );
  }

  Widget _pointerTarget(Widget child) {
    return MouseRegion(cursor: SystemMouseCursors.click, child: child);
  }
}

class _AppDestination {
  const _AppDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
