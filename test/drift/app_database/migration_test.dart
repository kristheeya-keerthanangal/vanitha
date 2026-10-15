// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v6.dart' as v6;
import 'generated/schema_v7.dart' as v7;
import 'generated/schema_v8.dart' as v8;
import 'generated/schema_v9.dart' as v9;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('migration from v6 to v7 does not corrupt data', () async {
    const oldSubscribersData = [
      v6.SubscribersData(
        id: 17,
        name: 'Existing Subscriber',
        email: 'reader@example.com',
        phone: '555-0100',
        postalAddress: '10 Main Street',
        city: 'Kochi',
        state: 'Kerala',
        postalCode: '682001',
        country: 'India',
        createdAt: '2026-01-01',
        updatedAt: '2026-01-02',
        archivedAt: null,
      ),
    ];
    const expectedNewSubscribersData = [
      v7.SubscribersData(
        id: 17,
        name: 'Existing Subscriber',
        email: 'reader@example.com',
        phone: '555-0100',
        postalAddress: '10 Main Street',
        city: 'Kochi',
        state: 'Kerala',
        postalCode: '682001',
        country: 'India',
        createdAt: '2026-01-01',
        updatedAt: '2026-01-02',
        archivedAt: null,
      ),
    ];

    const oldAuditLogsData = [
      v6.AuditLogsData(
        id: 23,
        subscriberId: 17,
        previousValues: '{"name":"Old Name"}',
        updatedValues: '{"name":"Existing Subscriber"}',
        modifiedAt: '2026-01-02',
      ),
    ];
    const expectedNewAuditLogsData = [
      v7.AuditLogsData(
        id: 23,
        subscriberId: 17,
        previousValues: '{"name":"Old Name"}',
        updatedValues: '{"name":"Existing Subscriber"}',
        modifiedAt: '2026-01-02',
      ),
    ];

    const oldSubscriptionsData = [
      v6.SubscriptionsData(
        id: 31,
        subscriberId: 17,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startDate: '2026-01-01',
        expiryDate: '2027-01-01',
        paymentStatus: 'paid',
        createdAt: '2026-01-01',
        updatedAt: '2026-01-01',
      ),
    ];
    const expectedNewSubscriptionsData = [
      v7.SubscriptionsData(
        id: 31,
        subscriberId: 17,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startDate: '2026-01-01',
        expiryDate: '2027-01-01',
        paymentStatus: 'paid',
        createdAt: '2026-01-01',
        updatedAt: '2026-01-01',
        archivedAt: null,
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 6,
      newVersion: 7,
      createOld: v6.DatabaseAtV6.new,
      createNew: v7.DatabaseAtV7.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.subscribers, oldSubscribersData);
        batch.insertAll(oldDb.auditLogs, oldAuditLogsData);
        batch.insertAll(oldDb.subscriptions, oldSubscriptionsData);
      },
      validateItems: (newDb) async {
        expect(
          expectedNewSubscribersData,
          await newDb.select(newDb.subscribers).get(),
        );
        expect(
          expectedNewAuditLogsData,
          await newDb.select(newDb.auditLogs).get(),
        );
        expect(
          expectedNewSubscriptionsData,
          await newDb.select(newDb.subscriptions).get(),
        );
        expect(
          await newDb.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
        expect(
          (await newDb.customSelect('PRAGMA foreign_keys').getSingle())
              .read<int>('foreign_keys'),
          1,
        );
        expect(await newDb.select(newDb.migrationSnapshots).get(), isEmpty);
        final indexes = await newDb
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
      },
    );
  });

  test(
    'migration from v7 to v8 removes payment status without data loss',
    () async {
      const oldSubscriptionsData = [
        v7.SubscriptionsData(
          id: 31,
          subscriberId: 17,
          edition: 'online',
          planType: 'annual',
          durationYears: 1,
          startDate: '2026-01-01',
          expiryDate: '2027-01-01',
          paymentStatus: 'paid',
          createdAt: '2026-01-01',
          updatedAt: '2026-01-01',
          archivedAt: null,
        ),
      ];
      const expectedSubscriptionsData = [
        v8.SubscriptionsData(
          id: 31,
          subscriberId: 17,
          edition: 'online',
          planType: 'annual',
          durationYears: 1,
          startDate: '2026-01-01',
          expiryDate: '2027-01-01',
          createdAt: '2026-01-01',
          updatedAt: '2026-01-01',
          archivedAt: null,
        ),
      ];
      const oldSubscribersData = [
        v7.SubscribersData(
          id: 17,
          name: 'Existing Subscriber',
          email: null,
          phone: null,
          postalAddress: null,
          city: null,
          state: null,
          postalCode: null,
          country: null,
          createdAt: '2026-01-01',
          updatedAt: '2026-01-01',
          archivedAt: null,
        ),
      ];

      await verifier.testWithDataIntegrity(
        oldVersion: 7,
        newVersion: 8,
        createOld: v7.DatabaseAtV7.new,
        createNew: v8.DatabaseAtV8.new,
        openTestedDatabase: AppDatabase.new,
        createItems: (batch, oldDb) {
          batch.insertAll(oldDb.subscribers, oldSubscribersData);
          batch.insertAll(oldDb.subscriptions, oldSubscriptionsData);
        },
        validateItems: (newDb) async {
          expect(
            expectedSubscriptionsData,
            await newDb.select(newDb.subscriptions).get(),
          );
          expect(
            await newDb.customSelect('PRAGMA foreign_key_check').get(),
            isEmpty,
          );
        },
      );
    },
  );
  test(
    'v8 to v9 preserves address data, history and subscriber numbers',
    () async {
      await verifier.testWithDataIntegrity(
        oldVersion: 8,
        newVersion: 9,
        createOld: v8.DatabaseAtV8.new,
        createNew: v9.DatabaseAtV9.new,
        openTestedDatabase: AppDatabase.new,
        createItems: (batch, oldDb) {
          batch.insertAll(oldDb.subscribers, [
            v8.SubscribersData(
              id: 17,
              name: 'Archived Reader',
              email: 'reader@example.com',
              phone: '555-0100',
              postalAddress: ' 10 Main Street ',
              city: 'Kochi',
              state: 'Kerala',
              country: 'India',
              postalCode: '0682001',
              createdAt: '2026-01-01',
              updatedAt: '2026-01-02',
              archivedAt: '2026-02-01',
            ),
            v8.SubscribersData(
              id: 18,
              name: 'Empty Address',
              postalAddress: '  ',
              city: '',
              state: ' ',
              createdAt: '2026-01-01',
              updatedAt: '2026-01-01',
            ),
            v8.SubscribersData(
              id: 19,
              name: 'Locality Only',
              city: 'കൊച്ചി',
              country: 'India',
              createdAt: '2026-01-01',
              updatedAt: '2026-01-01',
            ),
            v8.SubscribersData(
              id: 20,
              name: 'Address Only',
              postalAddress: 'Line 1\nLine 2',
              createdAt: '2026-01-01',
              updatedAt: '2026-01-01',
            ),
          ]);
          batch.insert(
            oldDb.auditLogs,
            v8.AuditLogsData(
              id: 23,
              subscriberId: 17,
              previousValues: '{"city":"Old City"}',
              updatedValues: '{"city":"Kochi"}',
              modifiedAt: '2026-01-02',
            ),
          );
          batch.insert(
            oldDb.subscriptions,
            v8.SubscriptionsData(
              id: 31,
              subscriberId: 17,
              edition: 'online',
              planType: 'annual',
              durationYears: 1,
              startDate: '2026-01-01',
              expiryDate: '2027-01-01',
              createdAt: '2026-01-01',
              updatedAt: '2026-01-01',
            ),
          );
          batch.customStatement(
            "UPDATE sqlite_sequence SET seq = 100 WHERE name = 'subscribers'",
          );
        },
        validateItems: (db) async {
          final rows = await (db.select(
            db.subscribers,
          )..orderBy([(row) => OrderingTerm.asc(row.id)])).get();
          expect(rows.map((row) => row.postalAddress), [
            '10 Main Street, Kochi, Kerala, India',
            null,
            'കൊച്ചി, India',
            'Line 1\nLine 2',
          ]);
          final reader = rows.first;
          expect(reader.id, 17);
          expect(reader.email, 'reader@example.com');
          expect(reader.phone, '555-0100');
          expect(reader.postalCode, '0682001');
          expect(reader.createdAt, '2026-01-01');
          expect(reader.updatedAt, '2026-01-02');
          expect(reader.archivedAt, '2026-02-01');
          final log = await db.select(db.auditLogs).getSingle();
          expect(log.id, 23);
          expect(log.subscriberId, 17);
          expect(log.previousValues, '{"city":"Old City"}');
          expect(log.updatedValues, '{"city":"Kochi"}');
          expect(log.modifiedAt, '2026-01-02');
          final subscription = await db.select(db.subscriptions).getSingle();
          expect(subscription.id, 31);
          expect(subscription.subscriberId, 17);
          expect(subscription.expiryDate, '2027-01-01');
          final snapshots = await db.select(db.migrationSnapshots).get();
          expect(snapshots, hasLength(4));
          final snapshot = snapshots.singleWhere((row) => row.rowId == 17);
          expect(snapshot.sourceVersion, 8);
          final original =
              jsonDecode(snapshot.valuesJson) as Map<String, dynamic>;
          expect(original['postal_address'], ' 10 Main Street ');
          expect(original['city'], 'Kochi');
          expect(original['state'], 'Kerala');
          expect(original['country'], 'India');
          final columns = await db
              .customSelect('PRAGMA table_info(subscribers)')
              .get();
          expect(
            columns.map((row) => row.read<String>('name')),
            isNot(
              anyOf(contains('city'), contains('state'), contains('country')),
            ),
          );
          expect(
            await db.customSelect('PRAGMA foreign_key_check').get(),
            isEmpty,
          );
          final indexes = await db
              .customSelect(
                "SELECT name FROM sqlite_master WHERE type = 'index'",
              )
              .get();
          expect(
            indexes.map((row) => row.read<String>('name')),
            contains('idx_subscribers_name'),
          );
          await db.customStatement(
            "INSERT INTO subscribers (name) VALUES ('Next Reader')",
          );
          final next = await (db.select(
            db.subscribers,
          )..where((row) => row.name.equals('Next Reader'))).getSingle();
          expect(next.id, 101);
        },
      );
    },
  );
}
