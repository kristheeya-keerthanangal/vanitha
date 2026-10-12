import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vanithabodhini/data/app_database.dart';

void main() {
  late Directory directory;
  late File file;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('database_safety_');
    file = File('${directory.path}/test.sqlite');
  });

  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test(
    'retains original subscription terms and retired subscriber fields',
    () async {
      final database = AppDatabase(_version3Database(file));
      try {
        final subscriptions = await database
            .select(database.subscriptions)
            .get();
        expect(subscriptions.single.durationYears, 10);
        expect(subscriptions.single.expiryDate, '2036-01-01');
        final existing =
            (await database.select(database.subscribers).get()).single;
        expect(existing.email, 'existing@example.com');
        expect(existing.phone, '555-0100');
        expect(existing.postalAddress, '10 Main Street');
        expect(existing.city, 'Kochi');
        expect(existing.state, 'Kerala');
        expect(existing.postalCode, '682001');
        expect(existing.country, 'India');
        expect(existing.createdAt, '2026-01-01');
        expect(existing.updatedAt, '2026-01-01');
        expect(existing.archivedAt, '2026-02-01');
        final snapshots = await database
            .select(database.migrationSnapshots)
            .get();
        final subscriber =
            jsonDecode(
                  snapshots
                      .singleWhere((row) => row.sourceTable == 'subscribers')
                      .valuesJson,
                )
                as Map<String, dynamic>;
        expect(subscriber['subscriber_type'], 'organization');
        expect(subscriber['contact_person_name'], 'Contact Person');
        expect(subscriber['archived_at'], '2026-02-01');
        final subscription =
            jsonDecode(
                  snapshots
                      .singleWhere((row) => row.sourceTable == 'subscriptions')
                      .valuesJson,
                )
                as Map<String, dynamic>;
        expect(subscription['duration_years'], 1);
        expect(subscription['expiry_date'], '2027-01-01');
        expect(subscription['payment_status'], 'paid');
        final sequence = await database
            .customSelect(
              "SELECT seq FROM sqlite_sequence WHERE name = 'subscriptions'",
            )
            .getSingle();
        expect(sequence.read<int>('seq'), 100);
      } finally {
        await database.close();
      }
      // Reopening a successfully migrated file must not repeat normalization or
      // lose recovery snapshots.
      final reopened = AppDatabase(NativeDatabase(file));
      try {
        expect(
          await reopened.select(reopened.migrationSnapshots).get(),
          hasLength(2),
        );
        expect(
          await reopened.select(reopened.subscriptions).get(),
          hasLength(1),
        );
      } finally {
        await reopened.close();
      }
    },
  );

  for (final orphan in [false, true]) {
    test(
      'failed migration rolls back schema, values, sequences and version (orphan: $orphan)',
      () async {
        final database = AppDatabase(
          _version3Database(file, blankName: !orphan, orphan: orphan),
        );
        try {
          await expectLater(
            database.customSelect('SELECT 1').get(),
            orphan ? throwsStateError : throwsA(isA<Exception>()),
          );
        } finally {
          await database.close();
        }
        final original = _OriginalDatabase(NativeDatabase(file), 3);
        try {
          final row = await original
              .customSelect('SELECT * FROM subscriptions')
              .getSingle();
          expect(row.read<int>('duration_years'), 1);
          expect(row.read<String>('expiry_date'), '2027-01-01');
          final subscriber = await original
              .customSelect('SELECT * FROM subscribers')
              .getSingle();
          expect(
            subscriber.read<String>('contact_person_name'),
            'Contact Person',
          );
          expect(subscriber.read<String>('subscriber_type'), 'organization');
          expect(
            await original
                .customSelect(
                  "SELECT name FROM sqlite_master WHERE name IN ('migration_snapshots', 'tmp_for_copy_subscribers', 'tmp_for_copy_subscriptions')",
                )
                .get(),
            isEmpty,
          );
          expect(
            (await original.customSelect('PRAGMA user_version').getSingle())
                .read<int>('user_version'),
            3,
          );
          expect(
            (await original
                    .customSelect(
                      "SELECT seq FROM sqlite_sequence WHERE name = 'subscribers'",
                    )
                    .getSingle())
                .read<int>('seq'),
            100,
          );
          expect(
            (await original
                    .customSelect(
                      "SELECT seq FROM sqlite_sequence WHERE name = 'subscriptions'",
                    )
                    .getSingle())
                .read<int>('seq'),
            100,
          );
          expect(
            await original.customSelect('SELECT * FROM audit_logs').get(),
            hasLength(1),
          );
        } finally {
          await original.close();
        }
      },
    );
  }

  test(
    'rejects newer databases without changing their version or data',
    () async {
      final database = AppDatabase(_version3Database(file, version: 9));
      try {
        await expectLater(
          database.customSelect('SELECT 1').get(),
          throwsStateError,
        );
      } finally {
        await database.close();
      }
      final original = _OriginalDatabase(NativeDatabase(file), 9);
      try {
        expect(
          (await original.customSelect('PRAGMA user_version').getSingle())
              .read<int>('user_version'),
          9,
        );
        expect(
          (await original
                  .customSelect('SELECT * FROM subscriptions')
                  .getSingle())
              .read<int>('duration_years'),
          1,
        );
        expect(
          await original
              .customSelect(
                "SELECT name FROM sqlite_master WHERE name = 'migration_snapshots'",
              )
              .get(),
          isEmpty,
        );
      } finally {
        await original.close();
      }
    },
  );

  test('upgrades the empty version 1 schema', () async {
    final database = AppDatabase(
      NativeDatabase.memory(
        setup: (db) {
          db.execute('PRAGMA user_version = 1');
        },
      ),
    );
    try {
      expect(await database.select(database.subscribers).get(), isEmpty);
      expect(await database.select(database.subscriptions).get(), isEmpty);
      expect(await database.select(database.migrationSnapshots).get(), isEmpty);
      expect(
        (await database.customSelect('PRAGMA foreign_keys').getSingle())
            .read<int>('foreign_keys'),
        1,
      );
    } finally {
      await database.close();
    }
  });

  test(
    'seed script supports the current schema and preserves existing data',
    () async {
      final database = AppDatabase(NativeDatabase(file));
      try {
        await database.customStatement(
          "INSERT INTO subscribers (name) VALUES ('Existing Subscriber')",
        );
        await database.customStatement(
          "INSERT INTO audit_logs (subscriber_id, updated_values) VALUES (1, '{}')",
        );
        await database.customStatement('''
        INSERT INTO subscriptions (subscriber_id, edition, plan_type,
          duration_years, start_date, expiry_date)
        VALUES (1, 'online', 'annual', 1, '2026-01-01', '2027-01-01')
      ''');
      } finally {
        await database.close();
      }
      // Dot commands are sqlite3 CLI settings, rather than SQL statements.
      final script = (await File(
        'tool/seed_subscribers.sql',
      ).readAsLines()).where((line) => !line.startsWith('.')).join('\n');
      final seeded = AppDatabase(
        NativeDatabase(file, setup: (db) => db.execute(script)),
      );
      try {
        expect(await seeded.select(seeded.subscribers).get(), hasLength(1001));
        expect(await seeded.select(seeded.auditLogs).get(), hasLength(1001));
        final existing = await (seeded.select(
          seeded.subscribers,
        )..where((row) => row.id.equals(1))).getSingle();
        expect(existing.name, 'Existing Subscriber');
        final subscription =
            (await seeded.select(seeded.subscriptions).get()).single;
        expect(subscription.subscriberId, 1);
        expect(subscription.planType, 'annual');
        expect(
          await seeded.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
      } finally {
        await seeded.close();
      }
    },
  );
}

