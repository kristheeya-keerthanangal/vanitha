import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';
import 'package:vanithabodhini/data/repositories/subscription_repository.dart';
import 'package:vanithabodhini/data/subscription_status.dart';

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

  test('search matches an exact pincode only', () async {
    final exact = await repository.createSubscriber(
      name: 'Pincode Reader',
      postalCode: '560001',
    );
    final neighbour = await repository.createSubscriber(
      name: 'Neighbour Reader',
      postalCode: '560002',
    );
    final leadingZero = await repository.createSubscriber(
      name: 'Leading Zero Reader',
      postalCode: '060001',
    );

    expect(
      (await repository.getSubscribersPage(search: '560001')).rows.single.id,
      exact.id,
    );
    expect(
      (await repository.getSubscribersPage(search: ' 560001 ')).rows.single.id,
      exact.id,
    );
    expect((await repository.getSubscribersPage(search: '5600')).total, 0);
    expect(
      (await repository.getSubscribersPage(search: '560002')).rows.single.id,
      neighbour.id,
    );
    expect(
      (await repository.getSubscribersPage(search: '060001')).rows.single.id,
      leadingZero.id,
    );

    await repository.archiveSubscriber(exact.id);
    expect((await repository.getSubscribersPage(search: '560001')).total, 0);
  });

  test(
    'classifies subscriber status by maximum expiry and filters it consistently',
    () async {
      final subscriptions = SubscriptionRepository(database);
      final today = DateTime.now();
      ({int year, int month}) addMonths(int year, int month, int delta) {
        final total = year * 12 + (month - 1) + delta;
        return (year: total ~/ 12, month: (total % 12) + 1);
      }

      String formatYearMonth(int year, int month) =>
          '$year-${month.toString().padLeft(2, '0')}';

      final futureStart = addMonths(today.year, today.month, 2);
      final futureExpiry = addMonths(futureStart.year, futureStart.month, 11);
      final expiresThisMonthStart = addMonths(today.year, today.month, -11);
      final expiredStart = addMonths(today.year, today.month, -36);
      final activeAndFutureStart = addMonths(today.year, today.month, -1);

      final futureSubscriber = await repository.createSubscriber(
        name: 'Status Reader Future',
      );
      final expiresTodaySubscriber = await repository.createSubscriber(
        name: 'Status Reader Expires Today',
      );
      final expiredSubscriber = await repository.createSubscriber(
        name: 'Status Reader Expired',
      );
      final noSubscription = await repository.createSubscriber(
        name: 'Status Reader None',
      );
      final mixedSubscriber = await repository.createSubscriber(
        name: 'Status Reader Mixed',
      );
      final activeAndFutureSubscriber = await repository.createSubscriber(
        name: 'Status Reader Active and Future',
      );
      final archivedSubscriptionSubscriber = await repository.createSubscriber(
        name: 'Status Reader Archived',
      );

      Future<int> addAnnualSubscription(
        int subscriberId,
        int startYear,
        int startMonth,
      ) {
        return subscriptions
            .createSubscription(
              subscriberId: subscriberId,
              edition: 'online',
              planType: 'annual',
              durationYears: 1,
              startYear: startYear,
              startMonth: startMonth,
            )
            .then((subscription) => subscription.id);
      }

      await addAnnualSubscription(
        futureSubscriber.id,
        futureStart.year,
        futureStart.month,
      );
      // Expiry is inclusive: a subscription ending this month remains active.
      await addAnnualSubscription(
        expiresTodaySubscriber.id,
        expiresThisMonthStart.year,
        expiresThisMonthStart.month,
      );
      await addAnnualSubscription(
        expiredSubscriber.id,
        expiredStart.year,
        expiredStart.month,
      );
      await addAnnualSubscription(
        mixedSubscriber.id,
        expiredStart.year,
        expiredStart.month,
      );
      await addAnnualSubscription(
        mixedSubscriber.id,
        futureStart.year,
        futureStart.month,
      );
      await addAnnualSubscription(
        activeAndFutureSubscriber.id,
        activeAndFutureStart.year,
        activeAndFutureStart.month,
      );
      await addAnnualSubscription(
        activeAndFutureSubscriber.id,
        futureStart.year,
        futureStart.month,
      );
      final archivedSubscriptionId = await addAnnualSubscription(
        archivedSubscriptionSubscriber.id,
        expiredStart.year,
        expiredStart.month,
      );
      await subscriptions.archiveSubscription(archivedSubscriptionId);

      final all = await repository.getSubscribersPage(search: 'Status Reader');
      final active = await repository.getSubscribersPage(
        search: 'Status Reader',
        filterBy: SubscriberFilter.active,
      );
      final expired = await repository.getSubscribersPage(
        search: 'Status Reader',
        filterBy: SubscriberFilter.expired,
      );

      expect(all.total, 7);
      expect(active.rows.map((subscriber) => subscriber.id).toSet(), {
        expiresTodaySubscriber.id,
        activeAndFutureSubscriber.id,
        futureSubscriber.id,
        mixedSubscriber.id,
      });
      expect(active.total, 4);
      expect(expired.rows.map((subscriber) => subscriber.id).toSet(), {
        expiredSubscriber.id,
      });
      expect(expired.total, 1);
      expect(expired.rows, isNot(contains(noSubscription)));
      expect(expired.rows, isNot(contains(archivedSubscriptionSubscriber)));
      expect(active.rows, isNot(contains(noSubscription)));
      expect(active.rows, isNot(contains(archivedSubscriptionSubscriber)));
      expect(
        all.rows.map((subscriber) => subscriber.id),
        containsAll([noSubscription.id, archivedSubscriptionSubscriber.id]),
      );
      expect(
        all.statuses[futureSubscriber.id]?.status,
        SubscriptionStatus.active,
      );
      expect(all.statuses[futureSubscriber.id]?.expiryDate, isNotNull);
      expect(
        all.statuses[expiresTodaySubscriber.id]?.status,
        SubscriptionStatus.active,
      );
      expect(
        all.statuses[mixedSubscriber.id]?.status,
        SubscriptionStatus.active,
      );
      expect(
        all.statuses[activeAndFutureSubscriber.id]?.status,
        SubscriptionStatus.active,
      );
      expect(
        all.statuses[mixedSubscriber.id]?.expiryDate,
        formatYearMonth(futureExpiry.year, futureExpiry.month),
      );
      expect(
        all.statuses[expiredSubscriber.id]?.status,
        SubscriptionStatus.expired,
      );
      expect(
        all.statuses[noSubscription.id]?.status,
        SubscriptionStatus.notSubscribed,
      );
      expect(
        all.statuses[archivedSubscriptionSubscriber.id]?.status,
        SubscriptionStatus.notSubscribed,
      );
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
