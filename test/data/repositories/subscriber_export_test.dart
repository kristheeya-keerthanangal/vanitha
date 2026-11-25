import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/postal_office_repository.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';
import 'package:vanithabodhini/data/repositories/subscription_repository.dart';

void main() {
  late AppDatabase database;
  late SubscriberRepository repository;
  late SubscriptionRepository subscriptionRepository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = SubscriberRepository(database);
    subscriptionRepository = SubscriptionRepository(database);
  });
  tearDown(() => database.close());

  test('empty database exports a JSON array', () async {
    expect(jsonDecode(await repository.exportSubscribers()), isEmpty);
  });

  test(
    'exports all fields and archived records without pagination or writes',
    () async {
      final first = await repository.createSubscriber(
        name: 'മലയാളം "Reader"',
        email: 'reader@example.com',
        phone: '+91 1234567890',
        postalAddress: 'First line\nSecond line',
        postalCode: '0682001',
      );
      await repository.archiveSubscriber(first.id);
      for (var i = 0; i < 55; i++) {
        await repository.createSubscriber(name: 'Reader $i');
      }
      final before = await database.select(database.subscribers).get();
      final audits = await database.select(database.auditLogs).get();

      final decoded = jsonDecode(await repository.exportSubscribers()) as List;

      expect(decoded, hasLength(56));
      expect(decoded, before.map((row) => row.toJson()).toList());
      expect(decoded.first['archivedAt'], isNotNull);
      expect(decoded.first['postalCode'], '0682001');
      expect(decoded.first['name'], 'മലയാളം "Reader"');
      expect(decoded.last['postalAddress'], isNull);
      expect(await database.select(database.subscribers).get(), before);
      expect(await database.select(database.auditLogs).get(), audits);
    },
  );

  test(
    'complete export includes every subscriber and subscription record',
    () async {
      final first = await repository.createSubscriber(name: 'First reader');
      final second = await repository.createSubscriber(name: 'Second reader');
      final firstSubscription = await subscriptionRepository.createSubscription(
        subscriberId: first.id,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startYear: 2025,
        startMonth: 1,
      );
      final secondSubscription = await subscriptionRepository
          .createSubscription(
            subscriberId: second.id,
            edition: 'offline',
            planType: 'multi_year',
            durationYears: 2,
            startYear: 2026,
            startMonth: 1,
          );
      final archivedSubscription = await subscriptionRepository
          .archiveSubscription(firstSubscription.id);
      final archivedSubscriber = await repository.archiveSubscriber(second.id);

      final json = jsonDecode(await repository.exportCompleteSubscribers())
          as Map<String, dynamic>;
      final decoded = json['subscribers'] as List;

      expect(decoded, [
        {
          ...first.toJson(),
          'subscriptions': [archivedSubscription.toJson()],
        },
        {
          ...archivedSubscriber.toJson(),
          'subscriptions': [secondSubscription.toJson()],
        },
      ]);
    },
  );

  test(
    'complete export includes foreign status, contacts, and lifetime subscription',
    () async {
      final foreignSubscriber = await repository.createSubscriber(
        name: 'Foreign Reader',
        isForeign: true,
        email: 'foreign@example.com',
        phone: '+44 7911 123456',
        postalAddress: 'London',
      );
      final lifetimeSub = await subscriptionRepository.createSubscription(
        subscriberId: foreignSubscriber.id,
        edition: 'online',
        planType: 'lifetime',
        durationYears: 15,
        startYear: 2026,
        startMonth: 1,
      );

      final json = jsonDecode(await repository.exportCompleteSubscribers())
          as Map<String, dynamic>;
      final decoded = json['subscribers'] as List;

      expect(decoded.single['isForeign'], isTrue);
      expect(decoded.single['email'], 'foreign@example.com');
      expect(decoded.single['phone'], '+44 7911 123456');
      expect(decoded.single['subscriptions'], [lifetimeSub.toJson()]);
      expect(decoded.single['subscriptions'].first['planType'], 'lifetime');
      expect(decoded.single['subscriptions'].first['durationYears'], 15);
    },
  );

  test(
    'complete export includes postal offices and their rules',
    () async {
      final officeRepo = PostalOfficeRepository(database);
      final office = await officeRepo.createOffice(name: 'Kannur RMS');
      await officeRepo.addRule(
        postalOfficeId: office.id,
        operation: 'include',
        matchMethod: 'prefix',
        startValue: '670',
      );
      await officeRepo.addRule(
        postalOfficeId: office.id,
        operation: 'exclude',
        matchMethod: 'exact',
        startValue: '670002',
      );

      final json = jsonDecode(await repository.exportCompleteSubscribers())
          as Map<String, dynamic>;
      final offices = json['postalOffices'] as List;
      expect(offices, hasLength(1));
      expect(offices.first['name'], 'Kannur RMS');
      expect(offices.first['isActive'], isTrue);
      final rules = offices.first['rules'] as List;
      expect(rules, hasLength(2));
      expect(rules[0]['operation'], 'include');
      expect(rules[0]['matchMethod'], 'prefix');
      expect(rules[0]['startValue'], '670');
      expect(rules[1]['operation'], 'exclude');
      expect(rules[1]['matchMethod'], 'exact');
      expect(rules[1]['startValue'], '670002');
    },
  );
}
