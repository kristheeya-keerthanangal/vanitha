import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../ui/app_shell.dart';
import '../ui/dashboard_page.dart';
import '../ui/settings_page.dart';
import '../ui/subscribers/subscribers_page.dart';
import '../ui/subscribers/subscriber_details_page.dart';
import '../ui/archived/archived_subscriptions_page.dart';
import '../ui/archived/archived_subscription_details_page.dart';
import '../ui/mailing_list/mailing_list_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(path: '/', redirect: (_, _) => '/dashboard'),
      ShellRoute(
        pageBuilder: (context, state, child) => _noTransitionPage(
          state,
          AppShell(
            selectedIndex: state.uri.path.startsWith('/settings')
                ? 4
                : state.uri.path.startsWith('/mailing-list')
                ? 3
                : state.uri.path.startsWith('/archived')
                ? 2
                : state.uri.path.startsWith('/subscribers')
                ? 1
                : 0,
            child: child,
          ),
        ),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (_, state) =>
                _noTransitionPage(state, const DashboardPage()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (_, state) =>
                _noTransitionPage(state, const SettingsPage()),
          ),
          GoRoute(
            path: '/mailing-list',
            pageBuilder: (_, state) =>
                _noTransitionPage(state, const MailingListPage()),
          ),
          GoRoute(
            path: '/archived',
            pageBuilder: (_, state) =>
                _noTransitionPage(state, const ArchivedSubscriptionsPage()),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (_, state) => _noTransitionPage(
                  state,
                  ArchivedSubscriptionDetailsPage(
                    id: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/subscribers',
            pageBuilder: (_, state) =>
                _noTransitionPage(state, const SubscribersPage()),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (_, state) => _noTransitionPage(
                  state,
                  SubscriberDetailsPage(
                    id: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
                  ),
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

NoTransitionPage<void> _noTransitionPage(GoRouterState state, Widget child) =>
    NoTransitionPage<void>(key: state.pageKey, child: child);
