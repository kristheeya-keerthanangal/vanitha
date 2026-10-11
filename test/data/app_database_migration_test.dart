import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vanithabodhini/data/app_database.dart';

void main() {
  test(
    'preserves subscriber data when upgrading from schema version 4',
    () async {
      final executor = NativeDatabase.memory(
        setup: (db) {
          db
            ..execute('''
            CREATE TABLE subscribers (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              subscriber_type TEXT NOT NULL,
              name TEXT NOT NULL,
              contact_person_name TEXT,
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
          ''')
            ..execute('''
            CREATE TABLE audit_logs (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              subscriber_id INTEGER NOT NULL REFERENCES subscribers(id),
              previous_values TEXT,
              updated_values TEXT NOT NULL,
              modified_at TEXT NOT NULL
            );
          ''')
            ..execute('''
            CREATE TABLE subscriptions (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              subscriber_id INTEGER NOT NULL REFERENCES subscribers(id),
              edition TEXT NOT NULL,
              plan_type TEXT NOT NULL,
              duration_years INTEGER NOT NULL,
              start_date TEXT NOT NULL,
              expiry_date TEXT NOT NULL,
              payment_status TEXT NOT NULL,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            );
          ''')
            ..execute('''
            INSERT INTO subscribers (
              id, subscriber_type, name, contact_person_name, created_at,
              updated_at
            ) VALUES (7, 'individual', 'Existing Subscriber', 'Contact',
              '2026-01-01', '2026-01-01');
          ''')
            ..execute('''
            INSERT INTO audit_logs (
              subscriber_id, updated_values, modified_at
            ) VALUES (7, '{"name":"Existing Subscriber"}', '2026-01-01');
          ''')
            ..execute('''
            INSERT INTO subscriptions (
              subscriber_id, edition, plan_type, duration_years, start_date,
              expiry_date, payment_status, created_at, updated_at
            ) VALUES (7, 'online', 'annual', 1, '2026-01-01', '2027-01-01',
              'paid', '2026-01-01', '2026-01-01');
          ''');
          db.execute('PRAGMA user_version = 4');
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
      expect(subscriptions, hasLength(1));
      expect(subscriptions.single.subscriberId, 7);
      expect(auditLogs, hasLength(1));
      expect(auditLogs.single.subscriberId, 7);
    },
  );
}
