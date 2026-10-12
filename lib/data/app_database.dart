import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'app_database.steps.dart';
import 'tables/migration_snapshots.dart';
import 'tables/subscribers.dart';
import 'tables/subscriptions.dart';

part 'app_database.g.dart';

/// The application's local SQLite database.
@DriftDatabase(
  tables: [Subscribers, AuditLogs, Subscriptions, MigrationSnapshots],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'vanithabodhini'));

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => transaction(m.createAll),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: (m, from, to) async {
      if (from > to) {
        throw StateError('This database requires a newer version of the app');
      }
      // SQLite cannot change foreign_keys inside a transaction. Disable it
      // before rebuilding referenced tables, and validate before committing.
      await customStatement('PRAGMA foreign_keys = OFF');
      try {
        await transaction(() async {
          if (from < 6) {
            // The exported history begins at version 6. Keep the established
            // upgrade path for older databases, then continue with guided
            // migrations from version 7 onward.
            await _upgradeLegacyToVersion7(m, from);
            await customStatement('PRAGMA user_version = 7');
            if (to > 7) {
              await _schemaUpgrade(m, 7, to);
            }
          } else {
            await _schemaUpgrade(m, from, to);
          }

          // Older table rebuilds may have dropped indexes that were absent
          // from their source schema. Restore every currently declared index.
          for (final index in allSchemaEntities.whereType<Index>()) {
            await customStatement(
              index.createStatementsByDialect[SqlDialect.sqlite]!.replaceFirst(
                'CREATE INDEX ',
                'CREATE INDEX IF NOT EXISTS ',
              ),
            );
          }
          final violations = await customSelect(
            'PRAGMA foreign_key_check',
          ).get();
          if (violations.isNotEmpty) {
            throw StateError(
              'Migration contains invalid foreign key references',
            );
          }
        });
      } finally {
        await customStatement('PRAGMA foreign_keys = ON');
      }
    },
  );

  Future<void> _upgradeLegacyToVersion7(Migrator m, int from) async {
    if (from < 2) {
      // Version 1 had no application tables.
      await m.createAll();
      return;
    }

    await m.createTable(migrationSnapshots);
    if (from < 6) {
      await _snapshotTable('subscribers', from);
    }
    if (from < 3) {
      await m.createTable(subscriptions);
    } else if (from < 4) {
      await _snapshotTable('subscriptions', from);
    }

    if (from == 3) {
      // Read only columns present in version 3 before rebuilding the table.
      final existingSubscriptions = await customSelect(
        'SELECT id, plan_type, duration_years, start_date, expiry_date '
        'FROM subscriptions',
      ).get();
      for (final subscription in existingSubscriptions) {
        final oldDuration = subscription.read<int>('duration_years');
        final durationYears = switch (subscription.read<String>('plan_type')) {
          'annual' => 1,
          'lifetime' => 10,
          'multi_year' => oldDuration < 2 ? 2 : oldDuration,
          _ => oldDuration,
        };
        final startDate = DateTime.tryParse(
          subscription.read<String>('start_date'),
        );
        final expiryDate = startDate == null
            ? subscription.read<String>('expiry_date')
            : _formatDate(_addYears(startDate, durationYears));
        await (update(
          subscriptions,
        )..where((row) => row.id.equals(subscription.read<int>('id')))).write(
          SubscriptionsCompanion(
            durationYears: Value(durationYears),
            expiryDate: Value(expiryDate),
          ),
        );
      }
      await _rebuildTable(
        m,
        subscriptions,
        newColumns: [subscriptions.archivedAt],
      );
    } else if (from >= 4) {
      await m.addColumn(subscriptions, subscriptions.archivedAt);
    }

    // Retired subscriber columns are snapshotted above. Rebuild while keeping
    // all shared values and the IDs referenced by subscriptions and audit logs.
    await _rebuildTable(m, subscribers);
  }

  OnUpgrade get _schemaUpgrade => stepByStep(
    from6To7: (m, schema) async {
      await m.createTable(schema.migrationSnapshots);
      await m.addColumn(schema.subscriptions, schema.subscriptions.archivedAt);
    },
  );

  Future<void> _snapshotTable(String tableName, int from) async {
    final rows = await customSelect('SELECT * FROM "$tableName"').get();
    for (final row in rows) {
      await into(migrationSnapshots).insert(
        MigrationSnapshotsCompanion.insert(
          sourceTable: tableName,
          rowId: row.read<int>('id'),
          sourceVersion: from,
          valuesJson: jsonEncode(row.data),
        ),
      );
    }
  }

  Future<void> _rebuildTable(
    Migrator m,
    TableInfo table, {
    List<GeneratedColumn> newColumns = const [],
  }) async {
    // Drift copies rows, but rebuilding AUTOINCREMENT tables otherwise loses
    // the highest number previously issued if that row has since been deleted.
    final sequence = await customSelect(
      'SELECT seq FROM sqlite_sequence WHERE name = ?',
      variables: [Variable<String>(table.actualTableName)],
    ).getSingleOrNull();
    await m.alterTable(TableMigration(table, newColumns: newColumns));
    if (sequence != null) {
      final value = sequence.read<int>('seq');
      await customStatement(
        'UPDATE sqlite_sequence SET seq = MAX(seq, ?) WHERE name = ?',
        [value, table.actualTableName],
      );
    }
  }
}

DateTime _addYears(DateTime date, int years) =>
    DateTime.utc(date.year + years, date.month, date.day);

String _formatDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

extension SubscriberDisplayNumber on Subscriber {
  String get displayNumber => 'SUB-${id.toString().padLeft(6, '0')}';
}
