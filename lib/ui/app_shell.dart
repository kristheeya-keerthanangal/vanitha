import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_navigation_rail.dart';
import 'dashboard_page.dart';
import 'subscribers_page.dart';
import 'view_models/app_shell_view_model.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(appShellViewModelProvider);
    final viewModel = ref.read(appShellViewModelProvider.notifier);

    return Scaffold(
      body: Row(
        children: [
          AppNavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: viewModel.selectDestination,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: selectedIndex == 1
                ? const SubscribersPage()
                : const DashboardPage(),
          ),
        ],
      ),
    );
  }
}
