import 'package:drift/drift.dart';

@TableIndex.sql('''
  CREATE INDEX idx_subscribers_name
  ON subscribers(name COLLATE NOCASE)
''')
class Subscribers extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name =>
      text().customConstraint('NOT NULL CHECK (LENGTH(TRIM(name)) > 0)')();

  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get postalAddress => text().nullable()();
  TextColumn get postalCode => text().nullable()();

  BoolColumn get isForeign =>
      boolean().withDefault(const Constant(false))();

  TextColumn get createdAt =>
      text().customConstraint('NOT NULL DEFAULT CURRENT_TIMESTAMP')();

  TextColumn get updatedAt =>
      text().customConstraint('NOT NULL DEFAULT CURRENT_TIMESTAMP')();

  TextColumn get archivedAt => text().nullable()();
}

/// Stores before-and-after snapshots for every subscriber change.
class AuditLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get subscriberId => integer().references(Subscribers, #id)();

  TextColumn get previousValues => text().nullable()();
  TextColumn get updatedValues => text()();

  TextColumn get modifiedAt =>
      text().customConstraint('NOT NULL DEFAULT CURRENT_TIMESTAMP')();
}