NativeDatabase _version3Database(
  File file, {
  bool blankName = false,
  bool orphan = false,
  int version = 3,
}) {
  return NativeDatabase(
    file,
    setup: (db) {
      db.execute('''
      CREATE TABLE subscribers (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        subscriber_type TEXT NOT NULL,
        name TEXT NOT NULL,
        contact_person_name TEXT,
        email TEXT, phone TEXT, postal_address TEXT, city TEXT,
        state TEXT, postal_code TEXT, country TEXT,
        created_at TEXT NOT NULL, updated_at TEXT NOT NULL, archived_at TEXT
      );
      CREATE TABLE subscriptions (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        subscriber_id INTEGER NOT NULL REFERENCES subscribers(id),
        edition TEXT NOT NULL, plan_type TEXT NOT NULL,
        duration_years INTEGER NOT NULL CHECK (duration_years > 0),
        start_date TEXT NOT NULL, expiry_date TEXT NOT NULL,
        payment_status TEXT NOT NULL,
        created_at TEXT NOT NULL, updated_at TEXT NOT NULL
      );
      CREATE TABLE audit_logs (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        subscriber_id INTEGER NOT NULL REFERENCES subscribers(id),
        previous_values TEXT, updated_values TEXT NOT NULL,
        modified_at TEXT NOT NULL
      );
    ''');
      db.execute(
        '''
      INSERT INTO subscribers (id, subscriber_type, name, contact_person_name,
        created_at, updated_at, archived_at)
      VALUES (7, 'organization', ?, 'Contact Person', '2026-01-01',
        '2026-01-01', '2026-02-01');
    ''',
        [blankName ? ' ' : 'Existing Subscriber'],
      );
      db.execute('''
        UPDATE subscribers SET email = 'existing@example.com', phone = '555-0100',
          postal_address = '10 Main Street', city = 'Kochi', state = 'Kerala',
          postal_code = '682001', country = 'India' WHERE id = 7;
      ''');
      db.execute(
        '''
      INSERT INTO subscriptions (id, subscriber_id, edition, plan_type,
        duration_years, start_date, expiry_date, payment_status, created_at, updated_at)
      VALUES (9, ?, 'online', 'lifetime', 1, '2026-01-01', '2027-01-01',
        'paid', '2026-01-01', '2026-01-01');
    ''',
        [orphan ? 999 : 7],
      );
      db.execute('''
      INSERT INTO audit_logs (subscriber_id, updated_values, modified_at)
      VALUES (7, '{"name":"Existing Subscriber"}', '2026-01-01');
      UPDATE sqlite_sequence SET seq = 100 WHERE name IN ('subscribers', 'subscriptions');
      PRAGMA foreign_keys = ON;
      PRAGMA user_version = $version;
    ''');
    },
  );
}

/// Opens a failed migration's file at its original version for raw inspection.
class _OriginalDatabase extends AppDatabase {
  _OriginalDatabase(super.executor, this.originalVersion);

  final int originalVersion;

  @override
  int get schemaVersion => originalVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy();
}
