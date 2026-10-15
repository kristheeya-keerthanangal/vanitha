import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/app_database.dart';
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

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = ControlledMailingListRepository(database);
    pdf = ControlledMailingPdf();
    file = FakeMailingPdfFile();
    model = MailingListViewModel(repository, pdf: pdf, file: file);
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
    'generates the complete ordered list using selected layout and guides',
    () async {
      expect(model.canGenerate, isFalse);
      await load();
      model.changeOrdering(MailingOrdering.postalCode);
      model.changeOrientation(MailingOrientation.landscape);
      model.changeLabelSize(MailingLabelSize.large);
      model.changeCuttingGuides(false);
      final generation = model.generatePdf();
      expect(model.generating, isTrue);
      expect(model.canGenerate, isFalse);
      await model.generatePdf();
      expect(pdf.requests, hasLength(1));
      expect(pdf.requests.single.subscribers.map((row) => row.subscriberId), [
        1,
        2,
        3,
        4,
        5,
      ]);
      expect(
        pdf.requests.single.layout.orientation,
        MailingOrientation.landscape,
      );
      expect(pdf.requests.single.layout.labelSize, MailingLabelSize.large);
      expect(pdf.requests.single.cuttingGuides, isFalse);
      model.changeLabelSize(MailingLabelSize.small);
      expect(model.labelSize, MailingLabelSize.large);
      await model.refresh();
      expect(repository.requests, hasLength(1));
      final bytes = Uint8List.fromList([37, 80, 68, 70]);
      pdf.requests.single.result.complete(bytes);
      await generation;
      expect(file.savedBytes, [bytes]);
      expect(model.pdfSaved, isTrue);
      expect(model.generating, isFalse);
    },
  );

  test(
    'blocks saving and regeneration on fit failures until details or layout change',
    () async {
      await load();
      final generation = model.generatePdf();
      pdf.requests.single.result.completeError(
        MailingTextFitFailure([mailingEntries[0], mailingEntries[2]]),
      );
      await generation;
      expect(model.fittingFailures.map((row) => row.subscriberId), [3, 1]);
      expect(file.savedBytes, isEmpty);
      expect(model.canGenerate, isFalse);
      await model.generatePdf();
      expect(pdf.requests, hasLength(1));
      model.changeLabelSize(MailingLabelSize.large);
      expect(model.canGenerate, isTrue);
      final retry = model.generatePdf();
      pdf.requests.last.result.complete(Uint8List(1));
      await retry;
      expect(model.pdfSaved, isTrue);
      expect(model.fittingFailures, isEmpty);
    },
  );

  test(
    'handles save cancellation and generation or save errors without losing subscribers',
    () async {
      await load();
      final failed = model.generatePdf();
      pdf.requests.last.result.completeError(StateError('generation failed'));
      await failed;
      expect(model.generationError, isNotNull);
      expect(model.total, 5);
      file.canceled = true;
      final canceled = model.generatePdf();
      pdf.requests.last.result.complete(Uint8List(1));
      await canceled;
      expect(model.pdfSaved, isFalse);
      expect(model.generationError, isNull);
      file.fail = true;
      final saveFailed = model.generatePdf();
      pdf.requests.last.result.complete(Uint8List(1));
      await saveFailed;
      expect(model.generationError, isNotNull);
      expect(model.canGenerate, isTrue);
    },
  );

  test('does not save if disposed while generating', () async {
    final disposed = MailingListViewModel(repository, pdf: pdf, file: file);
    repository.requests.last.complete(mailingEntries);
    await Future<void>.delayed(Duration.zero);
    final generation = disposed.generatePdf();
    disposed.dispose();
    pdf.requests.last.result.complete(Uint8List(1));
    await generation;
    expect(file.savedBytes, isEmpty);
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
  });

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
