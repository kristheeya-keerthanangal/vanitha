import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';
import 'package:vanithabodhini/data/repositories/subscription_repository.dart';
import 'package:vanithabodhini/data/subscriber_import.dart';

void main() {
  late AppDatabase database;
  late SubscriberRepository repository;

  SubscriberImportEntry entry(String name) => SubscriberImportEntry(
    name: name,
    address: 'Main Street',
    pincode: '0682001',
  );

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = SubscriberRepository(database);
  });
  tearDown(() => database.close());

  test(
    'preview makes no writes; import appends with audit and no subscription',
    () async {
      final existing = await repository.createSubscriber(
        name: 'Existing',
        email: 'test@example.com',
      );
      final subscription = await SubscriptionRepository(database)
          .createSubscription(
            subscriberId: existing.id,
            edition: 'offline',
            planType: 'annual',
            durationYears: 1,
            startYear: 2026,
            startMonth: 1,
          );
      final beforeLogs = await database.select(database.auditLogs).get();
      final preview = await repository.previewImport([
        entry('SALLY BABU'),
        entry('New'),
      ]);
      expect(preview.toInsert, 2);
      expect(await database.select(database.subscribers).get(), [existing]);
      expect(await database.select(database.auditLogs).get(), beforeLogs);

      final result = await repository.importSubscribers(preview);
      expect(result.inserted, 2);
      expect(result.skipped, 0);
      expect(await repository.getSubscriber(existing.id), existing);
      expect(await database.select(database.subscriptions).get(), [
        subscription,
      ]);
      final rows = await database.select(database.subscribers).get();
      expect(rows, hasLength(3));
      final imported = rows[1];
      expect(imported.name, 'SALLY BABU');
      expect(imported.postalAddress, 'Main Street');
      expect(imported.postalCode, '0682001');
      expect(imported.email, isNull);
      expect(imported.phone, isNull);
      expect(imported.archivedAt, isNull);
      expect(imported.createdAt, isNotEmpty);
      final logs = await database.select(database.auditLogs).get();
      expect(logs, hasLength(3));
      expect(logs[1].previousValues, isNull);
      expect(jsonDecode(logs[1].updatedValues)['id'], imported.id);
    },
  );

  test(
    'skips trimmed exact matches within file and database; preserves case',
    () async {
      await repository.createSubscriber(
        name: ' Sally ',
        postalAddress: ' Main Street ',
        postalCode: ' 0682001 ',
      );
      final preview = await repository.previewImport([
        entry('Sally'),
        entry('New'),
        entry(' New '),
        entry('sally'),
        SubscriberImportEntry(
          name: 'Sally',
          address: 'Other Street',
          pincode: '0682001',
        ),
        SubscriberImportEntry(
          name: 'Sally',
          address: 'Main Street',
          pincode: '682001',
        ),
      ]);
      expect(preview.total, 6);
      expect(preview.toInsert, 4);
      expect(preview.skipped, 2);
      await repository.importSubscribers(preview);
      final repeated = await repository.previewImport([
        entry('Sally'),
        entry('New'),
        entry('sally'),
      ]);
      expect(repeated.toInsert, 0);
      expect(repeated.skipped, 3);
    },
  );

  test(
    'creates new subscriber when only a soft-deleted match exists',
    () async {
      final old = await repository.createSubscriber(
        name: 'Sally',
        postalAddress: 'Main Street',
        postalCode: '0682001',
      );
      final archived = await repository.archiveSubscriber(old.id);
      final preview = await repository.previewImport([entry('Sally')]);
      expect(preview.toInsert, 1);
      await repository.importSubscribers(preview);
      expect(
        await repository.getSubscriber(old.id, includeArchived: true),
        archived,
      );
      expect(await database.select(database.subscribers).get(), hasLength(2));
    },
  );

  test('rechecks duplicates added after confirmation preview', () async {
    final preview = await repository.previewImport([
      entry('Sally'),
      entry('New'),
    ]);
    await repository.createSubscriber(
      name: 'Sally',
      postalAddress: 'Main Street',
      postalCode: '0682001',
    );
    final result = await repository.importSubscribers(preview);
    expect(result.inserted, 1);
    expect(result.skipped, 1);
    expect(await database.select(database.subscribers).get(), hasLength(2));
  });

  test(
    'audit failure rolls back the entire import and preserves existing data',
    () async {
      final existing = await repository.createSubscriber(name: 'Existing');
      final logs = await database.select(database.auditLogs).get();
      final preview = await repository.previewImport([
        entry('First'),
        entry('Second'),
      ]);
      await database.customStatement('''
      CREATE TRIGGER fail_second_audit BEFORE INSERT ON audit_logs
      WHEN (SELECT name FROM subscribers WHERE id = NEW.subscriber_id) = 'Second'
      BEGIN SELECT RAISE(ABORT, 'test audit failure'); END
    ''');
      await expectLater(
        repository.importSubscribers(preview),
        throwsA(anything),
      );
      expect(await database.select(database.subscribers).get(), [existing]);
      expect(await database.select(database.auditLogs).get(), logs);
    },
  );

  group('complete import', () {
    test(
      'imports subscribers with foreign status, contact info, and linked subscriptions',
      () async {
        await repository.createSubscriber(
          name: 'Existing Domestic',
          postalAddress: 'Town Center',
          postalCode: '682001',
          email: 'existing@example.com',
          phone: '+91 9999999999',
        );

        final entries = [
          CompleteSubscriberImportEntry(
            name: 'Existing Domestic',
            postalAddress: 'Town Center',
            postalCode: '682001',
            email: 'existing@example.com',
            phone: '+91 9999999999',
            isForeign: false,
            subscriptions: [
              const CompleteSubscriptionImportEntry(
                edition: 'online',
                planType: 'annual',
                durationYears: 1,
                startDate: '2026-01',
                expiryDate: '2026-12',
              ),
            ],
          ),
          CompleteSubscriberImportEntry(
            name: 'Foreign Reader',
            postalAddress: '123 Baker St, London',
            postalCode: null,
            email: 'london@example.com',
            phone: '+44 7911 123456',
            isForeign: true,
            subscriptions: [
              const CompleteSubscriptionImportEntry(
                edition: 'online',
                planType: 'lifetime',
                durationYears: 15,
                startDate: '2026-01',
                expiryDate: '2040-12',
              ),
              const CompleteSubscriptionImportEntry(
                edition: 'offline',
                planType: 'multi_year',
                durationYears: 2,
                startDate: '2026-01',
                expiryDate: '2027-12',
                archivedAt: '2026-06-01T12:00:00Z',
              ),
            ],
          ),
        ];

        final preview = await repository.previewCompleteImport(entries);
        expect(preview.totalSubscribers, 2);
        expect(preview.subscribersToInsert, 1);
        expect(preview.subscribersSkipped, 1);
        expect(preview.totalSubscriptionsToInsert, 2);

        final result = await repository.importCompleteSubscribers(preview);
        expect(result.subscribersInserted, 1);
        expect(result.subscribersSkipped, 1);
        expect(result.subscriptionsInserted, 2);

        final subscribers = await database.select(database.subscribers).get();
        expect(subscribers, hasLength(2));
        final imported = subscribers.firstWhere(
          (s) => s.name == 'Foreign Reader',
        );
        expect(imported.isForeign, isTrue);
        expect(imported.postalCode, isNull);
        expect(imported.email, 'london@example.com');
        expect(imported.phone, '+44 7911 123456');

        final subscriptions =
            await database.select(database.subscriptions).get();
        expect(subscriptions, hasLength(2));
        expect(
          subscriptions.every((s) => s.subscriberId == imported.id),
          isTrue,
        );
        final lifetimeSub = subscriptions.firstWhere(
          (s) => s.planType == 'lifetime',
        );
        expect(lifetimeSub.durationYears, 15);
        expect(lifetimeSub.edition, 'online');
        final multiSub = subscriptions.firstWhere(
          (s) => s.planType == 'multi_year',
        );
        expect(multiSub.archivedAt, '2026-06-01T12:00:00Z');

        final audits = await database.select(database.auditLogs).get();
        expect(audits, hasLength(2));
      },
    );
  });
}
