import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../ui/app_shell.dart';
import '../ui/dashboard_page.dart';
import '../ui/settings_page.dart';
import '../ui/subscribers/subscribers_page.dart';
import '../ui/subscribers/subscriber_details_page.dart';
import '../ui/archived/archived_subscriptions_page.dart';
import '../ui/archived/archived_subscription_details_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(path: '/', redirect: (_, _) => '/dashboard'),
      ShellRoute(
        builder: (context, state, child) => AppShell(
          selectedIndex: state.uri.path.startsWith('/settings')
              ? 3
              : state.uri.path.startsWith('/archived')
              ? 2
              : state.uri.path.startsWith('/subscribers')
              ? 1
              : 0,
          child: child,
        ),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, _) => const DashboardPage()),
          GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
          GoRoute(
            path: '/archived',
            builder: (_, _) => const ArchivedSubscriptionsPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => ArchivedSubscriptionDetailsPage(
                  id: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/subscribers',
            builder: (_, _) => const SubscribersPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => SubscriberDetailsPage(
                  id: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
