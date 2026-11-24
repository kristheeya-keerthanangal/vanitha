import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscription_repository.dart';
import 'package:vanithabodhini/data/subscription_renewal.dart';
import 'package:vanithabodhini/theme/app_theme.dart';
import 'package:vanithabodhini/ui/subscribers/renew_subscription_form.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('shows the renewal form controls in a scrollable dialog', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => RenewSubscriptionForm(
                  repository: SubscriptionRepository(database),
                  subscriberId: 1,
                  rules: SubscriptionRenewal([]),
                ),
              ),
              child: const Text('Open renewal form'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open renewal form'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<AlertDialog>(find.byType(AlertDialog)).scrollable,
      isTrue,
    );
    expect(find.text('Edition'), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);
    expect(find.text('Plan type'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Start month'), findsOneWidget);
    expect(
      tester.getRect(find.widgetWithText(TextFormField, 'Start month')).height,
      greaterThan(0),
    );
  });
}
