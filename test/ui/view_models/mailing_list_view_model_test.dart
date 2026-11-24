import 'dart:async';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';
import 'package:vanithabodhini/mailing/mailing_pdf.dart';
import 'package:vanithabodhini/ui/mailing_list/view_models/mailing_list_view_model.dart';

import '../../support/controlled_mailing_list_repository.dart';
import '../../support/controlled_mailing_pdf.dart';

void main() {
  late AppDatabase database;
  late ControlledMailingListRepository repository;
  late MailingListViewModel model;
  late ControlledMailingPdf pdf;
  late FakeMailingPdfFile file;
  late FakeMailingPdfPrinter printer;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = ControlledMailingListRepository(database);
    pdf = ControlledMailingPdf();
    file = FakeMailingPdfFile();
    printer = FakeMailingPdfPrinter();
    model = MailingListViewModel(
      repository,
      pdf: pdf,
      file: file,
      printer: printer,
    );
  });

  tearDown(() async {
    model.dispose();
    await database.close();
  });

  Future<void> load() async {
    repository.requests.last.complete(mailingEntries);
    await Future<void>.delayed(Duration.zero);
  }

  test(
    'preview captures ordered subscribers and selected settings without saving',
    () async {
      await load();
      model.changeOrdering(MailingOrdering.postalCode);
      model.changeOrientation(MailingOrientation.landscape);
      model.changeLabelSize(MailingLabelSize.large);
      model.changeCuttingGuides(false);
      final pending = model.previewPdf();
      expect(model.previewing, isTrue);
      expect(model.canPreview, isFalse);
      expect(model.canOutput, isFalse);
      await model.previewPdf();
      expect(pdf.requests, hasLength(1));
      final bytes = Uint8List.fromList([1, 2, 3]);
      pdf.requests.last.result.complete(bytes);
      await pending;
      final preview = model.preview!;
      expect(preview.snapshot.subscribers.map((row) => row.subscriberId), [
        1,
        2,
        3,
        4,
        5,
      ]);
      expect(preview.snapshot.layout.orientation, MailingOrientation.landscape);
      expect(preview.snapshot.layout.labelSize, MailingLabelSize.large);
      expect(preview.snapshot.ordering, MailingOrdering.postalCode);
      expect(preview.snapshot.cuttingGuides, isFalse);
      expect(preview.snapshot.pageCount, 1);
      expect(model.previewing, isFalse);
      expect(model.previewInvalidated, isFalse);
      expect(file.savedBytes, isEmpty);
      bytes[0] = 99;
      expect(preview.bytes, [1, 2, 3]);
      expect(() => preview.bytes[0] = 8, throwsUnsupportedError);
      expect(
        () => preview.snapshot.subscribers.clear(),
        throwsUnsupportedError,
      );
    },
  );

  final changes = <String, void Function(MailingListViewModel)>{
    'orientation': (model) =>
        model.changeOrientation(MailingOrientation.landscape),
    'label size': (model) => model.changeLabelSize(MailingLabelSize.large),
    'ordering': (model) => model.changeOrdering(MailingOrdering.postalCode),
    'cutting guides': (model) => model.changeCuttingGuides(false),
  };
  for (final change in changes.entries) {
    test(
      'changing ${change.key} immediately removes the completed preview',
      () async {
        await load();
        final pending = model.previewPdf();
        pdf.requests.last.result.complete(Uint8List(1));
        await pending;
        expect(model.preview, isNotNull);
        change.value(model);
        expect(model.preview, isNull);
        expect(model.previewInvalidated, isTrue);
        expect(model.canPreview, isTrue);
      },
    );
  }

  test(
    'refresh removes a preview before loading, including details changed with the same count',
    () async {
      await load();
      final initial = model.previewPdf();
      pdf.requests.last.result.complete(Uint8List(1));
      await initial;
      final refresh = model.refresh();
      expect(model.preview, isNull);
      expect(model.previewInvalidated, isTrue);
      expect(model.canPreview, isFalse);
      final updatedRows = [
        MailingListEntry(
          subscriberId: mailingEntries.first.subscriberId,
          name: mailingEntries.first.name,
          postalAddress: 'Corrected address',
          postalCode: mailingEntries.first.postalCode,
        ),
        ...mailingEntries.skip(1),
      ];
      repository.requests.last.complete(updatedRows);
      await refresh;
      final updated = model.previewPdf();
      expect(pdf.requests.last.subscribers, updatedRows);
      pdf.requests.last.result.complete(Uint8List.fromList([2]));
      await updated;
      expect(model.preview!.bytes, [2]);
      expect(model.previewInvalidated, isFalse);
    },
  );

  test(
    'ignores stale fitting failures when settings change during preview generation',
    () async {
      await load();
      final stale = model.previewPdf();
      final old = pdf.requests.last;
      model.changeLabelSize(MailingLabelSize.large);
      expect(model.previewing, isFalse);
      expect(model.previewInvalidated, isTrue);
      final current = model.previewPdf();
      pdf.requests.last.result.complete(Uint8List.fromList([2]));
      await current;
      old.result.completeError(MailingTextFitFailure(mailingEntries));
      await stale;
      expect(old.layout.labelSize, MailingLabelSize.small);
      expect(model.preview!.snapshot.layout.labelSize, MailingLabelSize.large);
      expect(model.preview!.bytes, [2]);
      expect(model.fittingFailures, isEmpty);
      expect(model.previewError, isNull);
    },
  );

  test(
    'ignores old success after subscribers refresh during generation',
    () async {
      await load();
      final stale = model.previewPdf();
      final old = pdf.requests.last;
      final refresh = model.refresh();
      repository.requests.last.complete(mailingEntries.take(2).toList());
      await refresh;
      old.result.complete(Uint8List.fromList([1]));
      await stale;
      expect(old.subscribers, hasLength(5));
      expect(model.total, 2);
      expect(model.preview, isNull);
      expect(model.previewing, isFalse);
      expect(model.canPreview, isTrue);
    },
  );

  test(
    'preview errors can be retried, while fitting failures require a correction',
    () async {
      await load();
      final failed = model.previewPdf();
      pdf.requests.last.result.completeError(StateError('failure'));
      await failed;
      expect(model.previewError, contains('Select Generate list to try again'));
      expect(model.canPreview, isTrue);
      final fitFailed = model.previewPdf();
      pdf.requests.last.result.completeError(
        MailingTextFitFailure([mailingEntries.first]),
      );
      await fitFailed;
      expect(model.preview, isNull);
      expect(model.previewing, isFalse);
      expect(model.canPreview, isFalse);
      expect(model.fittingFailures, [mailingEntries.first]);
      model.changeOrdering(MailingOrdering.postalCode);
      model.changeCuttingGuides(false);
      expect(model.canPreview, isFalse);
      model.changeLabelSize(MailingLabelSize.large);
      expect(model.canPreview, isTrue);
      final corrected = model.previewPdf();
      pdf.requests.last.result.complete(Uint8List(1));
      await corrected;
      expect(model.previewError, isNull);
      expect(model.preview, isNotNull);
      expect(file.savedBytes, isEmpty);
    },
  );

  test('empty list and loading errors disable preview', () async {
    expect(model.canPreview, isFalse);
    repository.requests.last.completeError(StateError('failed'));
    await Future<void>.delayed(Duration.zero);
    expect(model.canPreview, isFalse);
    await model.previewPdf();
    expect(pdf.requests, isEmpty);
    final refresh = model.refresh();
    repository.requests.last.complete([]);
    await refresh;
    expect(model.canPreview, isFalse);
    await model.previewPdf();
    expect(pdf.requests, isEmpty);
  });

  test('ignores preview completion after disposal', () async {
    final disposed = MailingListViewModel(repository, pdf: pdf, file: file);
    repository.requests.last.complete(mailingEntries);
    await Future<void>.delayed(Duration.zero);
    final pending = disposed.previewPdf();
    disposed.dispose();
    pdf.requests.last.result.complete(Uint8List(1));
    await pending;
    expect(disposed.preview, isNull);
  });

  Future<void> preparePreview() async {
    final pending = model.previewPdf();
    pdf.requests.last.result.complete(Uint8List.fromList([37, 80, 68, 70, 7]));
    await pending;
  }

  test('prints and saves the exact preview without regeneration', () async {
    await load();
    model.changeOrientation(MailingOrientation.landscape);
    await preparePreview();
    final document = model.preview!;
    await model.savePdf();
    expect(identical(file.savedBytes.single, document.bytes), isTrue);
    expect(model.outputMessage, 'PDF saved.');
    await model.printPdf();
    expect(identical(printer.documents.single, document), isTrue);
    expect(model.outputMessage, 'Print job submitted.');
    expect(pdf.requests, hasLength(1));
    expect(identical(model.preview, document), isTrue);
  });

  test(
    'no output is possible before preview or after selection is invalidated',
    () async {
      await model.savePdf();
      await model.printPdf();
      await load();
      expect(model.canOutput, isFalse);
      await model.savePdf();
      await model.printPdf();
      await preparePreview();
      model.changeCuttingGuides(false);
      expect(model.canOutput, isFalse);
      await model.savePdf();
      await model.printPdf();
      expect(file.savedBytes, isEmpty);
      expect(printer.documents, isEmpty);
      expect(pdf.requests, hasLength(1));
    },
  );

  for (final action in PdfOutputAction.values) {
    test('$action locks output and settings until the dialog closes', () async {
      await load();
      await preparePreview();
      final completed = Completer<bool>();
      file.pending = completed;
      printer.pending = completed;
      final pending = action == PdfOutputAction.print
          ? model.printPdf()
          : model.savePdf();
      expect(model.outputAction, action);
      expect(model.canOutput, isFalse);
      expect(model.canPreview, isFalse);
      model.changeOrientation(MailingOrientation.landscape);
      expect(model.orientation, MailingOrientation.portrait);
      model.changeFilter(MailingListFilter.expired);
      expect(model.filter, MailingListFilter.active);
      await model.refresh();
      await model.savePdf();
      await model.printPdf();
      await model.previewPdf();
      expect(file.savedBytes.length + printer.documents.length, 1);
      expect(pdf.requests, hasLength(1));
      expect(repository.requests, hasLength(1));
      completed.complete(false);
      await pending;
      expect(model.outputBusy, isFalse);
      expect(model.canOutput, isTrue);
      expect(
        model.outputMessage,
        action == PdfOutputAction.print ? 'Print canceled.' : 'Save canceled.',
      );
      expect(model.outputError, isNull);
    });
  }

  test('save and print errors allow retrying the same preview', () async {
    await load();
    await preparePreview();
    final document = model.preview;
    file.fail = true;
    await model.savePdf();
    expect(model.outputError, contains('Choose a writable location'));
    expect(model.outputBusy, isFalse);
    printer.fail = true;
    await model.printPdf();
    expect(model.outputError, contains('Check your printer'));
    expect(model.canOutput, isTrue);
    expect(model.preview, document);
    file.fail = false;
    await model.savePdf();
    expect(model.outputError, isNull);
    expect(model.outputMessage, 'PDF saved.');
    expect(pdf.requests, hasLength(1));
  });

  test('ignores output completion after disposal', () async {
    final disposed = MailingListViewModel(repository, pdf: pdf, file: file);
    repository.requests.last.complete(mailingEntries);
    await Future<void>.delayed(Duration.zero);
    final preparing = disposed.previewPdf();
    pdf.requests.last.result.complete(Uint8List(1));
    await preparing;
    file.pending = Completer<bool>();
    final saving = disposed.savePdf();
    disposed.dispose();
    file.pending!.complete(true);
    await saving;
    expect(disposed.outputMessage, isNull);
  });

  test('starts loading with the requested default settings', () {
    expect(model.loading, isTrue);
    expect(model.error, isNull);
    expect(model.orientation, MailingOrientation.portrait);
    expect(model.labelSize, MailingLabelSize.small);
    expect(model.labelSize.widthMm, 60);
    expect(model.labelSize.heightMm, 30);
    expect(model.ordering, MailingOrdering.name);
    expect(model.cuttingGuides, isTrue);
    expect(model.filter, MailingListFilter.active);
  });

  test(
    'changing filter updates setting, invalidates preview, and requests new data',
    () async {
      await load();
      expect(repository.filters.last, MailingListFilter.active);
      await preparePreview();
      expect(model.preview, isNotNull);

      model.changeFilter(MailingListFilter.expired);
      expect(model.filter, MailingListFilter.expired);
      expect(model.preview, isNull);
      expect(model.previewInvalidated, isTrue);
      expect(repository.filters.last, MailingListFilter.expired);

      final expiredEntries = [mailingEntries.first];
      repository.requests.last.complete(expiredEntries);
      await Future<void>.delayed(Duration.zero);
      expect(model.rows, expiredEntries);
      expect(model.total, 1);
    },
  );

  test(
    'loads full counts and counts each incomplete subscriber once',
    () async {
      await load();
      expect(model.loading, isFalse);
      expect(model.total, 5);
      expect(model.rows, mailingEntries);
      expect(model.incompleteCount, 3);
      expect(model.incompleteRows.map((row) => row.subscriberId), [1, 5, 4]);
    },
  );

  test(
    'orders by PIN with ID ties and missing codes last, then restores name order',
    () async {
      await load();
      model.changeOrdering(MailingOrdering.postalCode);
      expect(model.rows.map((row) => row.subscriberId), [1, 2, 3, 4, 5]);
      expect(model.incompleteCount, 3);
      model.changeOrdering(MailingOrdering.name);
      expect(model.rows, mailingEntries);
    },
  );

  test('updates settings and keeps selections when data refreshes', () async {
    await load();
    var notifications = 0;
    model.addListener(() => notifications++);
    model.changeOrientation(MailingOrientation.landscape);
    model.changeLabelSize(MailingLabelSize.medium);
    expect(model.labelSize.label, '65 × 35 mm');
    model.changeLabelSize(MailingLabelSize.large);
    model.changeCuttingGuides(false);
    model.changeOrdering(MailingOrdering.postalCode);
    expect(notifications, 5);
    final refresh = model.refresh();
    repository.requests.last.complete(mailingEntries);
    await refresh;
    expect(model.orientation, MailingOrientation.landscape);
    expect(model.labelSize.label, '65 × 40 mm');
    expect(model.cuttingGuides, isFalse);
    expect(model.rows.map((row) => row.subscriberId), [1, 2, 3, 4, 5]);
  });

  test('reports errors and allows a retry to an empty result', () async {
    repository.requests.last.completeError(StateError('database unavailable'));
    await Future<void>.delayed(Duration.zero);
    expect(model.error, 'Unable to load the mailing list.');
    expect(model.loading, isFalse);
    final retry = model.refresh();
    expect(model.loading, isTrue);
    expect(model.error, isNull);
    repository.requests.last.complete([]);
    await retry;
    expect(model.total, 0);
    expect(model.incompleteCount, 0);
    expect(model.loading, isFalse);
  });

  test('ignores stale successes and errors', () async {
    final latest = model.refresh();
    repository.requests[1].complete(mailingEntries);
    await latest;
    repository.requests[0].completeError(StateError('old request'));
    await Future<void>.delayed(Duration.zero);
    expect(model.error, isNull);
    expect(model.total, 5);

    final stale = model.refresh();
    final current = model.refresh();
    repository.requests[3].complete([]);
    await current;
    repository.requests[2].complete(mailingEntries);
    await stale;
    expect(model.total, 0);
  });

  test('ignores responses after disposal', () async {
    final disposed = MailingListViewModel(repository);
    disposed.dispose();
    repository.requests.last.complete(mailingEntries);
    await Future<void>.delayed(Duration.zero);
    expect(disposed.rows, isEmpty);
  });
}
