import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';

void main() {
  late AppDatabase database;
  late SubscriberRepository repository;
  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = SubscriberRepository(database);
    await database.batch(
      (batch) => batch.insertAll(database.subscribers, [
        for (var i = 0; i < 550; i++)
          SubscribersCompanion.insert(
            name: 'Reader ${i.toString().padLeft(3, '0')}',
          ),
      ]),
    );
  });
  tearDown(() => database.close());

  test('pages through 550 rows without omissions or duplicates', () async {
    final ids = <int>{};
    for (var offset = 0; offset < 550; offset += 25) {
      final page = await repository.getSubscribersPage(offset: offset);
      expect(page.total, 550);
      expect(page.rows.length, 25);
      ids.addAll(page.rows.map((row) => row.id));
    }
    expect(ids.length, 550);
    final last = await repository.getSubscribersPage(offset: 540, limit: 10);
    expect(last.rows.length, 10);
    final partial = await repository.getSubscribersPage(offset: 525, limit: 50);
    expect(partial.rows.length, 25);
    expect((await repository.getSubscribersPage(offset: 550)).rows, isEmpty);
  });

  test(
    'search is literal, excludes archived rows and matches contacts',
    () async {
      final literal = await repository.createSubscriber(
        name: '100%_Special',
        email: 'unique@example.com',
        phone: '555-0199',
      );
      expect(
        (await repository.getSubscribersPage(search: '%_')).rows.single.id,
        literal.id,
      );
      expect(
        (await repository.getSubscribersPage(search: ' UNIQUE@ ')).total,
        1,
      );
      expect(
        (await repository.getSubscribersPage(search: '555-0199')).total,
        1,
      );
      await repository.archiveSubscriber(literal.id);
      expect((await repository.getSubscribersPage(search: '%_')).total, 0);
    },
  );

  test(
    'sorting is stable for equal names and supports descending ID',
    () async {
      final first = await repository.createSubscriber(name: 'same');
      final second = await repository.createSubscriber(name: 'SAME');
      final page = await repository.getSubscribersPage(search: 'same');
      expect(page.rows.map((row) => row.id), [first.id, second.id]);
      final descending = await repository.getSubscribersPage(
        sortBy: SubscriberSort.number,
        ascending: false,
      );
      expect(descending.rows.first.id, second.id);
    },
  );

  test('rejects invalid pagination', () {
    expect(
      () => repository.getSubscribersPage(offset: -1),
      throwsArgumentError,
    );
    expect(
      () => repository.getSubscribersPage(limit: 1000),
      throwsArgumentError,
    );
  });
}
