import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/providers/database_provider.dart';
import 'package:vanithabodhini/main.dart';

void main() {
  testWidgets('switches between dashboard and subscribers', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MainApp(),
      ),
    );

    expect(find.text('Dashboard'), findsNWidgets(2));
    expect(find.text('Subscribers'), findsOneWidget);
    expect(find.byIcon(Icons.dashboard), findsNWidgets(2));

    await tester.tap(find.text('Subscribers'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(find.text('Subscribers'), findsNWidgets(2));
    expect(find.byIcon(Icons.people), findsOneWidget);
  });
}
