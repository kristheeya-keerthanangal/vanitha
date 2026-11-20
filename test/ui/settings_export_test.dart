import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';
import 'package:vanithabodhini/providers/database_provider.dart';
import 'package:vanithabodhini/ui/settings/view_models/subscriber_export_view_model.dart';
import 'package:vanithabodhini/ui/settings_page.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() async {
    container.dispose();
    await database.close();
  });

  Future<void> mount(
    WidgetTester tester,
    Future<bool> Function(String) saver,
  ) async {
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        subscriberExportFileSaverProvider.overrideWithValue(saver),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: SettingsPage())),
      ),
    );
    await tester.ensureVisible(find.text('Export subscribers'));
  }

  Future<void> export(WidgetTester tester) async {
    await tester.tap(find.text('Export subscribers'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
  }

  testWidgets('exports all subscriber fields and reports success', (
    tester,
  ) async {
    final repository = SubscriberRepository(database);
    final subscriber = await repository.createSubscriber(name: 'Reader');
    final archived = await repository.archiveSubscriber(subscriber.id);
    String? saved;
    await mount(tester, (contents) async {
      saved = contents;
      return true;
    });
    await export(tester);
    expect(jsonDecode(saved!), [archived.toJson()]);
    expect(find.text('Subscribers exported.'), findsOneWidget);
    expect(find.text('Import subscribers'), findsOneWidget);
  });

  testWidgets('cancellation permits another export', (tester) async {
    var calls = 0;
    await mount(tester, (_) async {
      calls++;
      return calls > 1;
    });
    await export(tester);
    expect(find.text('Export canceled.'), findsOneWidget);
    await export(tester);
    expect(find.text('Subscribers exported.'), findsOneWidget);
    expect(calls, 2);
  });

  testWidgets('save failure is shown and export can be retried', (
    tester,
  ) async {
    var fail = true;
    await mount(tester, (_) async {
      if (fail) throw StateError('Disk full');
      return true;
    });
    await export(tester);
    expect(
      find.textContaining('Unable to export subscribers.'),
      findsOneWidget,
    );
    fail = false;
    await export(tester);
    expect(find.text('Subscribers exported.'), findsOneWidget);
    expect(find.textContaining('Unable to export subscribers.'), findsNothing);
  });

  testWidgets(
    'busy export prevents duplicates and safely finishes after disposal',
    (tester) async {
      final pending = Completer<bool>();
      var calls = 0;
      await mount(tester, (_) {
        calls++;
        return pending.future;
      });
      await export(tester);
      expect(find.text('Exporting subscribers…'), findsOneWidget);
      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        isNull,
      );
      final model = container.read(subscriberExportViewModelProvider);
      await model.export();
      expect(calls, 1);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      pending.complete(true);
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}
