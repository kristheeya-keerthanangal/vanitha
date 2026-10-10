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
      subscriberType: 'individual',
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
      durationYears: 50,
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
      planType: 'annual',
      durationYears: 1,
      startDate: DateTime(2026, 2, 10),
      paymentStatus: 'unpaid',
    );

    final updated = await repository.updateSubscription(
      created.copyWith(
        durationYears: 2,
        startDate: '2026-03-15',
        paymentStatus: 'paid',
      ),
    );

    expect(updated.expiryDate, '2028-03-15');
    expect(updated.updatedAt, isNot(created.updatedAt));
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
}
