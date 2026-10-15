import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/providers/database_provider.dart';
import 'package:vanithabodhini/main.dart';
import 'package:vanithabodhini/providers/router_provider.dart';
import 'package:vanithabodhini/ui/settings_page.dart';

void main() {
  testWidgets('opens settings from the last navigation destination', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MainApp(),
      ),
    );

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect((rail.destinations.last.label as Text).data, 'Settings');

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.text('Import subscribers'), findsOneWidget);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      3,
    );

    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsNothing);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      0,
    );
  });

  testWidgets('opens the settings route directly with settings selected', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    container.read(routerProvider).go('/settings');

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MainApp()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      3,
    );
  });

  testWidgets('switches between dashboard and subscribers', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MainApp(),
      ),
    );

    expect(find.text('Dashboard'), findsNWidgets(2));
    expect(find.text('Subscribers'), findsOneWidget);
    expect(find.byIcon(Icons.dashboard), findsNWidgets(2));

    await tester.tap(find.text('Subscribers'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(find.text('Subscribers'), findsNWidgets(2));
    expect(find.byIcon(Icons.people), findsOneWidget);
  });
}
