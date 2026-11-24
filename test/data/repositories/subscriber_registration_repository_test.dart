import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_registration_repository.dart';

void main() {
  late AppDatabase database;
  late SubscriberRegistrationRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = SubscriberRegistrationRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('creates a subscriber and subscription atomically', () async {
    final result = await repository.registerSubscriber(
      name: 'Anita Rao',
      email: 'anita@example.com',
      edition: 'online',
      planType: 'annual',
      durationYears: 1,
      startYear: 2026,
      startMonth: 3,
    );

    expect(result.subscriber.name, 'Anita Rao');
    expect(result.subscription.subscriberId, result.subscriber.id);
    expect(result.subscription.expiryDate, '2027-02');
    expect(await database.select(database.auditLogs).get(), hasLength(1));
  });

  test('rolls back the subscriber when subscription creation fails', () async {
    expect(
      repository.registerSubscriber(
        name: 'Invalid Subscription',
        edition: 'invalid',
        planType: 'annual',
        durationYears: 1,
        startYear: 2026,
        startMonth: 3,
      ),
      throwsA(isA<Exception>()),
    );

    expect(await database.select(database.subscribers).get(), isEmpty);
    expect(await database.select(database.subscriptions).get(), isEmpty);
    expect(await database.select(database.auditLogs).get(), isEmpty);
  });
}
