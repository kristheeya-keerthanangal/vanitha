import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vanithabodhini/theme/app_theme.dart';
import 'package:vanithabodhini/ui/app_shell.dart';

void main() {
  testWidgets('switches between dashboard and subscribers', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const AppShell()),
    );

    expect(find.text('Dashboard'), findsNWidgets(2));
    expect(find.text('Subscribers'), findsOneWidget);
    expect(find.byIcon(Icons.dashboard), findsNWidgets(2));

    await tester.tap(find.text('Subscribers'));
    await tester.pumpAndSettle();

    expect(find.text('Subscribers'), findsNWidgets(2));
    expect(find.byIcon(Icons.people), findsNWidgets(2));
  });
}
