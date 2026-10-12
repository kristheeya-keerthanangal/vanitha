# Database migrations

The database uses Drift guided migrations from schema version 6 onward. The
version 6 and 7 schema exports are in `drift_schemas/app_database/`, and Drift
generates the versioned schema helpers and migration verification database in
`lib/data/app_database.steps.dart` and `test/drift/app_database/generated/`.

Databases at versions 1 through 5 use the compatibility migration retained in
`AppDatabase`. It preserves the upgrade behavior those installations already
depend on, including recovery snapshots for retired values. Version 5 has no
committed historical schema export, so its compatibility path remains covered
by the populated upgrade tests. The `migration_snapshots` table stores original
row values from legacy migrations; it is application recovery data and is
separate from Drift's schema exports.

## Adding a schema migration

1. Update the Drift table definitions and increment `AppDatabase.schemaVersion`.
2. Run `dart run drift_dev make-migrations` to export the new schema and refresh
   the generated step and test helpers.
3. Complete the new version-specific migration callback in
   `lib/data/app_database.dart`. Use the generated `schema` argument for the
   destination version, and preserve existing values, relationships, indexes,
   constraints, and defaults.
4. Review the new schema export and generated files. Add populated data-integrity
   coverage for any transformation or relationship affected by the change.
5. Run the generated migration test, then `flutter analyze` and `flutter test`.
6. Commit the schema export, migration callback, generated helpers, and tests
   together.

Keep the legacy compatibility path for versions 1 through 5 unless support for
those installations is deliberately ended in a separately reviewed change.
