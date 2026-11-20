import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';
import 'package:vanithabodhini/data/subscriber_import.dart';
import 'package:vanithabodhini/data/subscriber_import_file.dart';
import 'package:vanithabodhini/providers/database_provider.dart';
import 'package:vanithabodhini/ui/settings_page.dart';
import 'package:vanithabodhini/ui/settings/view_models/subscriber_import_view_model.dart';
import 'package:vanithabodhini/ui/subscribers/view_models/subscribers_view_model.dart';

void main() {
  late AppDatabase database;
  late SubscriberRepository repository;
  late ProviderContainer container;
  final sample = {
    'subscriber_name': 'SALLY BABU',
    'address': 'Main Street',
    'pincode': '691526',
  };

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = SubscriberRepository(database);
  });
  tearDown(() async {
    container.dispose();
    await database.close();
  });

  Future<void> mount(
    WidgetTester tester,
    Future<SubscriberImportFile?> Function() picker,
  ) async {
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        subscriberRepositoryProvider.overrideWithValue(repository),
        subscriberImportFilePickerProvider.overrideWithValue(picker),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: SettingsPage())),
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> selectFile(WidgetTester tester) async {
    await tester.tap(find.text('Import subscribers'));
    await settle(tester);
  }

  SubscriberImportFile file(List<Object?> rows) => SubscriberImportFile(
    name: 'subscribers.json',
    contents: jsonEncode(rows),
  );

  testWidgets('canceling the file picker leaves the database unchanged', (
    tester,
  ) async {
    await mount(tester, () async => null);
    await selectFile(tester);
    expect(find.byType(AlertDialog), findsNothing);
    expect(await database.select(database.subscribers).get(), isEmpty);
  });

  testWidgets(
    'invalid file blocks the entire import and displays the entry error',
    (tester) async {
      await mount(
        tester,
        () async => file([
          sample,
          {...sample, 'pincode': 691526},
        ]),
      );
      await selectFile(tester);
      expect(
        find.text('Entry 2: "pincode" must be a nonempty string.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
      expect(await database.select(database.subscribers).get(), isEmpty);
    },
  );

  testWidgets('file read failure is displayed and allows another selection', (
    tester,
  ) async {
    await mount(tester, () async => throw StateError('Unreadable file'));
    await selectFile(tester);
    expect(
      find.text('Unable to read or prepare the import. Try again.'),
      findsOneWidget,
    );
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Import subscribers'),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('shows counts without writes and cancel discards the preview', (
    tester,
  ) async {
    await mount(tester, () async => file([sample, sample]));
    await selectFile(tester);
    expect(find.text('subscribers.json'), findsOneWidget);
    expect(find.text('Total entries: 2'), findsOneWidget);
    expect(find.text('Subscribers to insert: 1'), findsOneWidget);
    expect(find.text('Duplicates to skip: 1'), findsOneWidget);
    expect(find.text('Are you sure you want to continue?'), findsOneWidget);
    expect(await database.select(database.subscribers).get(), isEmpty);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.byType(AlertDialog), findsNothing);
    expect(await database.select(database.subscribers).get(), isEmpty);
    expect(container.read(subscriberImportViewModelProvider).preview, isNull);
  });

  testWidgets(
    'confirmed import reports results, clears preview, and refreshes the list',
    (tester) async {
      await mount(tester, () async => file([sample, sample]));
      final list = container.read(subscribersViewModelProvider);
      await tester.runAsync(list.refresh);
      expect(list.total, 0);
      await selectFile(tester);
      await tester.tap(find.text('Import 1 subscriber'));
      await settle(tester);
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        find.text('1 subscriber imported. 1 duplicate skipped.'),
        findsOneWidget,
      );
      expect(await database.select(database.subscribers).get(), hasLength(1));
      expect(list.total, 1);
      final model = container.read(subscriberImportViewModelProvider);
      expect(model.preview, isNull);
      expect(model.filename, isNull);
      await selectFile(tester);
      expect(find.text('No new subscribers to import'), findsOneWidget);
      expect(find.text('Subscribers to insert: 0'), findsOneWidget);
      expect(find.text('Duplicates to skip: 2'), findsOneWidget);
      expect(find.text('Import 0 subscribers'), findsNothing);
      await tester.tap(find.text('Close'));
      await settle(tester);
    },
  );

  testWidgets('database failure reports rollback and permits retry', (
    tester,
  ) async {
    await mount(tester, () async => file([sample]));
    await selectFile(tester);
    await database.customStatement('''
      CREATE TRIGGER fail_import BEFORE INSERT ON audit_logs
      BEGIN SELECT RAISE(ABORT, 'test failure'); END
    ''');
    await tester.tap(find.text('Import 1 subscriber'));
    await settle(tester);
    expect(
      find.text('Unable to import subscribers. No subscribers were added.'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(await database.select(database.subscribers).get(), isEmpty);
    await database.customStatement('DROP TRIGGER fail_import');
    await tester.tap(find.text('Import 1 subscriber'));
    await settle(tester);
    expect(find.byType(AlertDialog), findsNothing);
    expect(await database.select(database.subscribers).get(), hasLength(1));
  });

  testWidgets(
    'prevents repeated selection and import, and dismissal during import',
    (tester) async {
      final picked = Completer<SubscriberImportFile?>();
      final delayed = _DelayedRepository(database);
      repository = delayed;
      var pickCalls = 0;
      await mount(tester, () {
        pickCalls++;
        return picked.future;
      });
      await tester.tap(find.text('Import subscribers'));
      await tester.pump();
      final model = container.read(subscriberImportViewModelProvider);
      await model.selectFile();
      expect(pickCalls, 1);
      picked.complete(file([sample]));
      await settle(tester);
      await tester.tap(find.text('Import 1 subscriber'));
      await tester.pump();
      await model.import();
      expect(delayed.calls, 1);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Cancel'))
            .onPressed,
        isNull,
      );
      final popScope = tester.widget<PopScope>(find.byType(PopScope).last);
      expect(popScope.canPop, isFalse);
      expect(await database.select(database.subscribers).get(), isEmpty);
      delayed.gate.complete();
      await settle(tester);
      expect(await database.select(database.subscribers).get(), hasLength(1));
      expect(find.byType(AlertDialog), findsNothing);
    },
  );
}

class _DelayedRepository extends SubscriberRepository {
  _DelayedRepository(super.database);

  final gate = Completer<void>();
  int calls = 0;

  @override
  Future<SubscriberImportResult> importSubscribers(
    SubscriberImportPreview preview,
  ) async {
    calls++;
    await gate.future;
    return super.importSubscribers(preview);
  }
}
