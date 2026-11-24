import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vanithabodhini/data/app_database.dart';

void main() {
  for (final fromVersion in [2, 3, 4, 5, 6]) {
    test('preserves data when upgrading from schema $fromVersion to 10', () async {
      final executor = NativeDatabase.memory(
        setup: (db) {
          final hasSubscriberType = fromVersion < 5;
          final hasContactPerson = fromVersion < 6;
          final subscriberTypeColumn = hasSubscriberType
              ? 'subscriber_type TEXT NOT NULL, '
              : '';
          final contactPersonColumn = hasContactPerson
              ? 'contact_person_name TEXT, '
              : '';
          db.execute('''
            CREATE TABLE subscribers (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              $subscriberTypeColumn
              name TEXT NOT NULL,
              $contactPersonColumn
              email TEXT,
              phone TEXT,
              postal_address TEXT,
              city TEXT,
              state TEXT,
              postal_code TEXT,
              country TEXT,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              archived_at TEXT
            );
          ''');
          db.execute('''
            CREATE TABLE audit_logs (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              subscriber_id INTEGER NOT NULL REFERENCES subscribers(id),
              previous_values TEXT,
              updated_values TEXT NOT NULL,
              modified_at TEXT NOT NULL
            );
          ''');

          if (hasSubscriberType && hasContactPerson) {
            db.execute('''
              INSERT INTO subscribers (
                id, subscriber_type, name, contact_person_name, created_at,
                updated_at
              ) VALUES (7, 'individual', 'Existing Subscriber', 'Contact',
                '2026-01-01', '2026-01-01');
            ''');
          } else if (hasContactPerson) {
            db.execute('''
              INSERT INTO subscribers (
                id, name, contact_person_name, created_at, updated_at
              ) VALUES (7, 'Existing Subscriber', 'Contact', '2026-01-01',
                '2026-01-01');
            ''');
          } else {
            db.execute('''
              INSERT INTO subscribers (id, name, created_at, updated_at)
              VALUES (7, 'Existing Subscriber', '2026-01-01', '2026-01-01');
            ''');
          }
          db.execute('''
            INSERT INTO audit_logs (
              subscriber_id, updated_values, modified_at
            ) VALUES (7, '{"name":"Existing Subscriber"}', '2026-01-01');
          ''');
          db.execute(
            "UPDATE subscribers SET postal_address = '10 Main Street', city = 'Kochi', state = 'Kerala', postal_code = '0682001', country = 'India'",
          );
          // A table rebuild must retain numbers issued to deleted rows.
          db.execute(
            "UPDATE sqlite_sequence SET seq = 100 WHERE name = 'subscribers'",
          );
          db.execute('PRAGMA foreign_keys = ON');

          if (fromVersion >= 3) {
            final durationConstraint = fromVersion >= 4
                ? '''CHECK (
                    (plan_type = 'annual' AND duration_years = 1) OR
                    (plan_type = 'multi_year' AND duration_years > 1) OR
                    (plan_type = 'lifetime' AND duration_years = 10)
                  )'''
                : 'CHECK (duration_years > 0)';
            db.execute('''
              CREATE TABLE subscriptions (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                subscriber_id INTEGER NOT NULL REFERENCES subscribers(id),
                edition TEXT NOT NULL,
                plan_type TEXT NOT NULL,
                duration_years INTEGER NOT NULL $durationConstraint,
                start_date TEXT NOT NULL,
                expiry_date TEXT NOT NULL,
                payment_status TEXT NOT NULL,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
              );
            ''');
            db.execute('''
              INSERT INTO subscriptions (
                subscriber_id, edition, plan_type, duration_years, start_date,
                expiry_date, payment_status, created_at, updated_at
              ) VALUES (7, 'online', 'annual', 1, '2026-01-01', '2027-01-01',
                'paid', '2026-01-01', '2026-01-01');
            ''');
          }
          db.execute('PRAGMA user_version = $fromVersion');
        },
      );
      final database = AppDatabase(executor);
      addTearDown(database.close);

      final subscribers = await database.select(database.subscribers).get();
      final subscriptions = await database.select(database.subscriptions).get();
      final auditLogs = await database.select(database.auditLogs).get();

      expect(subscribers, hasLength(1));
      expect(subscribers.single.id, 7);
      expect(subscribers.single.name, 'Existing Subscriber');
      expect(subscribers.single.email, isNull);
      expect(
        subscribers.single.postalAddress,
        '10 Main Street, Kochi, Kerala, India',
      );
      expect(subscribers.single.postalCode, '0682001');
      expect(auditLogs, hasLength(1));
      expect(auditLogs.single.subscriberId, 7);
      final snapshots = await database
          .select(database.migrationSnapshots)
          .get();
      final subscriberSnapshots = snapshots.where(
        (row) => row.sourceTable == 'subscribers' && row.sourceVersion < 8,
      );
      if (fromVersion < 6) {
        final original =
            jsonDecode(subscriberSnapshots.single.valuesJson)
                as Map<String, dynamic>;
        expect(original['contact_person_name'], 'Contact');
        if (fromVersion < 5) {
          expect(original['subscriber_type'], 'individual');
        }
      } else {
        expect(subscriberSnapshots, isEmpty);
      }
      if (fromVersion >= 3) {
        expect(subscriptions, hasLength(1));
        expect(subscriptions.single.subscriberId, 7);
        expect(subscriptions.single.archivedAt, isNull);
      } else {
        expect(subscriptions, isEmpty);
      }
      expect(
        await database.customSelect('PRAGMA foreign_key_check').get(),
        isEmpty,
      );
      expect(
        (await database.customSelect('PRAGMA foreign_keys').getSingle())
            .read<int>('foreign_keys'),
        1,
      );
      expect(
        (await database.customSelect('PRAGMA user_version').getSingle())
            .read<int>('user_version'),
        10,
      );
      final indexes = await database
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
          .get();
      expect(
        indexes.map((row) => row.read<String>('name')),
        containsAll([
          'idx_subscribers_name',
          'idx_subscriptions_subscriber',
          'idx_subscriptions_expiry_date',
        ]),
      );
      await database.customStatement(
        "INSERT INTO subscribers (name, created_at, updated_at) VALUES ('Next Subscriber', '2026-01-01', '2026-01-01')",
      );
      final next = await (database.select(
        database.subscribers,
      )..where((row) => row.name.equals('Next Subscriber'))).getSingle();
      expect(next.id, 101);
    });
  }
}
