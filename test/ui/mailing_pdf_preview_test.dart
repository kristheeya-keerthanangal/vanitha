import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';
import 'package:vanithabodhini/main.dart';
import 'package:vanithabodhini/mailing/mailing_pdf.dart';
import 'package:vanithabodhini/providers/database_provider.dart';
import 'package:vanithabodhini/ui/mailing_list/mailing_list_page.dart';
import 'package:vanithabodhini/ui/mailing_list/view_models/mailing_list_view_model.dart';

import '../support/controlled_mailing_list_repository.dart';
import '../support/controlled_mailing_pdf.dart';

const channel = MethodChannel('net.nfet.printing');
const codec = StandardMethodCodec();

Future<void> fromPlatform(String method, Object arguments) =>
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          channel.name,
          codec.encodeMethodCall(MethodCall(method, arguments)),
          null,
        );

void main() {
  late AppDatabase database;
  late ControlledMailingListRepository repository;
  late ControlledMailingPdf pdf;
  late FakeMailingPdfFile file;
  late FakeMailingPdfPrinter printer;
  late ProviderContainer container;
  late List<Map<dynamic, dynamic>> rasters;
  late bool canRaster;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = ControlledMailingListRepository(database);
    pdf = ControlledMailingPdf();
    file = FakeMailingPdfFile();
    printer = FakeMailingPdfPrinter();
    rasters = [];
    canRaster = true;
    container = ProviderContainer(
      overrides: [
        subscriberRepositoryProvider.overrideWithValue(repository),
        mailingPdfProvider.overrideWithValue(pdf),
        mailingPdfFileProvider.overrideWithValue(file),
        mailingPdfPrinterProvider.overrideWithValue(printer),
      ],
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'printingInfo') return {'canRaster': canRaster};
          if (call.method == 'rasterPdf') {
            rasters.add(call.arguments as Map<dynamic, dynamic>);
          }
          return null;
        });
  });

  tearDown(() async {
    container.dispose();
    await database.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    List<MailingListEntry> rows = mailingEntries,
    bool navigate = false,
  }) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: navigate
            ? const MainApp()
            : const MaterialApp(home: Scaffold(body: MailingListPage())),
      ),
    );
    if (navigate) {
      await tester.tap(find.text('Mailing list'));
      await tester.pump();
    }
    repository.requests.last.complete(rows);
    await tester.pumpAndSettle();
  }

  Future<void> finishRaster(WidgetTester tester, {int pages = 1}) async {
    expect(rasters, isNotEmpty);
    final job = rasters.last['job'];
    // Raster decoding needs the real engine event loop rather than fake time.
    Future<void> settleRaster() async {
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 60)),
        );
        await tester.pump();
      }
    }

    for (var page = 0; page < pages; page++) {
      await fromPlatform('onPageRasterized', {
        'job': job,
        'width': 1,
        'height': 1,
        'image': Uint8List.fromList([page * 50, 0, 0, 255]),
      });
      await settleRaster();
    }
    final ended = fromPlatform('onPageRasterEnd', {'job': job, 'error': null});
    await settleRaster();
    await ended;
    await tester.pumpAndSettle();
  }

  Future<void> finishPreview(WidgetTester tester, {int pages = 1}) async {
    pdf.requests.last.result.complete(Uint8List.fromList([37, 80, 68, 70]));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await finishRaster(tester, pages: pages);
  }

  testWidgets(
    'navigation through preview, save, and print keeps Settings last',
    (tester) async {
      await pumpPage(tester, navigate: true);
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.selectedIndex, 3);
      expect((rail.destinations.last.label as Text).data, 'Settings');
      expect(find.text('Subscribers: 5'), findsOneWidget);
      expect(
        find.text('3 subscribers have incomplete mailing details.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Preview PDF'));
      await finishPreview(tester);
      final document = container.read(mailingListViewModelProvider).preview!;
      await tester.tap(find.text('Save PDF'));
      await tester.pumpAndSettle();
      expect(find.text('PDF saved.'), findsOneWidget);
      await tester.tap(find.text('Print PDF'));
      await tester.pumpAndSettle();
      expect(find.text('Print job submitted.'), findsOneWidget);
      expect(file.savedBytes.single, document.bytes);
      expect(printer.documents.single, document);
      expect(pdf.requests, hasLength(1));
    },
  );

  testWidgets(
    'prints and saves preview bytes, with busy states and actual-size guidance',
    (tester) async {
      await pumpPage(tester);
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
      await tester.tap(find.text('Preview PDF'));
      await finishPreview(tester);
      final document = container.read(mailingListViewModelProvider).preview!;
      expect(find.textContaining('100% / actual size'), findsOneWidget);
      file.pending = Completer<bool>();
      await tester.tap(find.text('Save PDF'));
      await tester.pump();
      expect(find.text('Saving PDF…'), findsOneWidget);
      expect(identical(file.savedBytes.single, document.bytes), isTrue);
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Print PDF'),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Preview PDF'),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<DropdownButton<MailingLabelSize>>(
              find.byType(DropdownButton<MailingLabelSize>),
            )
            .onChanged,
        isNull,
      );
      file.pending!.complete(true);
      await tester.pumpAndSettle();
      expect(find.text('PDF saved.'), findsOneWidget);
      printer.pending = Completer<bool>();
      await tester.tap(find.text('Print PDF'));
      await tester.pump();
      expect(find.text('Printing PDF…'), findsOneWidget);
      expect(identical(printer.documents.single, document), isTrue);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Save PDF'))
            .onPressed,
        isNull,
      );
      printer.pending!.complete(true);
      await tester.pumpAndSettle();
      expect(find.text('Print job submitted.'), findsOneWidget);
      expect(pdf.requests, hasLength(1));
      final dropdown = find.byType(DropdownButton<bool>);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Off').last);
      await tester.pumpAndSettle();
      expect(find.byType(PdfPreview), findsNothing);
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
    },
  );

  testWidgets(
    'print and save cancellation or errors keep the current preview retryable',
    (tester) async {
      await pumpPage(tester);
      await tester.tap(find.text('Preview PDF'));
      await finishPreview(tester);
      file.canceled = true;
      await tester.tap(find.text('Save PDF'));
      await tester.pumpAndSettle();
      expect(find.text('Save canceled.'), findsOneWidget);
      printer.canceled = true;
      await tester.tap(find.text('Print PDF'));
      await tester.pumpAndSettle();
      expect(find.text('Print canceled.'), findsOneWidget);
      file.fail = true;
      await tester.tap(find.text('Save PDF'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Choose a writable location'), findsOneWidget);
      printer.fail = true;
      await tester.tap(find.text('Print PDF'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Check your printer'), findsOneWidget);
      expect(find.byType(PdfPreview), findsOneWidget);
      expect(pdf.requests, hasLength(1));
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Save PDF'))
            .onPressed,
        isNotNull,
      );
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Print PDF'),
            )
            .onPressed,
        isNotNull,
      );
    },
  );

  testWidgets(
    'large mailing lists rasterize only the selected page at bounded resolution',
    (tester) async {
      final rows = List.generate(
        930,
        (i) => MailingListEntry(
          subscriberId: i + 1,
          name: 'Reader $i',
          postalAddress: 'Main Street',
          postalCode: '682001',
        ),
      );
      await pumpPage(tester, rows: rows);
      await tester.tap(find.text('Preview PDF'));
      await tester.pump();
      expect(find.text('Preparing preview…'), findsOneWidget);
      expect(file.savedBytes, isEmpty);
      await finishPreview(tester);
      expect(find.text('PDF preview · 35 pages'), findsOneWidget);
      expect(find.text('Page 1 of 35'), findsOneWidget);
      final preview = tester.widget<PdfPreview>(find.byType(PdfPreview));
      expect(preview.pages, [0]);
      expect(preview.dpi, 144);
      expect(preview.canChangeOrientation, isFalse);
      expect(preview.canChangePageFormat, isFalse);
      expect(preview.canDebug, isFalse);
      expect(preview.useActions, isFalse);
      expect(await preview.build(PdfPageFormat.letter), [37, 80, 68, 70]);
      expect(rasters.last['pages'], [0]);
      expect(rasters.last['scale'], 2);
      expect(
        tester
            .state<PdfPreviewState>(find.byType(PdfPreview))
            .previewWidget
            .currentState!
            .pages,
        hasLength(1),
      );

      Future<void> select(String tooltip, int page) async {
        await tester.ensureVisible(find.byTooltip(tooltip));
        await tester.tap(find.byTooltip(tooltip));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();
        expect(rasters.last['pages'], [page]);
        await finishRaster(tester);
        expect(find.text('Page ${page + 1} of 35'), findsOneWidget);
      }

      await select('Next page', 1);
      await select('Last page', 34);
      await select('Previous page', 33);
      await select('First page', 0);
      final rasterCount = rasters.length;
      // Parent notifications during output must not rasterize the PDF again.
      await container.read(mailingListViewModelProvider).savePdf();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));
      expect(rasters, hasLength(rasterCount));
      await container.read(mailingListViewModelProvider).printPdf();
      await tester.pumpAndSettle();
      expect(file.savedBytes.single, [37, 80, 68, 70]);
      expect(printer.documents.single.bytes, file.savedBytes.single);
      expect(pdf.requests, hasLength(1));
      expect(pdf.requests.single.subscribers, hasLength(930));
      await select('Last page', 34);
      unawaited(container.read(mailingListViewModelProvider).previewPdf());
      await tester.pump();
      await finishPreview(tester);
      expect(find.text('Page 1 of 35'), findsOneWidget);
      expect(rasters.last['pages'], [0]);
    },
  );

  testWidgets(
    'changing settings removes the old preview and asks for regeneration',
    (tester) async {
      await pumpPage(tester);
      await tester.tap(find.text('Preview PDF'));
      await finishPreview(tester);
      final dropdown = find.byType(DropdownButton<bool>);
      await tester.ensureVisible(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Off').last);
      await tester.pumpAndSettle();
      expect(find.byType(PdfPreview), findsNothing);
      expect(
        find.textContaining(
          'Preview cleared because settings or subscriber data changed.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('refresh removes the preview before new subscriber data loads', (
    tester,
  ) async {
    await pumpPage(tester);
    await tester.tap(find.text('Preview PDF'));
    await finishPreview(tester);
    await tester.tap(find.byTooltip('Refresh mailing list'));
    await tester.pump();
    expect(find.byType(PdfPreview), findsNothing);
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Preview PDF'),
          )
          .onPressed,
      isNull,
    );
    repository.requests.last.complete([]);
    await tester.pumpAndSettle();
    expect(find.text('Subscribers: 0'), findsOneWidget);
    expect(find.byType(PdfPreview), findsNothing);
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Preview PDF'),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets(
    'reports generation errors and disables preview for unresolved fitting failures',
    (tester) async {
      await pumpPage(tester);
      await tester.tap(find.text('Preview PDF'));
      await tester.pump();
      pdf.requests.last.result.completeError(StateError('failed'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Unable to generate the preview. Select Preview PDF to try again.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Preview PDF'));
      await tester.pump();
      pdf.requests.last.result.completeError(
        MailingTextFitFailure([mailingEntries.first]),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Preview blocked. Correct the listed subscribers or choose a larger label.',
        ),
        findsOneWidget,
      );
      expect(find.text('View subscribers that do not fit'), findsOneWidget);
      expect(find.byType(PdfPreview), findsNothing);
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Preview PDF'),
            )
            .onPressed,
        isNull,
      );
    },
  );

  testWidgets('renderer errors offer retry and the save alternative', (
    tester,
  ) async {
    canRaster = false;
    await pumpPage(tester);
    await tester.tap(find.text('Preview PDF'));
    pdf.requests.last.result.complete(Uint8List(1));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Unable to display the PDF. Retry the preview, or use Save PDF to open it in a PDF viewer.',
      ),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Retry'));
    await tester.pumpAndSettle();
    canRaster = true;
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(pdf.requests, hasLength(2));
    await finishPreview(tester);
    expect(find.text('PDF preview · 1 page'), findsOneWidget);
    expect(find.textContaining('Unable to display the PDF.'), findsNothing);
  });

  testWidgets(
    'changing selection during generation discards the late document',
    (tester) async {
      await pumpPage(tester);
      await tester.tap(find.text('Preview PDF'));
      await tester.pump();
      await tester.tap(find.byType(DropdownButton<MailingOrientation>));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Landscape').last);
      await tester.pumpAndSettle();
      pdf.requests.last.result.complete(Uint8List(1));
      await tester.pumpAndSettle();
      expect(find.byType(PdfPreview), findsNothing);
      expect(find.text('Preview PDF'), findsOneWidget);
      expect(
        find.textContaining(
          'Preview cleared because settings or subscriber data changed.',
        ),
        findsOneWidget,
      );
    },
  );
}
