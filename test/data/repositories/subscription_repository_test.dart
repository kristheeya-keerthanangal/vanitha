import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';
import 'package:vanithabodhini/data/repositories/subscription_repository.dart';

void main() {
  late AppDatabase database;
  late SubscriberRepository subscriberRepository;
  late SubscriptionRepository repository;
  late int subscriberId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    subscriberRepository = SubscriberRepository(database);
    repository = SubscriptionRepository(database);
    subscriberId = (await subscriberRepository.createSubscriber(
      name: 'Anita Rao',
    )).id;
  });

  tearDown(() async {
    await database.close();
  });

  test('creates a subscription and calculates its expiry date', () async {
    final created = await repository.createSubscription(
      subscriberId: subscriberId,
      edition: 'online',
      planType: 'annual',
      durationYears: 1,
      startDate: DateTime(2026, 2, 10, 15, 30),
      paymentStatus: 'paid',
    );

    expect(created.id, 1);
    expect(created.subscriberId, subscriberId);
    expect(created.startDate, '2026-02-10');
    expect(created.expiryDate, '2027-02-10');
    expect(created.paymentStatus, 'paid');
    expect(await repository.getSubscription(created.id), created);
  });

  test('uses fixed durations for annual and lifetime plans', () async {
    final annual = await repository.createSubscription(
      subscriberId: subscriberId,
      edition: 'online',
      planType: 'annual',
      durationYears: 99,
      startDate: DateTime(2026, 2, 10),
      paymentStatus: 'paid',
    );
    final lifetime = await repository.createSubscription(
      subscriberId: subscriberId,
      edition: 'online',
      planType: 'lifetime',
      durationYears: 1,
      startDate: DateTime(2026, 2, 10),
      paymentStatus: 'paid',
    );

    expect(annual.durationYears, 1);
    expect(annual.expiryDate, '2027-02-10');
    expect(lifetime.durationYears, 10);
    expect(lifetime.expiryDate, '2036-02-10');
  });

  test('lists subscriptions for a subscriber in start-date order', () async {
    await repository.createSubscription(
      subscriberId: subscriberId,
      edition: 'offline',
      planType: 'multi_year',
      durationYears: 3,
      startDate: DateTime(2027, 1, 1),
      paymentStatus: 'unpaid',
    );
    await repository.createSubscription(
      subscriberId: subscriberId,
      edition: 'online',
      planType: 'lifetime',
      durationYears: 10,
      startDate: DateTime(2026, 1, 1),
      paymentStatus: 'paid',
    );

    final subscriptions = await repository.getSubscriptionsForSubscriber(
      subscriberId,
    );
    expect(subscriptions.map((item) => item.startDate), [
      '2027-01-01',
      '2026-01-01',
    ]);
  });

  test('recalculates expiry when an editable subscription changes', () async {
    final created = await repository.createSubscription(
      subscriberId: subscriberId,
      edition: 'online',
      planType: 'multi_year',
      durationYears: 2,
      startDate: DateTime(2026, 2, 10),
      paymentStatus: 'unpaid',
    );

    final updated = await repository.updateSubscription(
      created.copyWith(
        durationYears: 3,
        startDate: '2026-03-15',
        paymentStatus: 'paid',
      ),
    );

    expect(updated.expiryDate, '2029-03-15');
    expect(updated.updatedAt, isNot(created.updatedAt));
  });

  test('normalizes timestamp start dates when updating', () async {
    final created = await repository.createSubscription(
      subscriberId: subscriberId,
      edition: 'online',
      planType: 'annual',
      durationYears: 1,
      startDate: DateTime(2026, 2, 10),
      paymentStatus: 'paid',
    );

    final updated = await repository.updateSubscription(
      created.copyWith(startDate: '2026-03-15T12:00:00Z'),
    );

    expect(updated.startDate, '2026-03-15');
    expect(updated.expiryDate, '2027-03-15');
  });

  test('rejects invalid calendar dates when updating', () async {
    final created = await repository.createSubscription(
      subscriberId: subscriberId,
      edition: 'online',
      planType: 'annual',
      durationYears: 1,
      startDate: DateTime(2026, 2, 10),
      paymentStatus: 'paid',
    );

    expect(
      repository.updateSubscription(created.copyWith(startDate: '2026-02-30')),
      throwsA(isA<FormatException>()),
    );
  });

  test('enforces subscription value constraints', () async {
    expect(
      repository.createSubscription(
        subscriberId: subscriberId,
        edition: 'print',
        planType: 'annual',
        durationYears: 1,
        startDate: DateTime(2026),
        paymentStatus: 'paid',
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('rejects subscriptions for an unknown subscriber', () async {
    expect(
      repository.createSubscription(
        subscriberId: 999,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startDate: DateTime(2026, 1, 1),
        paymentStatus: 'paid',
      ),
      throwsA(isA<Exception>()),
    );
  });

  Future<Subscription> createSubscription() => repository.createSubscription(
    subscriberId: subscriberId,
    edition: 'online',
    planType: 'annual',
    durationYears: 1,
    startDate: DateTime(2026, 1, 1),
    paymentStatus: 'unpaid',
  );

  test(
    'deletion archives a subscription and restoration keeps its data',
    () async {
      final original = await createSubscription();
      await repository.deleteSubscription(original.id);
      expect(await repository.getSubscription(original.id), isNull);
      expect(
        await repository.getSubscriptionsForSubscriber(subscriberId),
        isEmpty,
      );
      final archived = await repository.getSubscription(
        original.id,
        includeArchived: true,
      );
      expect(archived, isNotNull);
      expect(archived!.archivedAt, isNotNull);
      expect(
        await repository.getSubscriptionsForSubscriber(
          subscriberId,
          includeArchived: true,
        ),
        [archived],
      );
      expect(await repository.archiveSubscription(original.id), archived);
      final restored = await repository.restoreSubscription(original.id);
      expect(restored.archivedAt, isNull);
      expect(restored.copyWith(updatedAt: original.updatedAt), original);
      expect(await repository.restoreSubscription(original.id), restored);
    },
  );

  test(
    'rejects stale edits without losing the latest payment status',
    () async {
      final original = await createSubscription();
      final latest = await repository.updateSubscription(
        original.copyWith(paymentStatus: 'paid'),
      );
      await expectLater(
        repository.updateSubscription(original.copyWith(edition: 'offline')),
        throwsStateError,
      );
      expect(await repository.getSubscription(original.id), latest);
    },
  );

  test('stale edits cannot undo a subscription archive', () async {
    final original = await createSubscription();
    final archived = await repository.archiveSubscription(original.id);
    await expectLater(
      repository.updateSubscription(original.copyWith(paymentStatus: 'paid')),
      throwsStateError,
    );
    expect(
      await repository.getSubscription(original.id, includeArchived: true),
      archived,
    );
  });

  test('invalid updates preserve all previous subscription data', () async {
    final original = await createSubscription();
    await expectLater(
      repository.updateSubscription(original.copyWith(edition: 'invalid')),
      throwsA(isA<Exception>()),
    );
    expect(await repository.getSubscription(original.id), original);
  });

  test('updates preserve subscription creation timestamps', () async {
    final original = await createSubscription();
    final updated = await repository.updateSubscription(
      original.copyWith(paymentStatus: 'paid', createdAt: 'changed'),
    );
    expect(updated.createdAt, original.createdAt);
  });

  test(
    'missing subscription mutations fail without changing existing rows',
    () async {
      final original = await createSubscription();
      await expectLater(
        repository.updateSubscription(original.copyWith(id: 999)),
        throwsStateError,
      );
      await expectLater(repository.deleteSubscription(999), throwsStateError);
      await expectLater(repository.restoreSubscription(999), throwsStateError);
      expect(await repository.getSubscription(original.id), original);
    },
  );

  test(
    'creation rolls back when the inserted row cannot be read back',
    () async {
      await database.customStatement('''
      CREATE TRIGGER move_inserted_subscription AFTER INSERT ON subscriptions
      BEGIN UPDATE subscriptions SET id = NEW.id + 1000 WHERE id = NEW.id; END
    ''');
      await expectLater(createSubscription(), throwsStateError);
      expect(await database.select(database.subscriptions).get(), isEmpty);
    },
  );

  test('updates roll back when the saved row cannot be read back', () async {
    final original = await createSubscription();
    await database.customStatement('''
      CREATE TRIGGER move_updated_subscription AFTER UPDATE ON subscriptions
      BEGIN UPDATE subscriptions SET id = NEW.id + 1000 WHERE id = NEW.id; END
    ''');
    await expectLater(
      repository.updateSubscription(original.copyWith(paymentStatus: 'paid')),
      throwsStateError,
    );
    expect(await database.select(database.subscriptions).get(), [original]);
  });
}
