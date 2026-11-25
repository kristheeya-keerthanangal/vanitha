import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/postal_office_repository.dart';
import 'package:vanithabodhini/providers/database_provider.dart';
import 'package:vanithabodhini/ui/postal_offices/postal_office_form_page.dart';
import 'package:vanithabodhini/ui/postal_offices/postal_offices_page.dart';

void main() {
  late AppDatabase database;
  late PostalOfficeRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = PostalOfficeRepository(database);
  });

  tearDown(() => database.close());

  Widget buildTestWidget({required Widget child, GoRouter? router}) {
    if (router != null) {
      return ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          postalOfficeRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp.router(routerConfig: router),
      );
    }
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        postalOfficeRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(home: child),
    );
  }

  testWidgets('PostalOfficesPage displays empty state when no offices exist', (tester) async {
    await tester.pumpWidget(buildTestWidget(child: const PostalOfficesPage()));
    await tester.pumpAndSettle();

    expect(find.text('Postal offices'), findsOneWidget);
    expect(find.text('No postal offices configured. Add your first postal office to get started.'), findsOneWidget);
    expect(find.text('Add postal office'), findsOneWidget);
  });

  testWidgets('PostalOfficesPage lists offices with rule counts and active badge', (tester) async {
    final office1 = await repository.createOffice(name: 'Kasaragod RMS', isActive: true);
    await repository.addRule(
      postalOfficeId: office1.id,
      operation: 'include',
      matchMethod: 'prefix',
      startValue: '671',
    );
    await repository.createOffice(name: 'Thiruvalla RMS', isActive: false);

    await tester.pumpWidget(buildTestWidget(child: const PostalOfficesPage()));
    await tester.pumpAndSettle();

    expect(find.text('Kasaragod RMS'), findsOneWidget);
    expect(find.text('1 rule configured'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);

    expect(find.text('Thiruvalla RMS'), findsOneWidget);
    expect(find.text('0 rules configured'), findsOneWidget);
    expect(find.text('Inactive'), findsOneWidget);
  });

  testWidgets('PostalOfficesPage deletes office after confirmation', (tester) async {
    final office = await repository.createOffice(name: 'Office to delete');

    await tester.pumpWidget(buildTestWidget(child: const PostalOfficesPage()));
    await tester.pumpAndSettle();

    expect(find.text('Office to delete'), findsOneWidget);

    // Tap delete icon
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Delete postal office?'), findsOneWidget);
    expect(find.text('Are you sure you want to delete "Office to delete"? All associated pincode rules will also be deleted.'), findsOneWidget);

    // Confirm delete
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Office to delete'), findsNothing);
    expect(await repository.getOffice(office.id), isNull);
  });

  testWidgets('PostalOfficeFormPage adds rules, runs pincode tester, and saves', (tester) async {
    await tester.pumpWidget(buildTestWidget(child: const PostalOfficeFormPage()));
    await tester.pumpAndSettle();

    expect(find.text('Add postal office'), findsOneWidget);

    // Enter name
    await tester.enterText(find.widgetWithText(TextFormField, 'Office name *'), 'Kannur RMS');

    // Add Include Prefix 670 rule
    await tester.tap(find.text('Add rule'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'PIN Prefix'), '670');

    // Add Exclude Exact 670002 rule
    await tester.tap(find.text('Add rule'));
    await tester.pumpAndSettle();

    // The second rule: change operation to Exclude, method to Exact
    final operationDropdowns = find.widgetWithText(DropdownButtonFormField<String>, 'Include');
    expect(operationDropdowns, findsNWidgets(2));
    await tester.tap(operationDropdowns.at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exclude').last);
    await tester.pumpAndSettle();

    final methodDropdowns = find.widgetWithText(DropdownButtonFormField<String>, 'Prefix');
    expect(methodDropdowns, findsNWidgets(2));
    await tester.tap(methodDropdowns.at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exact').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Exact PIN'), '670002');

    // Test pincode in the assignment tester
    await tester.ensureVisible(find.text('Test'));
    await tester.enterText(find.widgetWithText(TextFormField, 'Test pincode'), '670001');
    await tester.tap(find.text('Test'));
    await tester.pumpAndSettle();

    expect(find.text('MATCHES THIS OFFICE'), findsOneWidget);
    expect(find.textContaining('PREFIX (670)'), findsOneWidget);

    // Test excluded pincode
    await tester.enterText(find.widgetWithText(TextFormField, 'Test pincode'), '670002');
    await tester.tap(find.text('Test'));
    await tester.pumpAndSettle();

    expect(find.text('DOES NOT MATCH'), findsOneWidget);
    expect(find.textContaining('EXACT (670002)'), findsOneWidget);

    // Save
    await tester.ensureVisible(find.text('Create office'));
    await tester.tap(find.text('Create office'));
    await tester.pumpAndSettle();

    final savedOffices = await repository.getAllOffices();
    expect(savedOffices.length, 1);
    expect(savedOffices.first.name, 'Kannur RMS');

    final savedRules = await repository.getRulesForOffice(savedOffices.first.id);
    expect(savedRules.length, 2);
    expect(savedRules[0].operation, 'include');
    expect(savedRules[0].startValue, '670');
    expect(savedRules[1].operation, 'exclude');
    expect(savedRules[1].startValue, '670002');
  });

  testWidgets('PostalOfficesPage navigates to add office and immediately shows newly created office upon return', (tester) async {
    final router = GoRouter(
      initialLocation: '/postal-offices',
      routes: [
        GoRoute(
          path: '/postal-offices',
          builder: (_, _) => const Scaffold(body: PostalOfficesPage()),
          routes: [
            GoRoute(
              path: 'new',
              builder: (_, _) => const PostalOfficeFormPage(),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(buildTestWidget(child: const SizedBox.shrink(), router: router));
    await tester.pumpAndSettle();

    expect(find.text('No postal offices configured. Add your first postal office to get started.'), findsOneWidget);

    // Tap Add postal office
    await tester.tap(find.text('Add postal office'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'Office name *'), findsOneWidget);

    // Enter name
    await tester.enterText(find.widgetWithText(TextFormField, 'Office name *'), 'Thalassery STO');
    await tester.pumpAndSettle();

    // Tap Create office
    await tester.ensureVisible(find.text('Create office'));
    await tester.tap(find.text('Create office'));
    await tester.pumpAndSettle();

    // Check we are back on PostalOfficesPage and Thalassery STO is visible immediately
    expect(find.text('Thalassery STO'), findsOneWidget);
    expect(find.text('No postal offices configured. Add your first postal office to get started.'), findsNothing);
  });
}
