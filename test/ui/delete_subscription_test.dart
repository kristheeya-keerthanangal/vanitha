import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';
import 'package:vanithabodhini/data/repositories/subscription_repository.dart';
import 'package:vanithabodhini/providers/database_provider.dart';
import 'package:vanithabodhini/ui/subscribers/widgets/subscription_details_card.dart';
import 'package:vanithabodhini/ui/subscribers/widgets/subscriber_subscriptions_section.dart';
import 'package:vanithabodhini/ui/subscribers/view_models/subscriber_details_view_model.dart';

void main() {
  testWidgets(
    'only the tail has an archive button, and archiving reveals the next',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(database)],
      );
      addTearDown(() async {
        container.dispose();
        await database.close();
      });
      final repository = SubscriptionRepository(database);
      late int subscriberId;
      final rows = <Subscription>[];
      await tester.runAsync(() async {
        subscriberId = (await SubscriberRepository(
          database,
        ).createSubscriber(name: 'Reader')).id;
        for (final year in [2024, 2025, 2026]) {
          rows.add(
            await repository.createSubscription(
              subscriberId: subscriberId,
              edition: 'online',
              planType: 'annual',
              durationYears: 1,
              startDate: DateTime(year),
            ),
          );
        }
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final details = ref.watch(
                    subscriberDetailsViewModelProvider(subscriberId),
                  );
                  return ListView(
                    children: [
                      if (details.asData?.value case final value?)
                        SubscriberSubscriptionsSection(
                          subscriptions: value.subscriptions,
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(
        () => container.read(
          subscriberDetailsViewModelProvider(subscriberId).future,
        ),
      );
      await tester.pumpAndSettle();
      void expectTail(int id) {
        expect(find.byTooltip('Archive subscription'), findsOneWidget);
        final card = find.byWidgetPredicate(
          (widget) =>
              widget is SubscriptionDetailsCard && widget.subscription.id == id,
        );
        expect(
          find.descendant(
            of: card,
            matching: find.byTooltip('Archive subscription'),
          ),
          findsOneWidget,
        );
      }

      expectTail(rows.last.id);
      for (final row in rows.reversed) {
        expectTail(row.id);
        await tester.ensureVisible(find.byTooltip('Archive subscription'));
        await tester.tap(find.byTooltip('Archive subscription'));
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          await tester.tap(find.text('Archive'));
        });
        await tester.runAsync(
          () => container.read(
            subscriberDetailsViewModelProvider(subscriberId).future,
          ),
        );
        await tester.pumpAndSettle();
      }
      expect(find.byTooltip('Archive subscription'), findsNothing);
      expect(find.text('No subscriptions.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'delete confirms, cancellation preserves row, confirmation archives it',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(database)],
      );
      addTearDown(() async {
        container.dispose();
        await database.close();
      });
      final repository = SubscriptionRepository(database);
      late Subscription subscription;
      await tester.runAsync(() async {
        final subscriber = await SubscriberRepository(
          database,
        ).createSubscriber(name: 'Reader');
        subscription = await repository.createSubscription(
          subscriberId: subscriber.id,
          edition: 'online',
          planType: 'annual',
          durationYears: 1,
          startDate: DateTime(2026, 1, 1),
        );
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: SubscriptionDetailsCard(
                subscription: subscription,
                canArchive: true,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byTooltip('Archive subscription'));
      await tester.pumpAndSettle();
      expect(find.text('Archive subscription?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        expect(await repository.getSubscription(subscription.id), subscription);
      });
      await tester.tap(find.byTooltip('Archive subscription'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.text('Archive'));
      });
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        expect(await repository.getSubscription(subscription.id), isNull);
        final archived = await repository.getSubscription(
          subscription.id,
          includeArchived: true,
        );
        expect(archived, isNotNull);
        expect(archived!.archivedAt, isNotNull);
        expect(archived.expiryDate, subscription.expiryDate);
      });
      await tester.pumpWidget(const SizedBox());
    },
  );
}
