import 'dart:async';

import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_registration_repository.dart';
import 'package:vanithabodhini/providers/database_provider.dart';
import 'package:vanithabodhini/theme/app_theme.dart';
import 'package:vanithabodhini/ui/subscribers/subscriber_form.dart';
import 'package:vanithabodhini/ui/subscribers/view_models/subscribers_view_model.dart';
import 'package:vanithabodhini/ui/subscribers/widgets/add_subscriber_button.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('requires the subscriber and subscription fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AddSubscriberForm(
          repository: SubscriberRegistrationRepository(database),
        ),
      ),
    );

    await tester.tap(find.text('Add subscriber').last);
    await tester.pump();

    expect(find.text('Enter a name'), findsOneWidget);
    expect(find.text('select edition'), findsOneWidget);
    expect(find.text('select plan type'), findsOneWidget);
    expect(find.text('Select a start date'), findsOneWidget);
  });

  testWidgets('validates email and phone formats', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AddSubscriberForm(
          repository: SubscriberRegistrationRepository(database),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Anita Rao',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'invalid',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Phone'), '123');
    await tester.tap(find.text('Add subscriber').last);
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Enter a valid phone number'), findsOneWidget);
  });

  testWidgets('only shows editable duration for multi-year plans', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AddSubscriberForm(
          repository: SubscriberRegistrationRepository(database),
        ),
      ),
    );

    expect(find.text('Duration (years)'), findsNothing);

    final planTypeField = find.byType(DropdownButtonFormField<String>).at(1);
    await tester.ensureVisible(planTypeField);
    await tester.tap(planTypeField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Multi-year').last);
    await tester.pump();
    expect(find.text('Duration (years)'), findsOneWidget);

    await tester.ensureVisible(planTypeField);
    await tester.tap(planTypeField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lifetime').last);
    await tester.pump();
    expect(find.text('Duration (years)'), findsNothing);
  });

  testWidgets('does not dismiss while saving and refreshes after commit', (
    tester,
  ) async {
    final saveGate = Completer<void>();
    final repository = DelayedSubscriberRegistrationRepository(
      database,
      saveGate,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          subscriberRegistrationRepositoryProvider.overrideWithValue(
            repository,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Column(
              children: [
                const AddSubscriberButton(),
                Consumer(
                  builder: (context, ref, child) {
                    final model = ref.watch(subscribersViewModelProvider);
                    return ListenableBuilder(
                      listenable: model,
                      builder: (context, child) =>
                          Text('Subscribers: ${model.total}'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add subscriber'));
    await tester.pump();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Delayed Reader',
    );
    expect(find.widgetWithText(TextFormField, 'City'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'State'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'Country'), findsNothing);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Address'),
      '10 Main Street, Kochi, Kerala, India',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Pincode'),
      '0682001',
    );
    final editionField = find.byType(DropdownButtonFormField<String>).at(0);
    await tester.ensureVisible(editionField);
    await tester.tap(editionField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Online').last);
    await tester.pumpAndSettle();
    final planField = find.byType(DropdownButtonFormField<String>).at(1);
    await tester.ensureVisible(planField);
    await tester.pumpAndSettle();
    await tester.tap(planField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annual').last);
    await tester.pumpAndSettle();
    final startDateField = find.widgetWithText(TextFormField, 'Start date');
    await tester.ensureVisible(startDateField);
    await tester.tap(startDateField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('15').last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(0, -240),
    );
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    final submitButton = find.byType(FilledButton).last;
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();
    expect(repository.calls, 1);
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tapAt(const Offset(1, 1));
    await tester.pump();
    expect(find.byType(AlertDialog), findsOneWidget);

    saveGate.complete();
    await tester.pumpAndSettle();

    final subscriber = await database.select(database.subscribers).getSingle();
    expect(subscriber.postalAddress, '10 Main Street, Kochi, Kerala, India');
    expect(subscriber.postalCode, '0682001');
    expect(await database.select(database.subscriptions).get(), hasLength(1));
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Subscribers: 1'), findsOneWidget);
    expect(find.text('Subscriber added successfully'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class DelayedSubscriberRegistrationRepository
    extends SubscriberRegistrationRepository {
  DelayedSubscriberRegistrationRepository(super.database, this.gate);

  final Completer<void> gate;
  int calls = 0;

  @override
  Future<SubscriberRegistration> registerSubscriber({
    required String name,
    String? email,
    String? phone,
    String? postalAddress,
    String? postalCode,
    required String edition,
    required String planType,
    required int durationYears,
    required DateTime startDate,
  }) async {
    calls++;
    await gate.future;
    return super.registerSubscriber(
      name: name,
      email: email,
      phone: phone,
      postalAddress: postalAddress,
      postalCode: postalCode,
      edition: edition,
      planType: planType,
      durationYears: durationYears,
      startDate: startDate,
    );
  }
}
