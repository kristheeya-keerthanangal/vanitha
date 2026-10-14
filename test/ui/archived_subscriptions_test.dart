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
import 'package:vanithabodhini/ui/archived/view_models/archived_subscriptions_view_model.dart';

void main() {
  testWidgets(
    'archive list opens read-only details and supports direct links',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final database = AppDatabase(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(database)],
      );
      addTearDown(() async {
        container.dispose();
        await database.close();
      });
      final repository = SubscriptionRepository(database);
      late Subscription archived;
      late Subscription active;
      await tester.runAsync(() async {
        final subscriber = await SubscriberRepository(
          database,
        ).createSubscriber(name: 'Archived Reader');
        final subscription = await repository.createSubscription(
          subscriberId: subscriber.id,
          edition: 'online',
          planType: 'annual',
          durationYears: 1,
          startDate: DateTime(2026),
        );
        archived = await repository.archiveSubscription(subscription.id);
        active = await repository.createSubscription(
          subscriberId: subscriber.id,
          edition: 'offline',
          planType: 'annual',
          durationYears: 1,
          startDate: DateTime(2027),
        );
        await SubscriberRepository(database).archiveSubscriber(subscriber.id);
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const MainApp()),
      );
      await tester.tap(find.text('Archived'));
      await tester.pump();
      await tester.runAsync(
        () => container.read(archivedSubscriptionsViewModelProvider.future),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Subscription #${active.id} · Archived Reader'),
        findsNothing,
      );
      await tester.tap(
        find.text('Subscription #${archived.id} · Archived Reader'),
      );
      await tester.pump();
      await tester.runAsync(
        () => container.read(
          archivedSubscriptionDetailsViewModelProvider(archived.id).future,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Archived subscription details'), findsOneWidget);
      expect(find.text('Subscription #${archived.id}'), findsOneWidget);
      expect(find.text('Archived Reader'), findsOneWidget);
      expect(find.byTooltip('Archive subscription'), findsNothing);
      expect(find.text('Restore'), findsNothing);
      expect(find.text('Renew'), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
      await tester.ensureVisible(find.text('Archived at'));
      expect(find.text('Archived at'), findsOneWidget);
      await tester.tap(find.byTooltip('Back to archived subscriptions'));
      await tester.pump();
      await tester.runAsync(
        () => container.read(archivedSubscriptionsViewModelProvider.future),
      );
      await tester.pumpAndSettle();
      expect(find.text('Archived subscriptions'), findsOneWidget);

      container.read(routerProvider).go('/archived/${active.id}');
      await tester.pump();
      await tester.runAsync(
        () => container.read(
          archivedSubscriptionDetailsViewModelProvider(active.id).future,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Archived subscription not found.'), findsOneWidget);
      await tester.tap(find.byTooltip('Back to archived subscriptions'));
      await tester.pump();
      await tester.runAsync(
        () => container.read(archivedSubscriptionsViewModelProvider.future),
      );
      await tester.pumpAndSettle();
      expect(find.text('Archived subscriptions'), findsOneWidget);
      await tester.runAsync(() async {
        expect(
          await repository.getSubscription(archived.id, includeArchived: true),
          archived,
        );
      });
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('empty archive displays an empty state', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MainApp()),
    );
    await tester.tap(find.text('Archived'));
    await tester.pump();
    await tester.runAsync(
      () => container.read(archivedSubscriptionsViewModelProvider.future),
    );
    await tester.pumpAndSettle();
    expect(find.text('No archived subscriptions.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
