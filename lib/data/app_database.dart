import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/subscribers.dart';
import 'tables/subscriptions.dart';

part 'app_database.g.dart';

/// The application's local SQLite database.
///
/// Tables will be added here as the domain model is defined. Keeping the
/// database entry point in place now gives those tables a single migration
/// and lifecycle boundary.
@DriftDatabase(tables: [Subscribers, AuditLogs, Subscriptions])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'vanithabodhini'));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createAll();
      } else if (from < 3) {
        await m.createTable(subscriptions);
      }
      if (from < 4) {
        final existingSubscriptions = await select(subscriptions).get();
        for (final subscription in existingSubscriptions) {
          final durationYears = switch (subscription.planType) {
            'annual' => 1,
            'lifetime' => 10,
            'multi_year' =>
              subscription.durationYears < 2 ? 2 : subscription.durationYears,
            _ => subscription.durationYears,
          };
          final startDate = DateTime.tryParse(subscription.startDate);
          final expiryDate = startDate == null
              ? subscription.expiryDate
              : _formatDate(_addYears(startDate, durationYears));
          await (update(
            subscriptions,
          )..where((row) => row.id.equals(subscription.id))).write(
            SubscriptionsCompanion(
              durationYears: Value(durationYears),
              expiryDate: Value(expiryDate),
            ),
          );
        }
        await m.alterTable(TableMigration(subscriptions));
      }
    },
  );
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
