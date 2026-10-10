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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createAll();
      } else if (from < 3) {
        await m.createTable(subscriptions);
      }
    },
  );
}

extension SubscriberDisplayNumber on Subscriber {
  String get displayNumber => 'SUB-${id.toString().padLeft(6, '0')}';
}
