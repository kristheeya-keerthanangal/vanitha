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
    );

    expect(created.id, 1);
    expect(created.subscriberId, subscriberId);
    expect(created.startDate, '2026-02-10');
    expect(created.expiryDate, '2027-02-10');
    expect(await repository.getSubscription(created.id), created);
  });

  test('uses fixed durations for annual and lifetime plans', () async {
    final annual = await repository.createSubscription(
      subscriberId: subscriberId,
      edition: 'online',
      planType: 'annual',
      durationYears: 99,
      startDate: DateTime(2026, 2, 10),
    );
    final lifetime = await repository.createSubscription(
      subscriberId: subscriberId,
      edition: 'online',
      planType: 'lifetime',
      durationYears: 1,
      startDate: DateTime(2026, 2, 10),
    );

    expect(annual.durationYears, 1);
    expect(annual.expiryDate, '2027-02-10');
    expect(lifetime.durationYears, 10);
    expect(lifetime.expiryDate, '2036-02-10');
  });

  test('rejects multi-year durations over 50 years', () async {
    expect(
      repository.createSubscription(
        subscriberId: subscriberId,
        edition: 'online',
        planType: 'multi_year',
        durationYears: 51,
        startDate: DateTime(2026, 2, 10),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test(
    'renews annual, multi-year, and lifetime plans with supplied terms',
    () async {
      await repository.createSubscription(
        subscriberId: subscriberId,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startDate: DateTime(2020, 1, 1),
      );

      final annual = await repository.renewSubscription(
        subscriberId: subscriberId,
        edition: 'offline',
        planType: 'annual',
        durationYears: 50,
        startDate: DateTime(2022, 2, 3),
      );
      final multiYear = await repository.renewSubscription(
        subscriberId: subscriberId,
        edition: 'online',
        planType: 'multi_year',
        durationYears: 4,
        startDate: DateTime(2024, 2, 3),
      );
      final lifetime = await repository.renewSubscription(
        subscriberId: subscriberId,
        edition: 'offline',
        planType: 'lifetime',
        durationYears: 1,
        startDate: DateTime(2029, 2, 3),
      );

      expect(annual.edition, 'offline');
      expect(annual.durationYears, 1);
      expect(annual.expiryDate, '2023-02-03');
      expect(multiYear.edition, 'online');
      expect(multiYear.durationYears, 4);
      expect(multiYear.expiryDate, '2028-02-03');
      expect(lifetime.edition, 'offline');
      expect(lifetime.durationYears, 10);
      expect(lifetime.expiryDate, '2039-02-03');
    },
  );

  test(
    'renews after the greatest active expiry using the entered start date',
    () async {
      await repository.createSubscription(
        subscriberId: subscriberId,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startDate: DateTime(2026, 1, 1),
      );
      await repository.createSubscription(
        subscriberId: subscriberId,
        edition: 'offline',
        planType: 'multi_year',
        durationYears: 3,
        startDate: DateTime(2027, 1, 1),
      );

      final renewal = await repository.renewSubscription(
        subscriberId: subscriberId,
        edition: 'online',
        planType: 'annual',
        durationYears: 50,
        startDate: DateTime(2030, 1, 15, 18),
      );

      expect(renewal.startDate, '2030-01-15');
      expect(renewal.expiryDate, '2031-01-15');
      expect(renewal.edition, 'online');
      expect(renewal.planType, 'annual');
      expect(renewal.durationYears, 1);
    },
  );

  test('rejects renewal without an active subscription', () async {
    await expectLater(
      repository.renewSubscription(
        subscriberId: subscriberId,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startDate: DateTime(2026, 1, 2),
      ),
      throwsStateError,
    );
  });

  test('rejects renewal on or before the greatest active expiry', () async {
    final original = await repository.createSubscription(
      subscriberId: subscriberId,
      edition: 'online',
      planType: 'annual',
      durationYears: 1,
      startDate: DateTime(2026, 1, 1),
    );

    for (final startDate in [DateTime(2027, 1, 1), DateTime(2026, 12, 31)]) {
      await expectLater(
        repository.renewSubscription(
          subscriberId: subscriberId,
          edition: 'offline',
          planType: 'lifetime',
          durationYears: 1,
          startDate: startDate,
        ),
        throwsArgumentError,
      );
    }

    expect(await repository.getSubscriptionsForSubscriber(subscriberId), [
      original,
    ]);
  });

  test('allows future and late renewals while rejecting overlaps', () async {
    await repository.createSubscription(
      subscriberId: subscriberId,
      edition: 'online',
      planType: 'annual',
      durationYears: 1,
      startDate: DateTime(2026, 1, 1),
    );

    final future = await repository.renewSubscription(
      subscriberId: subscriberId,
      edition: 'online',
      planType: 'annual',
      durationYears: 1,
      startDate: DateTime(2028, 1, 1),
    );
    expect(future.expiryDate, '2029-01-01');

    final late = await repository.renewSubscription(
      subscriberId: subscriberId,
      edition: 'offline',
      planType: 'multi_year',
      durationYears: 2,
      startDate: DateTime(2035, 6, 1),
    );
    expect(late.startDate, '2035-06-01');
    expect(late.expiryDate, '2037-06-01');

    await expectLater(
      repository.renewSubscription(
        subscriberId: subscriberId,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startDate: DateTime(2037, 6, 1),
      ),
      throwsArgumentError,
    );
  });

  test('uses an existing upcoming renewal as the latest expiry', () async {
    await repository.createSubscription(
      subscriberId: subscriberId,
      edition: 'online',
      planType: 'annual',
      durationYears: 1,
      startDate: DateTime(2026, 1, 1),
    );
    final upcoming = await repository.renewSubscription(
      subscriberId: subscriberId,
      edition: 'offline',
      planType: 'annual',
      durationYears: 1,
      startDate: DateTime(2028, 1, 1),
    );

    await expectLater(
      repository.renewSubscription(
        subscriberId: subscriberId,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startDate: DateTime(2029, 1, 1),
      ),
      throwsArgumentError,
    );

    final next = await repository.renewSubscription(
      subscriberId: subscriberId,
      edition: 'online',
      planType: 'annual',
      durationYears: 1,
      startDate: DateTime(2030, 1, 1),
    );
    expect(next.startDate, '2030-01-01');
    expect(upcoming.expiryDate, '2029-01-01');
  });

  test('ignores archived subscriptions when validating a renewal', () async {
    final original = await repository.createSubscription(
      subscriberId: subscriberId,
      edition: 'online',
      planType: 'annual',
      durationYears: 1,
      startDate: DateTime(2026, 1, 1),
    );
    await repository.archiveSubscription(original.id);

    await expectLater(
      repository.renewSubscription(
        subscriberId: subscriberId,
        edition: 'offline',
        planType: 'multi_year',
        durationYears: 2,
        startDate: DateTime(2026, 1, 2),
      ),
      throwsStateError,
    );
  });

  test(
    'does not create or renew subscriptions for archived subscribers',
    () async {
      final archived = await subscriberRepository.archiveSubscriber(
        subscriberId,
      );

      await expectLater(
        repository.createSubscription(
          subscriberId: archived.id,
          edition: 'online',
          planType: 'annual',
          durationYears: 1,
          startDate: DateTime(2026, 1, 1),
        ),
        throwsStateError,
      );
    },
  );

  test(
    'does not renew an existing subscription after its subscriber is archived',
    () async {
      await repository.createSubscription(
        subscriberId: subscriberId,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startDate: DateTime(2026, 1, 1),
      );
      await subscriberRepository.archiveSubscriber(subscriberId);

      await expectLater(
        repository.renewSubscription(
          subscriberId: subscriberId,
          edition: 'offline',
          planType: 'annual',
          durationYears: 1,
          startDate: DateTime(2027, 1, 2),
        ),
        throwsStateError,
      );
    },
  );

  test(
    'archival changes the renewal ordering and restoration restores it',
    () async {
      final original = await repository.createSubscription(
        subscriberId: subscriberId,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startDate: DateTime(2026, 1, 1),
      );
      final later = await repository.createSubscription(
        subscriberId: subscriberId,
        edition: 'offline',
        planType: 'annual',
        durationYears: 1,
        startDate: DateTime(2028, 1, 1),
      );
      await repository.archiveSubscription(later.id);

      final renewal = await repository.renewSubscription(
        subscriberId: subscriberId,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startDate: DateTime(2028, 1, 1),
      );
      expect(renewal.startDate, '2028-01-01');
      expect(
        await repository.getSubscriptionsForSubscriber(subscriberId),
        containsAll([original, renewal]),
      );

      final restored = await repository.restoreSubscription(later.id);
      expect(restored.archivedAt, isNull);
      await expectLater(
        repository.renewSubscription(
          subscriberId: subscriberId,
          edition: 'offline',
          planType: 'annual',
          durationYears: 1,
          startDate: DateTime(2029, 1, 1),
        ),
        throwsArgumentError,
      );
    },
  );

  test('lists subscriptions for a subscriber in start-date order', () async {
    await repository.createSubscription(
      subscriberId: subscriberId,
      edition: 'offline',
      planType: 'multi_year',
      durationYears: 3,
      startDate: DateTime(2027, 1, 1),
    );
    await repository.createSubscription(
      subscriberId: subscriberId,
      edition: 'online',
      planType: 'lifetime',
      durationYears: 10,
      startDate: DateTime(2026, 1, 1),
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
    );

    final updated = await repository.updateSubscription(
      created.copyWith(durationYears: 3, startDate: '2026-03-15'),
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
    'rejects stale edits without losing the latest subscription data',
    () async {
      final original = await createSubscription();
      final latest = await repository.updateSubscription(
        original.copyWith(edition: 'offline'),
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
      repository.updateSubscription(original.copyWith(edition: 'offline')),
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
      original.copyWith(createdAt: 'changed'),
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
      repository.updateSubscription(original.copyWith(edition: 'offline')),
      throwsStateError,
    );
    expect(await database.select(database.subscriptions).get(), [original]);
  });

  test(
    'renewals roll back when the inserted row cannot be read back',
    () async {
      final original = await createSubscription();
      await database.customStatement('''
      CREATE TRIGGER move_renewed_subscription AFTER INSERT ON subscriptions
      BEGIN UPDATE subscriptions SET id = NEW.id + 1000 WHERE id = NEW.id; END
    ''');
      await expectLater(
        repository.renewSubscription(
          subscriberId: subscriberId,
          edition: 'offline',
          planType: 'annual',
          durationYears: 1,
          startDate: DateTime(2028, 1, 1),
        ),
        throwsStateError,
      );
      expect(await repository.getSubscriptionsForSubscriber(subscriberId), [
        original,
      ]);
    },
  );
}
