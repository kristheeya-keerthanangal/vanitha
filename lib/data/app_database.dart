import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// The application's local SQLite database.
///
/// Tables will be added here as the domain model is defined. Keeping the
/// database entry point in place now gives those tables a single migration
/// and lifecycle boundary.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'vanithabodhini'));

  @override
  int get schemaVersion => 1;
}
