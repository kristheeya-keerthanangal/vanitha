import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/main.dart';
import 'package:vanithabodhini/mailing/mailing_pdf.dart';
import 'package:vanithabodhini/providers/database_provider.dart';
import 'package:vanithabodhini/providers/router_provider.dart';
import 'package:vanithabodhini/ui/mailing_list/mailing_list_page.dart';
import 'package:vanithabodhini/ui/mailing_list/view_models/mailing_list_view_model.dart';

import '../support/controlled_mailing_list_repository.dart';
import '../support/controlled_mailing_pdf.dart';

void main() {
  late AppDatabase database;
  late ControlledMailingListRepository repository;
  late ProviderContainer container;
  late ControlledMailingPdf pdf;
  late FakeMailingPdfFile file;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = ControlledMailingListRepository(database);
    pdf = ControlledMailingPdf();
    file = FakeMailingPdfFile();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        subscriberRepositoryProvider.overrideWithValue(repository),
        mailingPdfProvider.overrideWithValue(pdf),
        mailingPdfFileProvider.overrideWithValue(file),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      initialLocation: '/mailing-list',
      routes: [
        GoRoute(
          path: '/mailing-list',
          builder: (_, _) => const Scaffold(body: MailingListPage()),
        ),
        GoRoute(
          path: '/subscribers/:id',
          builder: (_, state) =>
              Scaffold(body: Text('Subscriber ${state.pathParameters['id']}')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
  }

  Future<void> load(WidgetTester tester) async {
    repository.requests.last.complete(mailingEntries);
    await tester.pumpAndSettle();
  }

  Future<void> choose<T>(WidgetTester tester, String text) async {
    final dropdown = find.byType(DropdownButton<T>);
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  testWidgets('print and save stay disabled until a current preview exists', (
    tester,
  ) async {
    await pumpPage(tester);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Save PDF'))
          .onPressed,
      isNull,
    );
    await load(tester);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Save PDF'))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Print PDF'),
          )
          .onPressed,
      isNull,
    );
    expect(find.textContaining('100% / actual size'), findsOneWidget);
    expect(file.savedBytes, isEmpty);
  });

  testWidgets(
    'blocks PDF on fitting failures, shows affected subscribers and guidance, and allows larger labels',
    (tester) async {
      await pumpPage(tester);
      await load(tester);
      await tester.tap(find.text('Preview PDF'));
      await tester.pump();
      pdf.requests.single.result.completeError(
        MailingTextFitFailure([mailingEntries.first]),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('1 subscriber does not fit in the selected label.'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Correct their details or choose a larger label.'),
        findsOneWidget,
      );
      expect(file.savedBytes, isEmpty);
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Preview PDF'),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('View subscribers that do not fit'));
      await tester.pumpAndSettle();
      final dialog = find.byType(AlertDialog);
      expect(find.text('Text does not fit (1)'), findsOneWidget);
      expect(
        find.descendant(of: dialog, matching: find.text('Anita')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('Bela')),
        findsNothing,
      );
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await choose<MailingLabelSize>(tester, '65 × 40 mm');
      expect(find.text('View subscribers that do not fit'), findsNothing);
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Preview PDF'),
            )
            .onPressed,
        isNotNull,
      );
    },
  );

  testWidgets('generation failures are visible and retryable', (tester) async {
    await pumpPage(tester);
    await load(tester);
    await tester.tap(find.text('Preview PDF'));
    await tester.pump();
    pdf.requests.single.result.completeError(StateError('failed'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Unable to generate the preview. Select Preview PDF to try again.',
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Preview PDF'),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets(
    'shows defaults, full count, incomplete count and all subscribers',
    (tester) async {
      await pumpPage(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Subscribers: 0'), findsNothing);
      await load(tester);

      for (final label in [
        'Paper',
        'A4',
        'Orientation',
        'Portrait',
        'Label size',
        '60 × 30 mm',
        'Ordering',
        'Name',
        'Font size',
        'Automatic',
        'Cutting guides',
        'On',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      expect(
        tester
            .widget<DropdownButton<String>>(
              find.byType(DropdownButton<String>).first,
            )
            .onChanged,
        isNull,
      );
      expect(find.text('Subscribers: 5'), findsOneWidget);
      expect(
        find.text('3 subscribers have incomplete mailing details.'),
        findsOneWidget,
      );
      expect(find.text('View affected subscribers'), findsOneWidget);
      expect(find.byType(SegmentedButton), findsNothing);
      expect(find.text('Active'), findsNothing);
      expect(find.text('Expired'), findsNothing);
      for (final entry in mailingEntries) {
        await tester.ensureVisible(find.byKey(ValueKey(entry.subscriberId)));
        expect(find.text(entry.name), findsOneWidget);
      }
    },
  );

  testWidgets('changes settings and visibly reorders subscribers', (
    tester,
  ) async {
    await pumpPage(tester);
    await load(tester);
    final model = container.read(mailingListViewModelProvider);

    await choose<MailingOrientation>(tester, 'Landscape');
    await choose<MailingLabelSize>(tester, '65 × 35 mm');
    expect(model.labelSize, MailingLabelSize.medium);
    await choose<MailingLabelSize>(tester, '65 × 40 mm');
    await choose<bool>(tester, 'Off');
    await choose<MailingOrdering>(tester, 'PIN code');
    expect(model.orientation, MailingOrientation.landscape);
    expect(model.labelSize, MailingLabelSize.large);
    expect(model.cuttingGuides, isFalse);
    expect(model.rows.map((row) => row.subscriberId), [1, 2, 3, 4, 5]);
    expect(
      tester.getTopLeft(find.text('Chitra')).dy,
      lessThan(tester.getTopLeft(find.text('Bela')).dy),
    );
    await choose<MailingOrdering>(tester, 'Name');
    expect(
      tester.getTopLeft(find.text('Anita')).dy,
      lessThan(tester.getTopLeft(find.text('Bela')).dy),
    );
    expect(find.text('Subscribers: 5'), findsOneWidget);
  });

  testWidgets('opens only affected subscribers and links to their details', (
    tester,
  ) async {
    await pumpPage(tester);
    await load(tester);
    await tester.tap(find.text('View affected subscribers'));
    await tester.pumpAndSettle();
    final dialog = find.byType(AlertDialog);
    expect(find.text('Incomplete mailing details (3)'), findsOneWidget);
    expect(
      find.descendant(of: dialog, matching: find.text('Anita')),
      findsNothing,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('Bela')),
      findsNothing,
    );
    for (final name in ['Chitra', 'Deepa', 'Elsa']) {
      expect(
        find.descendant(of: dialog, matching: find.text(name)),
        findsOneWidget,
      );
    }
    await tester.tap(
      find.descendant(of: dialog, matching: find.text('Chitra')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Subscriber 1'), findsOneWidget);
  });

  testWidgets('shows empty state and hides the warning for complete data', (
    tester,
  ) async {
    await pumpPage(tester);
    repository.requests.last.complete([]);
    await tester.pumpAndSettle();
    expect(find.text('Subscribers: 0'), findsOneWidget);
    expect(find.text('No subscribers in the mailing list.'), findsOneWidget);
    expect(find.text('View affected subscribers'), findsNothing);
    await tester.tap(find.byTooltip('Refresh mailing list'));
    await tester.pump();
    repository.requests.last.complete(mailingEntries.take(2).toList());
    await tester.pumpAndSettle();
    expect(find.text('Subscribers: 2'), findsOneWidget);
    expect(find.text('View affected subscribers'), findsNothing);
    expect(find.text('No subscribers in the mailing list.'), findsNothing);
  });

  testWidgets('shows error state and retries successfully', (tester) async {
    await pumpPage(tester);
    repository.requests.last.completeError(StateError('unavailable'));
    await tester.pumpAndSettle();
    expect(find.text('Unable to load the mailing list.'), findsOneWidget);
    expect(find.text('Subscribers: 0'), findsNothing);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await load(tester);
    expect(find.text('Subscribers: 5'), findsOneWidget);
    expect(find.text('Unable to load the mailing list.'), findsNothing);
  });

  testWidgets(
    'opens Mailing list from navigation and directly, keeping Settings last',
    (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const MainApp()),
      );
      await tester.tap(find.text('Mailing list'));
      await tester.pump();
      await load(tester);
      expect(find.byType(MailingListPage), findsOneWidget);
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.selectedIndex, 3);
      expect((rail.destinations.last.label as Text).data, 'Settings');

      container.read(routerProvider).go('/dashboard');
      await tester.pumpAndSettle();
      container.read(routerProvider).go('/mailing-list');
      await tester.pump();
      await load(tester);
      expect(find.byType(MailingListPage), findsOneWidget);
      expect(
        tester
            .widget<NavigationRail>(find.byType(NavigationRail))
            .selectedIndex,
        3,
      );
    },
  );

  testWidgets('settings and affected list fit a narrow viewport', (
    tester,
  ) async {
    await pumpPage(tester);
    tester.view.physicalSize = const Size(400, 700);
    await tester.pump();
    await load(tester);
    await tester.ensureVisible(find.text('View affected subscribers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View affected subscribers'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
