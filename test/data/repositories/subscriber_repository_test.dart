import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';

void main() {
  late AppDatabase database;
  late SubscriberRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = SubscriberRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('creates and reads a subscriber with an audit entry', () async {
    final created = await repository.createSubscriber(
      subscriberType: 'individual',
      name: 'Anita Rao',
      email: 'anita@example.com',
    );

    expect(created.id, 1);
    expect(created.displayNumber, 'SUB-000001');
    expect(await repository.getSubscriber(created.id), created);
    expect(await database.select(database.auditLogs).get(), hasLength(1));
  });

  test('updates a subscriber and records before-and-after values', () async {
    final created = await repository.createSubscriber(
      subscriberType: 'organization',
      name: 'Original Name',
    );

    final updated = await repository.updateSubscriber(
      created.copyWith(
        name: 'Updated Name',
        email: const Value('updated@example.com'),
      ),
    );

    expect(updated.name, 'Updated Name');
    expect(updated.email, 'updated@example.com');

    final logs = await database.select(database.auditLogs).get();
    expect(logs, hasLength(2));
    expect(logs.last.previousValues, contains('Original Name'));
    expect(logs.last.updatedValues, contains('Updated Name'));
  });

  test(
    'searches active subscribers and can include archived records',
    () async {
      final active = await repository.createSubscriber(
        subscriberType: 'individual',
        name: 'Active Subscriber',
        phone: '555-0100',
      );
      final archived = await repository.createSubscriber(
        subscriberType: 'individual',
        name: 'Archived Subscriber',
      );
      await repository.archiveSubscriber(archived.id);

      expect(
        (await repository.searchSubscribers('active')).map((item) => item.id),
        [active.id],
      );
      expect(await repository.searchSubscribers('archived'), isEmpty);
      expect(
        await repository.searchSubscribers('archived', includeArchived: true),
        hasLength(1),
      );
      expect(await repository.searchSubscribers('555-0100'), hasLength(1));
    },
  );

  test('archives, restores, and soft-deletes subscribers', () async {
    final created = await repository.createSubscriber(
      subscriberType: 'individual',
      name: 'Archive Me',
    );

    final archived = await repository.archiveSubscriber(created.id);
    expect(archived.archivedAt, isNotNull);
    expect(await repository.getSubscriber(created.id), isNull);

    final restored = await repository.restoreSubscriber(created.id);
    expect(restored.archivedAt, isNull);
    expect(await repository.getSubscriber(created.id), restored);

    final softDeleted = await repository.deleteSubscriber(created.id);
    expect(softDeleted.archivedAt, isNotNull);
    expect(await repository.getSubscriber(created.id), isNull);
  });

  test('does not audit archive and restore no-op mutations', () async {
    final created = await repository.createSubscriber(
      subscriberType: 'individual',
      name: 'Idempotent Subscriber',
    );

    await repository.archiveSubscriber(created.id);
    final afterArchive = await database.select(database.auditLogs).get();
    expect(afterArchive, hasLength(2));

    await repository.archiveSubscriber(created.id);
    expect(await database.select(database.auditLogs).get(), hasLength(2));

    await repository.restoreSubscriber(created.id);
    expect(await database.select(database.auditLogs).get(), hasLength(3));

    await repository.restoreSubscriber(created.id);
    expect(await database.select(database.auditLogs).get(), hasLength(3));
  });
}
