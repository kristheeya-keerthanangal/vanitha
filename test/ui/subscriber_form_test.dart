import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_registration_repository.dart';
import 'package:vanithabodhini/theme/app_theme.dart';
import 'package:vanithabodhini/ui/subscriber_form.dart';

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
    expect(find.text('select subscriber type'), findsOneWidget);
    expect(find.text('select edition'), findsOneWidget);
    expect(find.text('select plan type'), findsOneWidget);
    expect(find.text('select payment status'), findsOneWidget);
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

    final planTypeField = find.byType(DropdownButtonFormField<String>).at(2);
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
}
