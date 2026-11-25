import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/subscription_renewal.dart';
import 'package:vanithabodhini/ui/subscribers/widgets/start_date_form_field.dart';

void main() {
  testWidgets('locked renewal date cannot open a picker', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StartMonthFormField(
            value: DateTime(2026, 10),
            locked: true,
            onChanged: (_) => fail('Locked date changed'),
            validator: (_) => null,
          ),
        ),
      ),
    );
    expect(find.text('2026-10'), findsOneWidget);
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();
    expect(find.byType(MonthPickerDialog), findsNothing);
  });

  testWidgets('renewal picker enforces the supplied inclusive date range', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StartMonthFormField(
            value: DateTime(2026, 10),
            firstDate: DateTime(2026, 8),
            lastDate: DateTime(2026, 10),
            onChanged: (_) {},
            validator: (_) => null,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();
    final picker = tester.widget<MonthPickerDialog>(
      find.byType(MonthPickerDialog),
    );
    expect(picker.firstDate, DateTime(2026, 8));
    expect(picker.lastDate, DateTime(2026, 10));
    expect(picker.initialDate, DateTime(2026, 10));
  });

  testWidgets(
    'renewal picker allows dates before 2020 for unsubscribed subscriber',
    (tester) async {
      final rules = SubscriptionRenewal([]);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StartMonthFormField(
              value: rules.startDate,
              firstDate: rules.firstDate,
              lastDate: rules.lastDate,
              onChanged: (_) {},
              validator: (_) => null,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();
      final picker = tester.widget<MonthPickerDialog>(
        find.byType(MonthPickerDialog),
      );
      expect(picker.firstDate, DateTime(2000));
      expect(find.byType(MonthPickerDialog), findsOneWidget);
    },
  );
}
