import 'package:drift/drift.dart';

class PostalOffices extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name =>
      text().customConstraint('NOT NULL CHECK (LENGTH(TRIM(name)) > 0)')();

  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();

  TextColumn get createdAt =>
      text().customConstraint('NOT NULL DEFAULT CURRENT_TIMESTAMP')();

  TextColumn get updatedAt =>
      text().customConstraint('NOT NULL DEFAULT CURRENT_TIMESTAMP')();
}

class PostalOfficeRules extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get postalOfficeId =>
      integer().references(PostalOffices, #id, onDelete: KeyAction.cascade)();

  TextColumn get operation => text().customConstraint(
    "NOT NULL CHECK (operation IN ('include', 'exclude'))",
  )();

  TextColumn get matchMethod => text().customConstraint(
    "NOT NULL CHECK (match_method IN ('prefix', 'range', 'exact'))",
  )();

  TextColumn get startValue => text().customConstraint(
    'NOT NULL CHECK (LENGTH(start_value) >= 1 AND LENGTH(start_value) <= 6)',
  )();

  TextColumn get endValue => text().nullable().customConstraint(
    'NULL CHECK (end_value IS NULL OR (LENGTH(end_value) = 6))',
  )();
}
