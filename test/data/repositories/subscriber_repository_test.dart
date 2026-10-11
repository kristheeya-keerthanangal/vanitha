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
      name: 'Anita Rao',
      email: 'anita@example.com',
    );

    expect(created.id, 1);
    expect(created.displayNumber, 'SUB-000001');
    expect(await repository.getSubscriber(created.id), created);
    expect(await database.select(database.auditLogs).get(), hasLength(1));
  });

  test('updates a subscriber and records before-and-after values', () async {
    final created = await repository.createSubscriber(name: 'Original Name');

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
        name: 'Active Subscriber',
        phone: '555-0100',
      );
      final archived = await repository.createSubscriber(
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
    final created = await repository.createSubscriber(name: 'Archive Me');

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

  test(
    'rejects stale edits without overwriting the latest data or audit',
    () async {
      final original = await repository.createSubscriber(name: 'Original');
      final latest = await repository.updateSubscriber(
        original.copyWith(name: 'Latest'),
      );
      await expectLater(
        repository.updateSubscriber(original.copyWith(name: 'Stale')),
        throwsStateError,
      );
      expect(await repository.getSubscriber(original.id), latest);
      expect(await database.select(database.auditLogs).get(), hasLength(2));
    },
  );

  test('stale edits cannot undo an archive', () async {
    final original = await repository.createSubscriber(name: 'Original');
    final archived = await repository.archiveSubscriber(original.id);
    await expectLater(
      repository.updateSubscriber(original.copyWith(name: 'Stale')),
      throwsStateError,
    );
    expect(
      await repository.getSubscriber(original.id, includeArchived: true),
      archived,
    );
  });

  test('updates preserve the original creation timestamp', () async {
    final original = await repository.createSubscriber(name: 'Original');
    final updated = await repository.updateSubscriber(
      original.copyWith(name: 'Updated', createdAt: 'changed'),
    );
    expect(updated.createdAt, original.createdAt);
  });

  test(
    'audit failure rolls back creation, updates, and archive changes',
    () async {
      final original = await repository.createSubscriber(name: 'Original');
      await database.customStatement('''
      CREATE TRIGGER reject_audit BEFORE INSERT ON audit_logs
      BEGIN SELECT RAISE(ABORT, 'audit failure'); END
    ''');
      await expectLater(
        repository.createSubscriber(name: 'Failed'),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        repository.updateSubscriber(original.copyWith(name: 'Failed')),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        repository.archiveSubscriber(original.id),
        throwsA(isA<Exception>()),
      );
      expect(await database.select(database.subscribers).get(), [original]);
      expect(await database.select(database.auditLogs).get(), hasLength(1));
    },
  );

  test('foreign keys prevent deleting a subscriber with history', () async {
    final original = await repository.createSubscriber(name: 'Keep History');
    await expectLater(
      (database.delete(
        database.subscribers,
      )..where((row) => row.id.equals(original.id))).go(),
      throwsA(isA<Exception>()),
    );
    expect(await repository.getSubscriber(original.id), original);
    expect(await database.select(database.auditLogs).get(), hasLength(1));
  });

  test(
    'updates advance the version even when the previous timestamp is in the future',
    () async {
      final original = await repository.createSubscriber(name: 'Original');
      await database.customStatement(
        'UPDATE subscribers SET updated_at = ? WHERE id = ?',
        ['2099-01-01T00:00:00.000000Z', original.id],
      );
      final current = (await repository.getSubscriber(original.id))!;
      final updated = await repository.updateSubscriber(
        current.copyWith(name: 'Updated'),
      );
      expect(
        DateTime.parse(
          updated.updatedAt,
        ).isAfter(DateTime.parse(current.updatedAt)),
        isTrue,
      );
      await expectLater(
        repository.updateSubscriber(current.copyWith(name: 'Stale')),
        throwsStateError,
      );
    },
  );
}
