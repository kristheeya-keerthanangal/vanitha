import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';
import 'package:vanithabodhini/data/repositories/subscription_repository.dart';
import 'package:vanithabodhini/main.dart';
import 'package:vanithabodhini/providers/database_provider.dart';
import 'package:vanithabodhini/providers/router_provider.dart';
import 'package:vanithabodhini/ui/subscribers/view_models/subscriber_details_view_model.dart';

void main() {
  testWidgets('edits subscriber personal details from the details page', (
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

    late int subscriberId;
    await tester.runAsync(() async {
      final subscriber = await SubscriberRepository(database).createSubscriber(
        name: 'Original Reader',
        email: 'old@example.com',
        phone: '9876543210',
        postalAddress: 'Old address',
        postalCode: '682001',
      );
      subscriberId = subscriber.id;
      await SubscriptionRepository(database).createSubscription(
        subscriberId: subscriber.id,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startYear: 2026,
        startMonth: 1,
      );
    });

    container.read(routerProvider).go('/subscribers/$subscriberId');
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MainApp()),
    );
    await tester.runAsync(
      () => container.read(
        subscriberDetailsViewModelProvider(subscriberId).future,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('subscriber-region-badge')), findsOneWidget);
    expect(find.text('Domestic'), findsWidgets);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit subscriber'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Updated Reader',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'new@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone'),
      '9123456780',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Address'),
      'New address',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Pincode'),
      '560001',
    );

    await tester.ensureVisible(find.text('Foreign'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Foreign'));
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(TextFormField, 'Postal / ZIP code'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final saved = await tester.runAsync(
      () => database.select(database.subscribers).getSingle(),
    );
    expect(saved, isNotNull);
    expect(saved!.name, 'Updated Reader');
    expect(saved.email, 'new@example.com');
    expect(saved.phone, '9123456780');
    expect(saved.postalAddress, 'New address');
    expect(saved.postalCode, '560001');
    expect(saved.isForeign, isTrue);

    final subscriptions = await tester.runAsync(
      () => database.select(database.subscriptions).get(),
    );
    expect(subscriptions, hasLength(1));
    expect(find.text('Updated Reader'), findsOneWidget);
    expect(find.text('Subscriber updated successfully'), findsOneWidget);
    expect(find.byKey(const Key('subscriber-region-badge')), findsOneWidget);
    expect(find.text('Foreign'), findsWidgets);
  });
}
