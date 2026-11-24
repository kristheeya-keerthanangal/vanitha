import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';
import 'package:vanithabodhini/data/repositories/subscription_repository.dart';

void main() {
  late AppDatabase database;
  late SubscriberRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = SubscriberRepository(database);
  });

  tearDown(() => database.close());

  test('returns an empty mailing list for an empty database', () async {
    expect(await repository.getMailingList(), isEmpty);
  });

  test('returns all non-archived subscribers without a page limit', () async {
    final subscriptions = SubscriptionRepository(database);
    await database.batch(
      (batch) => batch.insertAll(database.subscribers, [
        for (var i = 0; i < 125; i++)
          SubscribersCompanion.insert(
            name: 'Reader ${i.toString().padLeft(3, '0')}',
            postalAddress: const Value('Main Street'),
            postalCode: const Value('682001'),
          ),
      ]),
    );
    await database.batch(
      (batch) => batch.insertAll(database.subscriptions, [
        for (var i = 1; i <= 125; i++)
          SubscriptionsCompanion.insert(
            subscriberId: i,
            edition: 'offline',
            planType: 'annual',
            durationYears: 1,
            startDate: '2026-01-01',
            expiryDate: '2099-12-31',
          ),
      ]),
    );
    final archived = await repository.createSubscriber(name: 'Archived');
    await subscriptions.createSubscription(
      subscriberId: archived.id,
      edition: 'offline',
      planType: 'annual',
      durationYears: 1,
      startDate: DateTime.now(),
    );
    await repository.archiveSubscriber(archived.id);

    final rows = await repository.getMailingList();

    expect(rows, hasLength(125));
    expect(
      rows.map((row) => row.subscriberId),
      List.generate(125, (i) => i + 1),
    );
    expect(rows.first.name, 'Reader 000');
    expect(rows.first.postalAddress, 'Main Street');
    expect(rows.first.postalCode, '682001');
    expect(rows.every((row) => !row.hasIncompleteMailingDetails), isTrue);

    await repository.restoreSubscriber(archived.id);
    expect(await repository.getMailingList(), hasLength(126));
  });

  test(
    'orders names case-insensitively, breaks ties by ID, and puts missing PINs last',
    () async {
      final subscriptions = SubscriptionRepository(database);
      Future<Subscriber> add(String name, String? pin) async {
        final subscriber =
            await repository.createSubscriber(name: name, postalCode: pin);
        await subscriptions.createSubscription(
          subscriberId: subscriber.id,
          edition: 'offline',
          planType: 'annual',
          durationYears: 1,
          startDate: DateTime.now(),
        );
        return subscriber;
      }

      final missingZ = await add('Zara', null);
      final zara = await add('Zara', '100001');
      final firstAnita = await add('anita', '900001');
      final secondAnita = await add('ANITA', '100001');
      final missingA = await add('Anita', '  ');
      final missingATie = await add('ANITA', null);
      final bela = await add('Bela', '500001');

      expect(
        (await repository.getMailingList()).map((row) => row.subscriberId),
        [
          firstAnita.id,
          secondAnita.id,
          bela.id,
          zara.id,
          missingA.id,
          missingATie.id,
          missingZ.id,
        ],
      );
    },
  );

  test(
    'keeps distinct subscribers with identical details and emits one row per subscriber regardless of subscriptions',
    () async {
      final first = await repository.createSubscriber(
        name: 'Same Reader',
        postalAddress: 'Same Address',
        postalCode: '682001',
      );
      final second = await repository.createSubscriber(
        name: first.name,
        postalAddress: first.postalAddress,
        postalCode: first.postalCode,
      );
      final subscriptions = SubscriptionRepository(database);
      for (final edition in ['online', 'offline']) {
        await subscriptions.createSubscription(
          subscriberId: first.id,
          edition: edition,
          planType: 'annual',
          durationYears: 1,
          startDate: DateTime.now(),
        );
      }
      await subscriptions.createSubscription(
        subscriberId: second.id,
        edition: 'offline',
        planType: 'annual',
        durationYears: 1,
        startDate: DateTime.now(),
      );

      final rows = await repository.getMailingList();
      expect(rows.map((row) => row.subscriberId), [first.id, second.id]);
      expect(rows.map((row) => row.name), ['Same Reader', 'Same Reader']);
      expect(rows.map((row) => row.postalAddress), [
        'Same Address',
        'Same Address',
      ]);
      expect(rows.map((row) => row.postalCode), ['682001', '682001']);
    },
  );

  test(
    'retains null, empty, and whitespace details and flags each missing field',
    () async {
      final expected = <int, (String?, String?, bool, bool)>{};
      for (final address in <String?>[null, '', ' \t\n ', 'Main Street']) {
        for (final pin in <String?>[null, '', ' \t\n ', '682001']) {
          // Insert directly to cover legacy blanks that creation normalizes to null.
          final id = await database
              .into(database.subscribers)
              .insert(
                SubscribersCompanion.insert(
                  name: 'Reader',
                  postalAddress: Value(address),
                  postalCode: Value(pin),
                ),
              );
          await database.into(database.subscriptions).insert(
            SubscriptionsCompanion.insert(
              subscriberId: id,
              edition: 'offline',
              planType: 'annual',
              durationYears: 1,
              startDate: '2026-01-01',
              expiryDate: '2099-12-31',
            ),
          );
          expected[id] = (
            address,
            pin,
            address == null || address.trim().isEmpty,
            pin == null || pin.trim().isEmpty,
          );
        }
      }

      final rows = await repository.getMailingList();
      expect(rows, hasLength(expected.length));
      expect(
        rows.map((row) => row.subscriberId).toSet(),
        expected.keys.toSet(),
      );
      for (final row in rows) {
        final (address, pin, addressMissing, pinMissing) =
            expected[row.subscriberId]!;
        expect(row.postalAddress, address);
        expect(row.postalCode, pin);
        expect(row.isAddressMissing, addressMissing);
        expect(row.isPostalCodeMissing, pinMissing);
        expect(row.hasIncompleteMailingDetails, addressMissing || pinMissing);
      }
      final pinMissing = rows.map((row) => row.isPostalCodeMissing).toList();
      expect(pinMissing, [
        false,
        false,
        false,
        false,
        ...List.filled(12, true),
      ]);
    },
  );

  test('filters mailing list by active, expired, and all for offline edition', () async {
    final subscriptions = SubscriptionRepository(database);
    final today = DateTime.now();

    // 1. Active offline subscriber
    final activeOffline = await repository.createSubscriber(
      name: 'Active Offline',
    );
    await subscriptions.createSubscription(
      subscriberId: activeOffline.id,
      edition: 'offline',
      planType: 'annual',
      durationYears: 1,
      startDate: today,
    );

    // 2. Expired offline subscriber
    final expiredOffline = await repository.createSubscriber(
      name: 'Expired Offline',
    );
    await subscriptions.createSubscription(
      subscriberId: expiredOffline.id,
      edition: 'offline',
      planType: 'annual',
      durationYears: 1,
      startDate: DateTime(today.year - 3, today.month, today.day),
    );

    // 3. Online-only active subscriber
    final activeOnline = await repository.createSubscriber(
      name: 'Active Online',
    );
    await subscriptions.createSubscription(
      subscriberId: activeOnline.id,
      edition: 'online',
      planType: 'annual',
      durationYears: 1,
      startDate: today,
    );

    // 4. Online-only expired subscriber
    final expiredOnline = await repository.createSubscriber(
      name: 'Expired Online',
    );
    await subscriptions.createSubscription(
      subscriberId: expiredOnline.id,
      edition: 'online',
      planType: 'annual',
      durationYears: 1,
      startDate: DateTime(today.year - 3, today.month, today.day),
    );

    // 5. Never subscribed subscriber
    final neverSubscribed = await repository.createSubscriber(
      name: 'Never Subscribed',
    );

    // 6. Mixed subscriber (active offline and expired offline)
    final mixedOffline = await repository.createSubscriber(
      name: 'Mixed Offline',
    );
    await subscriptions.createSubscription(
      subscriberId: mixedOffline.id,
      edition: 'offline',
      planType: 'annual',
      durationYears: 1,
      startDate: DateTime(today.year - 3, today.month, today.day),
    );
    await subscriptions.createSubscription(
      subscriberId: mixedOffline.id,
      edition: 'offline',
      planType: 'annual',
      durationYears: 1,
      startDate: today,
    );

    // Test Active filter (default)
    final activeList = await repository.getMailingList();
    expect(
      activeList.map((e) => e.subscriberId).toSet(),
      {activeOffline.id, mixedOffline.id},
    );

    // Test Expired filter
    final expiredList = await repository.getMailingList(
      filter: MailingListFilter.expired,
    );
    expect(
      expiredList.map((e) => e.subscriberId).toSet(),
      {expiredOffline.id},
    );

    // Test All filter: includes active, expired, online, and never-subscribed users
    final allList = await repository.getMailingList(
      filter: MailingListFilter.all,
    );
    expect(
      allList.map((e) => e.subscriberId).toSet(),
      {
        activeOffline.id,
        expiredOffline.id,
        activeOnline.id,
        expiredOnline.id,
        neverSubscribed.id,
        mixedOffline.id,
      },
    );
  });

  test('ignores archived subscriptions when determining offline mailing status', () async {
    final subscriptions = SubscriptionRepository(database);
    final today = DateTime.now();

    final subscriber = await repository.createSubscriber(name: 'Archived Sub');
    final activeSub = await subscriptions.createSubscription(
      subscriberId: subscriber.id,
      edition: 'offline',
      planType: 'annual',
      durationYears: 1,
      startDate: today,
    );
    final expiredSub = await subscriptions.createSubscription(
      subscriberId: subscriber.id,
      edition: 'offline',
      planType: 'annual',
      durationYears: 1,
      startDate: DateTime(today.year - 3, today.month, today.day),
    );

    // Initially active
    expect(
      (await repository.getMailingList()).map((e) => e.subscriberId),
      [subscriber.id],
    );

    // Archive the active subscription -> should now be expired
    await subscriptions.archiveSubscription(activeSub.id);
    expect(await repository.getMailingList(), isEmpty);
    expect(
      (await repository.getMailingList(filter: MailingListFilter.expired))
          .map((e) => e.subscriberId),
      [subscriber.id],
    );

    // Archive the expired subscription -> should now be notSubscribed (not in active or expired, but in all)
    await subscriptions.archiveSubscription(expiredSub.id);
    expect(await repository.getMailingList(), isEmpty);
    expect(
      await repository.getMailingList(filter: MailingListFilter.expired),
      isEmpty,
    );
    expect(
      (await repository.getMailingList(filter: MailingListFilter.all))
          .map((e) => e.subscriberId),
      [subscriber.id],
    );
  });
}
