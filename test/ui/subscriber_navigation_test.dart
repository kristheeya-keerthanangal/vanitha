import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscription_repository.dart';
import 'package:vanithabodhini/main.dart';
import 'package:vanithabodhini/providers/database_provider.dart';
import 'package:vanithabodhini/providers/router_provider.dart';
import 'package:vanithabodhini/ui/subscribers/view_models/subscribers_view_model.dart';
import 'package:vanithabodhini/ui/subscribers/view_models/subscriber_details_view_model.dart';

void main() {
  testWidgets('table and details work in a narrow dark layout', (tester) async {
    tester.view.physicalSize = const Size(480, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final database = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });
    await tester.runAsync(() async {
      await database
          .into(database.subscribers)
          .insert(SubscribersCompanion.insert(name: 'Narrow Reader'));
    });
    container.read(routerProvider).go('/subscribers');
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MainApp()),
    );
    await tester.runAsync(container.read(subscribersViewModelProvider).refresh);
    await tester.pumpAndSettle();
    expect(find.text('Search subscribers'), findsOneWidget);
    expect(find.text('Enter Name, email or phone'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byType(PaginatedDataTable), findsOneWidget);
    expect(tester.takeException(), isNull);
    container.read(routerProvider).go('/subscribers/1');
    await tester.pump();
    await tester.runAsync(
      () => container.read(subscriberDetailsViewModelProvider(1).future),
    );
    await tester.pumpAndSettle();
    expect(find.text('Narrow Reader'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('No subscriptions.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('page controls, row navigation and back retain list state', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });
    await tester.runAsync(() async {
      await database.batch(
        (batch) => batch.insertAll(database.subscribers, [
          for (var i = 0; i < 55; i++)
            SubscribersCompanion.insert(
              name: 'Reader ${i.toString().padLeft(3, '0')}',
            ),
        ]),
      );
      await SubscriptionRepository(database).createSubscription(
        subscriberId: 26,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startDate: DateTime(2026, 1, 1),
        paymentStatus: 'paid',
      );
    });
    container.read(routerProvider).go('/subscribers');
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MainApp()),
    );
    final model = container.read(subscribersViewModelProvider);
    await tester.runAsync(model.refresh);
    await tester.pumpAndSettle();
    expect(find.text('Reader 000'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Next page'));
    await tester.tap(find.byTooltip('Next page'));
    await tester.runAsync(model.refresh);
    await tester.pumpAndSettle();
    expect(model.offset, 25);
    await tester.ensureVisible(find.text('Reader 025'));
    await tester.tap(find.text('Reader 025'));
    await tester.pump();
    await tester.runAsync(
      () => container.read(subscriberDetailsViewModelProvider(26).future),
    );
    await tester.pumpAndSettle();
    expect(container.read(routerProvider).state.uri.path, '/subscribers/26');
    expect(find.text('Reader 025'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('2027-01-01'), findsOneWidget);
    await tester.tap(find.byTooltip('Back to subscribers'));
    await tester.pumpAndSettle();
    expect(model.offset, 25);
    expect(find.text('Reader 025'), findsOneWidget);
    expect(find.text('Reader 000'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('direct details show missing state and back falls back to list', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });
    container.read(routerProvider).go('/subscribers/999');
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MainApp()),
    );
    await tester.runAsync(
      () => container.read(subscriberDetailsViewModelProvider(999).future),
    );
    await tester.pumpAndSettle();
    expect(find.text('Subscriber not found.'), findsOneWidget);
    await tester.tap(find.byTooltip('Back to subscribers'));
    final model = container.read(subscribersViewModelProvider);
    await tester.runAsync(model.refresh);
    await tester.pumpAndSettle();
    expect(
      container.read(routerProvider).routeInformationProvider.value.uri.path,
      '/subscribers',
    );
    expect(
      find.text('Add your first subscriber to get started.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });
}
