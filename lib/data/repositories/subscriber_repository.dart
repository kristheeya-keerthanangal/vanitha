import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';

class SubscriberRepository {
  SubscriberRepository(this._database);

  final AppDatabase _database;

  Future<Subscriber> createSubscriber({
    required String subscriberType,
    required String name,
    String? contactPersonName,
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
              subscriberType: subscriberType,
              name: name,
              contactPersonName: Value(contactPersonName),
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
    final previous = await getSubscriber(subscriber.id, includeArchived: true);
    if (previous == null) {
      throw StateError('Subscriber ${subscriber.id} was not found');
    }

    final updated = subscriber.copyWith(updatedAt: _now());
    return _database.transaction(() async {
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

  Future<Subscriber> archiveSubscriber(int id) async {
    final subscriber = await getSubscriber(id, includeArchived: true);
    if (subscriber == null) {
      throw StateError('Subscriber $id was not found');
    }
    if (subscriber.archivedAt != null) return subscriber;

    return _changeArchiveState(subscriber, _now());
  }

  Future<Subscriber> restoreSubscriber(int id) async {
    final subscriber = await getSubscriber(id, includeArchived: true);
    if (subscriber == null) {
      throw StateError('Subscriber $id was not found');
    }
    if (subscriber.archivedAt == null) return subscriber;

    return _changeArchiveState(subscriber, null);
  }

  Future<Subscriber> _changeArchiveState(
    Subscriber subscriber,
    String? archivedAt,
  ) async {
    final updated = subscriber.copyWith(
      updatedAt: _now(),
      archivedAt: Value(archivedAt),
    );

    return _database.transaction(() async {
      await (_database.update(_database.subscribers)
            ..where((row) => row.id.equals(subscriber.id)))
          .write(updated.toCompanion(false));
      final saved = await getSubscriber(subscriber.id, includeArchived: true);
      if (saved == null) {
        throw StateError('Subscriber ${subscriber.id} was not updated');
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
