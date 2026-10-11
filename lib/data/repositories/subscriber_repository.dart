import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';

enum SubscriberSort { number, name }

class SubscriberPage {
  const SubscriberPage({required this.rows, required this.total});
  final List<Subscriber> rows;
  final int total;
}

class SubscriberRepository {
  SubscriberRepository(this._database);

  final AppDatabase _database;

  Future<SubscriberPage> getSubscribersPage({
    int offset = 0,
    int limit = 25,
    String search = '',
    SubscriberSort sortBy = SubscriberSort.name,
    bool ascending = true,
  }) {
    if (offset < 0 || ![10, 25, 50].contains(limit)) {
      throw ArgumentError('Invalid pagination parameters');
    }
    final literal = search
        .trim()
        .replaceAll('\\', '\\\\')
        .replaceAll('%', '\\%')
        .replaceAll('_', '\\_');
    final filter = _subscribersFilter(literal);
    return _database.transaction(() async {
      final count = _database.subscribers.id.count();
      final countQuery = _database.selectOnly(_database.subscribers)
        ..addColumns([count])
        ..where(filter);
      final total = (await countQuery.getSingle()).read(count)!;
      final Expression<Object> column = sortBy == SubscriberSort.number
          ? _database.subscribers.id
          : _database.subscribers.name.collate(Collate.noCase);
      final query = _database.select(_database.subscribers)
        ..where((_) => filter)
        ..orderBy([
          (_) => OrderingTerm(
            expression: column,
            mode: ascending ? OrderingMode.asc : OrderingMode.desc,
          ),
          (row) => OrderingTerm.asc(row.id),
        ])
        ..limit(limit, offset: offset);
      return SubscriberPage(rows: await query.get(), total: total);
    });
  }

  Expression<bool> _subscribersFilter(String literal) {
    final table = _database.subscribers;
    final active = table.archivedAt.isNull();
    if (literal.isEmpty) return active;
    final pattern = '%$literal%';
    return active &
        (table.name.like(pattern, escapeChar: '\\') |
            table.email.like(pattern, escapeChar: '\\') |
            table.phone.like(pattern, escapeChar: '\\'));
  }

  Future<Subscriber> createSubscriber({
    required String name,
    String? email,
    String? phone,
    String? postalAddress,
    String? city,
    String? state,
    String? postalCode,
    String? country,
  }) async {
    final now = _now();

    return _database.transaction(() async {
      final id = await _database
          .into(_database.subscribers)
          .insert(
            SubscribersCompanion.insert(
              name: name,
              email: Value(email),
              phone: Value(phone),
              postalAddress: Value(postalAddress),
              city: Value(city),
              state: Value(state),
              postalCode: Value(postalCode),
              country: Value(country),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      final subscriber = await getSubscriber(id, includeArchived: true);
      if (subscriber == null) {
        throw StateError('Subscriber $id was not created');
      }
      await _writeAudit(subscriberId: id, updated: subscriber);
      return subscriber;
    });
  }

  Future<Subscriber?> getSubscriber(int id, {bool includeArchived = false}) {
    final query = _database.select(_database.subscribers)
      ..where((subscriber) => subscriber.id.equals(id));
    if (!includeArchived) {
      query.where((subscriber) => subscriber.archivedAt.isNull());
    }
    return query.getSingleOrNull();
  }

  Future<List<Subscriber>> searchSubscribers(
    String query, {
    bool includeArchived = false,
  }) {
    final normalizedQuery = query.trim();
    final select = _database.select(_database.subscribers)
      ..orderBy([(subscriber) => OrderingTerm.asc(subscriber.name)]);

    if (!includeArchived) {
      select.where((subscriber) => subscriber.archivedAt.isNull());
    }
    if (normalizedQuery.isNotEmpty) {
      final pattern = '%$normalizedQuery%';
      select.where(
        (subscriber) =>
            subscriber.name.like(pattern) |
            subscriber.email.like(pattern) |
            subscriber.phone.like(pattern),
      );
    }

    return select.get();
  }

  Future<Subscriber> updateSubscriber(Subscriber subscriber) async {
    return _database.transaction(() async {
      final previous = await getSubscriber(
        subscriber.id,
        includeArchived: true,
      );
      if (previous == null) {
        throw StateError('Subscriber ${subscriber.id} was not found');
      }

      final updated = subscriber.copyWith(updatedAt: _now());
      await (_database.update(_database.subscribers)
            ..where((row) => row.id.equals(subscriber.id)))
          .write(updated.toCompanion(false));
      final saved = await getSubscriber(subscriber.id, includeArchived: true);
      if (saved == null) {
        throw StateError('Subscriber ${subscriber.id} was not updated');
      }
      await _writeAudit(
        subscriberId: saved.id,
        previous: previous,
        updated: saved,
      );
      return saved;
    });
  }

  /// Deletes a subscriber according to the domain's soft-delete rule.
  Future<Subscriber> deleteSubscriber(int id) => archiveSubscriber(id);

  Future<Subscriber> archiveSubscriber(int id) =>
      _changeArchiveState(id, archive: true);

  Future<Subscriber> restoreSubscriber(int id) =>
      _changeArchiveState(id, archive: false);

  Future<Subscriber> _changeArchiveState(int id, {required bool archive}) {
    return _database.transaction(() async {
      final subscriber = await getSubscriber(id, includeArchived: true);
      if (subscriber == null) {
        throw StateError('Subscriber $id was not found');
      }
      if ((subscriber.archivedAt != null) == archive) return subscriber;

      final now = _now();
      final updated = subscriber.copyWith(
        updatedAt: now,
        archivedAt: Value(archive ? now : null),
      );
      await (_database.update(
        _database.subscribers,
      )..where((row) => row.id.equals(id))).write(updated.toCompanion(false));
      final saved = await getSubscriber(id, includeArchived: true);
      if (saved == null) {
        throw StateError('Subscriber $id was not updated');
      }
      await _writeAudit(
        subscriberId: saved.id,
        previous: subscriber,
        updated: saved,
      );
      return saved;
    });
  }

  Future<void> _writeAudit({
    required int subscriberId,
    Subscriber? previous,
    required Subscriber updated,
  }) {
    return _database
        .into(_database.auditLogs)
        .insert(
          AuditLogsCompanion.insert(
            subscriberId: subscriberId,
            previousValues: Value(
              previous == null ? null : jsonEncode(previous.toJson()),
            ),
            updatedValues: jsonEncode(updated.toJson()),
            modifiedAt: Value(_now()),
          ),
        );
  }

  String _now() => DateTime.now().toUtc().toIso8601String();
}
