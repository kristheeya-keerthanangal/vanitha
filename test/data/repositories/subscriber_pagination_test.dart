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

  test(
    'classifies subscriber status by priority and filters it consistently',
    () async {
      final subscriptions = SubscriptionRepository(database);
      final today = DateTime.now();
      final dateOnly = DateTime(today.year, today.month, today.day);
      final upcomingStartDate = dateOnly.add(const Duration(days: 30));
      final upcomingExpiryDate = DateTime(
        upcomingStartDate.year + 1,
        upcomingStartDate.month,
        upcomingStartDate.day,
      );
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
      final activeAndUpcomingSubscriber = await repository.createSubscriber(
        name: 'Status Reader Active and Upcoming',
      );
      final archivedSubscriptionSubscriber = await repository.createSubscriber(
        name: 'Status Reader Archived',
      );

      Future<int> addAnnualSubscription(int subscriberId, DateTime startDate) {
        return subscriptions
            .createSubscription(
              subscriberId: subscriberId,
              edition: 'online',
              planType: 'annual',
              durationYears: 1,
              startDate: startDate,
            )
            .then((subscription) => subscription.id);
      }

      await addAnnualSubscription(
        futureSubscriber.id,
        dateOnly.add(const Duration(days: 30)),
      );
      // Expiry is inclusive: a subscription ending today remains active.
      await addAnnualSubscription(
        expiresTodaySubscriber.id,
        DateTime(dateOnly.year - 1, dateOnly.month, dateOnly.day),
      );
      await addAnnualSubscription(
        expiredSubscriber.id,
        DateTime(today.year - 3, today.month, today.day),
      );
      await addAnnualSubscription(
        mixedSubscriber.id,
        DateTime(today.year - 3, today.month, today.day),
      );
      await addAnnualSubscription(mixedSubscriber.id, upcomingStartDate);
      await addAnnualSubscription(
        activeAndUpcomingSubscriber.id,
        dateOnly.subtract(const Duration(days: 30)),
      );
      await addAnnualSubscription(
        activeAndUpcomingSubscriber.id,
        upcomingStartDate,
      );
      final archivedSubscriptionId = await addAnnualSubscription(
        archivedSubscriptionSubscriber.id,
        DateTime(today.year - 3, today.month, today.day),
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
        activeAndUpcomingSubscriber.id,
      });
      expect(active.total, 2);
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
        SubscriptionStatus.upcoming,
      );
      expect(all.statuses[futureSubscriber.id]?.expiryDate, isNotNull);
      expect(
        all.statuses[expiresTodaySubscriber.id]?.status,
        SubscriptionStatus.active,
      );
      expect(
        all.statuses[mixedSubscriber.id]?.status,
        SubscriptionStatus.upcoming,
      );
      expect(
        all.statuses[activeAndUpcomingSubscriber.id]?.status,
        SubscriptionStatus.active,
      );
      expect(
        all.statuses[mixedSubscriber.id]?.expiryDate,
        '${upcomingExpiryDate.year}-${upcomingExpiryDate.month.toString().padLeft(2, '0')}-${upcomingExpiryDate.day.toString().padLeft(2, '0')}',
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
