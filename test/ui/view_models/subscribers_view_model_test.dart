import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';
import 'package:vanithabodhini/ui/subscribers/view_models/subscribers_view_model.dart';

class ControlledRepository extends SubscriberRepository {
  ControlledRepository(super.database);
  final requests = <Completer<SubscriberPage>>[];
  final offsets = <int>[];
  final searches = <String>[];
  final filters = <SubscriberFilter>[];
  final originFilters = <SubscriberOriginFilter>[];
  @override
  Future<SubscriberPage> getSubscribersPage({
    int offset = 0,
    int limit = 25,
    String search = '',
    SubscriberSort sortBy = SubscriberSort.name,
    SubscriberFilter filterBy = SubscriberFilter.all,
    SubscriberOriginFilter originFilter = SubscriberOriginFilter.all,
    bool ascending = true,
  }) {
    offsets.add(offset);
    searches.add(search);
    filters.add(filterBy);
    originFilters.add(originFilter);
    final request = Completer<SubscriberPage>();
    requests.add(request);
    return request.future;
  }
}

void main() {
  late AppDatabase database;
  late ControlledRepository repository;
  late SubscribersViewModel model;
  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = ControlledRepository(database);
    model = SubscribersViewModel(repository);
  });
  tearDown(() async {
    model.dispose();
    await database.close();
  });
  Future<void> tick() => Future<void>.delayed(Duration.zero);

  test('ignores stale page responses', () async {
    model.changePage(25);
    repository.requests[1].complete(const SubscriberPage(rows: [], total: 550));
    await tick();
    repository.requests[0].complete(const SubscriberPage(rows: [], total: 10));
    await tick();
    expect(model.total, 550);
    expect(model.offset, 25);
    expect(model.loading, false);
  });

  test(
    'status filter resets paging and is included in repository requests',
    () async {
      repository.requests[0].complete(
        const SubscriberPage(rows: [], total: 550),
      );
      await tick();
      model.changePage(25);
      repository.requests[1].complete(
        const SubscriberPage(rows: [], total: 550),
      );
      await tick();

      model.filterChanged(SubscriberFilter.expired);

      expect(model.selectedFilter, SubscriberFilter.expired);
      expect(model.offset, 0);
      expect(repository.offsets.last, 0);
      expect(repository.filters.last, SubscriberFilter.expired);
      repository.requests[2].complete(const SubscriberPage(rows: [], total: 3));
      await tick();
      expect(model.total, 3);
    },
  );

  test(
    'origin filter resets paging and is included in repository requests',
    () async {
      repository.requests[0].complete(
        const SubscriberPage(rows: [], total: 550),
      );
      await tick();
      model.changePage(25);
      repository.requests[1].complete(
        const SubscriberPage(rows: [], total: 550),
      );
      await tick();

      model.originFilterChanged(SubscriberOriginFilter.foreign);

      expect(model.selectedOriginFilter, SubscriberOriginFilter.foreign);
      expect(model.offset, 0);
      expect(repository.offsets.last, 0);
      expect(repository.originFilters.last, SubscriberOriginFilter.foreign);
      repository.requests[2].complete(const SubscriberPage(rows: [], total: 5));
      await tick();
      expect(model.total, 5);
    },
  );

  test('debounces search and resets paging and sorting', () async {
    repository.requests[0].complete(const SubscriberPage(rows: [], total: 550));
    await tick();
    model.changePage(25);
    repository.requests[1].complete(const SubscriberPage(rows: [], total: 550));
    await tick();
    model.searchChanged('a');
    model.searchChanged('anita');
    expect(model.offset, 0);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    expect(repository.searches, ['', '', 'anita']);
    repository.requests[2].complete(const SubscriberPage(rows: [], total: 1));
    await tick();
    model.changePageSize(10);
    expect(model.offset, 0);
    expect(model.pageSize, 10);
    repository.requests[3].complete(const SubscriberPage(rows: [], total: 1));
    await tick();
    model.changeSort(SubscriberSort.number, false);
    expect(model.sort, SubscriberSort.number);
    expect(model.ascending, false);
    repository.requests[4].complete(const SubscriberPage(rows: [], total: 1));
    await tick();
  });

  test('clamps an out-of-range page and retries failures', () async {
    repository.requests[0].complete(const SubscriberPage(rows: [], total: 550));
    await tick();
    model.changePage(525);
    repository.requests[1].complete(const SubscriberPage(rows: [], total: 30));
    await tick();
    expect(repository.offsets.last, 25);
    repository.requests[2].complete(const SubscriberPage(rows: [], total: 30));
    await tick();
    final refresh = model.refresh();
    repository.requests[3].completeError(StateError('failed'));
    await refresh;
    expect(model.error, isNotNull);
    final retry = model.refresh();
    repository.requests[4].complete(const SubscriberPage(rows: [], total: 30));
    await retry;
    expect(model.error, isNull);
    expect(model.loading, false);
  });
}
