import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';
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

  testWidgets('status segments render only subscribers matching their status', (
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
    final subscribers = SubscriberRepository(database);
    final subscriptions = SubscriptionRepository(database);
    late int activeId;
    late int expiresTodayId;
    late int expiredId;
    late int mixedId;
    await tester.runAsync(() async {
      final today = DateTime.now();
      final dateOnly = DateTime(today.year, today.month, today.day);
      final active = await subscribers.createSubscriber(
        name: 'Active Filter Reader',
      );
      final expiresToday = await subscribers.createSubscriber(
        name: 'Expires Today Filter Reader',
      );
      final expired = await subscribers.createSubscriber(
        name: 'Expired Filter Reader',
      );
      await subscribers.createSubscriber(name: 'No Subscription Filter Reader');
      final mixed = await subscribers.createSubscriber(
        name: 'Mixed Filter Reader',
      );
      final archivedOnly = await subscribers.createSubscriber(
        name: 'Archived Only Filter Reader',
      );
      activeId = active.id;
      expiresTodayId = expiresToday.id;
      expiredId = expired.id;
      mixedId = mixed.id;
      await subscriptions.createSubscription(
        subscriberId: active.id,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startDate: today.add(const Duration(days: 30)),
      );
      await subscriptions.createSubscription(
        subscriberId: expiresToday.id,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startDate: DateTime(dateOnly.year - 1, dateOnly.month, dateOnly.day),
      );
      await subscriptions.createSubscription(
        subscriberId: expired.id,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startDate: DateTime(today.year - 3, today.month, today.day),
      );
      await subscriptions.createSubscription(
        subscriberId: mixed.id,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startDate: DateTime(today.year - 3, today.month, today.day),
      );
      await subscriptions.createSubscription(
        subscriberId: mixed.id,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startDate: today.add(const Duration(days: 30)),
      );
      final archived = await subscriptions.createSubscription(
        subscriberId: archivedOnly.id,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startDate: DateTime(today.year - 3, today.month, today.day),
      );
      await subscriptions.archiveSubscription(archived.id);
    });

    container.read(routerProvider).go('/subscribers');
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MainApp()),
    );
    final model = container.read(subscribersViewModelProvider);
    await tester.runAsync(model.refresh);
    await tester.pumpAndSettle();
    expect(model.total, 6);
    expect(find.text('Active Filter Reader'), findsOneWidget);
    expect(find.text('Expired Filter Reader'), findsOneWidget);

    await tester.tap(find.text('Active').first);
    await tester.runAsync(model.refresh);
    await tester.pumpAndSettle();
    expect(model.selectedFilter, SubscriberFilter.active);
    expect(model.total, 3);
    expect(model.rows.map((subscriber) => subscriber.id).toSet(), {
      activeId,
      expiresTodayId,
      mixedId,
    });
    expect(find.text('Active Filter Reader'), findsOneWidget);
    expect(find.text('Expires Today Filter Reader'), findsOneWidget);
    expect(find.text('Mixed Filter Reader'), findsOneWidget);
    expect(find.text('Expired Filter Reader'), findsNothing);
    expect(find.text('No Subscription Filter Reader'), findsNothing);

    await tester.tap(find.text('Expired').first);
    await tester.runAsync(model.refresh);
    await tester.pumpAndSettle();

    expect(model.selectedFilter, SubscriberFilter.expired);
    expect(model.total, 1);
    expect(model.rows.single.id, expiredId);
    expect(find.text('Expired Filter Reader'), findsOneWidget);
    expect(find.text('Active Filter Reader'), findsNothing);
    expect(find.text('Expires Today Filter Reader'), findsNothing);
    expect(find.text('Mixed Filter Reader'), findsNothing);
    expect(find.text('No Subscription Filter Reader'), findsNothing);
    expect(find.text('Archived Only Filter Reader'), findsNothing);
    expect(
      model.rows.map((subscriber) => subscriber.id),
      isNot(contains(activeId)),
    );
    await tester.pumpWidget(const SizedBox());
  });
}
