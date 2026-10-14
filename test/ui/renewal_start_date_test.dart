import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/ui/subscribers/widgets/start_date_form_field.dart';

void main() {
  testWidgets('locked renewal date cannot open a picker', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StartDateFormField(
            value: DateTime(2026, 10, 15),
            locked: true,
            onChanged: (_) => fail('Locked date changed'),
            validator: (_) => null,
          ),
        ),
      ),
    );
    expect(find.text('2026-10-15'), findsOneWidget);
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsNothing);
  });

  testWidgets('renewal picker enforces the supplied inclusive date range', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StartDateFormField(
            value: DateTime(2026, 10, 14),
            firstDate: DateTime(2026, 10, 2),
            lastDate: DateTime(2026, 10, 14),
            onChanged: (_) {},
            validator: (_) => null,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();
    final picker = tester.widget<DatePickerDialog>(
      find.byType(DatePickerDialog),
    );
    expect(picker.firstDate, DateTime(2026, 10, 2));
    expect(picker.lastDate, DateTime(2026, 10, 14));
    expect(picker.initialDate, DateTime(2026, 10, 14));
  });
}
