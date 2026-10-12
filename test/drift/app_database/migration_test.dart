// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v6.dart' as v6;
import 'generated/schema_v7.dart' as v7;
import 'generated/schema_v8.dart' as v8;

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
}
