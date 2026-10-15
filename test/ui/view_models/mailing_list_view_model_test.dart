import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/ui/mailing_list/view_models/mailing_list_view_model.dart';

import '../../support/controlled_mailing_list_repository.dart';

void main() {
  late AppDatabase database;
  late ControlledMailingListRepository repository;
  late MailingListViewModel model;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = ControlledMailingListRepository(database);
    model = MailingListViewModel(repository);
  });

  tearDown(() async {
    model.dispose();
    await database.close();
  });

  Future<void> load() async {
    repository.requests.last.complete(mailingEntries);
    await Future<void>.delayed(Duration.zero);
  }

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
