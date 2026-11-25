import 'package:drift/drift.dart';

import '../app_database.dart';
import 'update_timestamp.dart';

class PostalOfficeRepository {
  PostalOfficeRepository(this._database);

  final AppDatabase _database;

  String _now() => DateTime.now().toUtc().toIso8601String();

  Future<PostalOffice> createOffice({
    required String name,
    bool isActive = true,
  }) async {
    final now = _now();
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Postal office name cannot be empty');
    }

    final id = await _database.into(_database.postalOffices).insert(
      PostalOfficesCompanion.insert(
        name: trimmedName,
        isActive: Value(isActive),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    final office = await getOffice(id);
    if (office == null) {
      throw StateError('Postal office $id was not created');
    }
    return office;
  }

  Future<PostalOffice> updateOffice(PostalOffice office) async {
    return _database.transaction(() async {
      final previous = await getOffice(office.id);
      if (previous == null) {
        throw StateError('Postal office ${office.id} was not found');
      }

      final now = nextUpdateTimestamp(previous.updatedAt);
      final updated = office.copyWith(
        name: office.name.trim(),
        updatedAt: now,
      );

      final changed = await (_database.update(_database.postalOffices)
            ..where((row) => row.id.equals(office.id)))
          .write(updated.toCompanion(false));

      if (changed == 0) {
        throw StateError('Postal office ${office.id} could not be updated');
      }

      return (await getOffice(office.id))!;
    });
  }

  Future<void> deleteOffice(int id) async {
    await _database.transaction(() async {
      // Explicitly delete associated rules first to guarantee clean deletion
      // even if foreign keys are toggled.
      await (_database.delete(_database.postalOfficeRules)
            ..where((row) => row.postalOfficeId.equals(id)))
          .go();
      await (_database.delete(_database.postalOffices)
            ..where((row) => row.id.equals(id)))
          .go();
    });
  }

  Future<PostalOffice?> getOffice(int id) {
    return (_database.select(_database.postalOffices)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<PostalOffice>> getAllOffices() {
    return (_database.select(_database.postalOffices)
          ..orderBy([
            (row) => OrderingTerm.asc(row.name.collate(Collate.noCase)),
            (row) => OrderingTerm.asc(row.id),
          ]))
        .get();
  }

  Future<List<PostalOffice>> getActiveOffices() {
    return (_database.select(_database.postalOffices)
          ..where((row) => row.isActive.equals(true))
          ..orderBy([
            (row) => OrderingTerm.asc(row.name.collate(Collate.noCase)),
            (row) => OrderingTerm.asc(row.id),
          ]))
        .get();
  }

  Future<Map<int, int>> getRuleCountsByOffice() async {
    final count = _database.postalOfficeRules.id.count();
    final query = _database.selectOnly(_database.postalOfficeRules)
      ..addColumns([_database.postalOfficeRules.postalOfficeId, count])
      ..groupBy([_database.postalOfficeRules.postalOfficeId]);

    final rows = await query.get();
    return {
      for (final row in rows)
        row.read(_database.postalOfficeRules.postalOfficeId)!: row.read(count)!,
    };
  }

  Future<PostalOfficeRule> addRule({
    required int postalOfficeId,
    required String operation,
    required String matchMethod,
    required String startValue,
    String? endValue,
  }) async {
    final id = await _database.into(_database.postalOfficeRules).insert(
      PostalOfficeRulesCompanion.insert(
        postalOfficeId: postalOfficeId,
        operation: operation,
        matchMethod: matchMethod,
        startValue: startValue.trim(),
        endValue: Value(endValue?.trim()),
      ),
    );

    final rule = await (_database.select(_database.postalOfficeRules)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    if (rule == null) {
      throw StateError('Postal office rule $id was not created');
    }
    return rule;
  }

  Future<PostalOfficeRule> updateRule(PostalOfficeRule rule) async {
    await (_database.update(_database.postalOfficeRules)
          ..where((row) => row.id.equals(rule.id)))
        .write(rule.toCompanion(false));

    final saved = await (_database.select(_database.postalOfficeRules)
          ..where((row) => row.id.equals(rule.id)))
        .getSingleOrNull();
    if (saved == null) {
      throw StateError('Postal office rule ${rule.id} was not found');
    }
    return saved;
  }

  Future<void> deleteRule(int id) async {
    await (_database.delete(_database.postalOfficeRules)
          ..where((row) => row.id.equals(id)))
        .go();
  }

  Future<List<PostalOfficeRule>> getRulesForOffice(int postalOfficeId) {
    return (_database.select(_database.postalOfficeRules)
          ..where((row) => row.postalOfficeId.equals(postalOfficeId))
          ..orderBy([(row) => OrderingTerm.asc(row.id)]))
        .get();
  }

  /// Atomically saves an office and replaces its rules.
  Future<PostalOffice> saveOfficeWithRules({
    int? id,
    required String name,
    required bool isActive,
    required List<PostalOfficeRulesCompanion> rules,
  }) async {
    return _database.transaction(() async {
      final PostalOffice office;
      if (id == null) {
        office = await createOffice(name: name, isActive: isActive);
      } else {
        final existing = await getOffice(id);
        if (existing == null) {
          throw StateError('Postal office $id was not found');
        }
        office = await updateOffice(existing.copyWith(name: name, isActive: isActive));
        // Clear old rules
        await (_database.delete(_database.postalOfficeRules)
              ..where((row) => row.postalOfficeId.equals(id)))
            .go();
      }

      // Insert rules
      for (final rule in rules) {
        await _database.into(_database.postalOfficeRules).insert(
          rule.copyWith(
            postalOfficeId: Value(office.id),
          ),
        );
      }

      return office;
    });
  }
}
