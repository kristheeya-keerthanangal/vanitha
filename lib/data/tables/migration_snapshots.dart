import 'package:drift/drift.dart';

/// Original rows retained before a migration removes or changes stored values.
/// These deliberately have no foreign key: recovery data must survive changes
/// to the live tables.
class MigrationSnapshots extends Table {
  TextColumn get sourceTable => text()();
  IntColumn get rowId => integer()();
  IntColumn get sourceVersion => integer()();
  TextColumn get valuesJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {sourceTable, rowId, sourceVersion};
}
