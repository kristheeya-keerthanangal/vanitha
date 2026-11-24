import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../subscriber_import.dart';
import '../subscription_expiry.dart';
import '../subscription_status.dart';
import 'update_timestamp.dart';

enum SubscriberSort { number, name }

enum SubscriberFilter { all, active, expired }

enum SubscriberOriginFilter { all, domestic, foreign }

enum MailingListFilter { active, expired, all }

class MailingListEntry {
  const MailingListEntry({
    required this.subscriberId,
    required this.name,
    required this.postalAddress,
    required this.postalCode,
  });

  final int subscriberId;
  final String name;
  final String? postalAddress;
  final String? postalCode;

  bool get isAddressMissing => postalAddress?.trim().isEmpty ?? true;
  bool get isPostalCodeMissing => postalCode?.trim().isEmpty ?? true;
  bool get hasIncompleteMailingDetails =>
      isAddressMissing || isPostalCodeMissing;
}

class SubscriberPage {
  const SubscriberPage({
    required this.rows,
    required this.total,
    this.statuses = const {},
  });
  final List<Subscriber> rows;
  final int total;
  final Map<int, SubscriberStatus> statuses;
}

class SubscriberStatus {
  const SubscriberStatus({required this.status, this.expiryDate});

  final SubscriptionStatus status;
  final String? expiryDate;

  bool get isActive => status == SubscriptionStatus.active;
}

class SubscriberRepository {
  SubscriberRepository(this._database)
    : _subscriptionExpiry = SubscriptionExpiry(_database);

  final AppDatabase _database;
  final SubscriptionExpiry _subscriptionExpiry;

  Future<String> exportSubscribers() async {
    final query = _database.select(_database.subscribers)
      ..orderBy([(row) => OrderingTerm.asc(row.id)]);
    final subscribers = await query.get();
    return const JsonEncoder.withIndent(
      '  ',
    ).convert([for (final subscriber in subscribers) subscriber.toJson()]);
  }

  /// Exports every subscriber together with all of their subscriptions.
  ///
  /// The regular subscriber export remains import-compatible. This complete
  /// export is intended as a full backup, so it includes archived subscribers
  /// and archived subscriptions too.
  Future<String> exportCompleteSubscribers() async {
    final subscriberQuery = _database.select(_database.subscribers)
      ..orderBy([(row) => OrderingTerm.asc(row.id)]);
    final subscriptionQuery = _database.select(_database.subscriptions)
      ..orderBy([
        (row) => OrderingTerm.asc(row.subscriberId),
        (row) => OrderingTerm.asc(row.id),
      ]);
    final subscribers = await subscriberQuery.get();
    final subscriptions = await subscriptionQuery.get();
    final subscriptionsBySubscriber = <int, List<Subscription>>{};
    for (final subscription in subscriptions) {
      subscriptionsBySubscriber
          .putIfAbsent(subscription.subscriberId, () => [])
          .add(subscription);
    }

    return const JsonEncoder.withIndent('  ').convert([
      for (final subscriber in subscribers)
        {
          ...subscriber.toJson(),
          'subscriptions': [
            for (final subscription
                in subscriptionsBySubscriber[subscriber.id] ?? const [])
              subscription.toJson(),
          ],
        },
    ]);
  }

  // Missing PIN codes come last; each group is ordered by name, then ID.
  Future<List<MailingListEntry>> getMailingList({
    MailingListFilter filter = MailingListFilter.active,
  }) async {
    final table = _database.subscribers;
    final statusPredicate = switch (filter) {
      MailingListFilter.active => _subscriptionExpiry.statusForSubscriber(
        SubscriptionStatus.active,
        table.id,
        edition: 'offline',
      ),
      MailingListFilter.expired => _subscriptionExpiry.statusForSubscriber(
        SubscriptionStatus.expired,
        table.id,
        edition: 'offline',
      ),
      MailingListFilter.all => const Constant(true),
    };

    final query = _database.selectOnly(table)
      ..addColumns([
        table.id,
        table.name,
        table.postalAddress,
        table.postalCode,
      ])
      ..where(table.archivedAt.isNull() & statusPredicate)
      ..orderBy([
        OrderingTerm.asc(table.name.collate(Collate.noCase)),
        OrderingTerm.asc(table.id),
      ]);
    final rows = await query.get();
    final withPostalCode = <MailingListEntry>[];
    final withoutPostalCode = <MailingListEntry>[];
    for (final row in rows) {
      final entry = MailingListEntry(
        subscriberId: row.read(table.id)!,
        name: row.read(table.name)!,
        postalAddress: row.read(table.postalAddress),
        postalCode: row.read(table.postalCode),
      );
      (entry.isPostalCodeMissing ? withoutPostalCode : withPostalCode).add(
        entry,
      );
    }
    return [...withPostalCode, ...withoutPostalCode];
  }

  Future<SubscriberPage> getSubscribersPage({
    int offset = 0,
    int limit = 25,
    String search = '',
    SubscriberSort sortBy = SubscriberSort.name,
    SubscriberFilter filterBy = SubscriberFilter.all,
    SubscriberOriginFilter originFilter = SubscriberOriginFilter.all,
    bool ascending = true,
  }) {
    if (offset < 0 || ![10, 25, 50].contains(limit)) {
      throw ArgumentError('Invalid pagination parameters');
    }
    final filter = _subscribersFilter(search) &
        _statusFilter(filterBy) &
        _originFilter(originFilter);
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
      final rows = await query.get();
      return SubscriberPage(
        rows: rows,
        total: total,
        statuses: await _getStatuses(rows),
      );
    });
  }

  Future<Map<int, SubscriberStatus>> _getStatuses(List<Subscriber> rows) async {
    if (rows.isEmpty) return const {};
    final subscriptions = _database.subscriptions;
    final result =
        await (_database.select(subscriptions)..where(
              (subscription) =>
                  subscription.subscriberId.isIn(rows.map((row) => row.id)) &
                  subscription.archivedAt.isNull(),
            ))
            .get();
    final subscriptionsBySubscriber = <int, List<Subscription>>{};
    for (final subscription in result) {
      subscriptionsBySubscriber
          .putIfAbsent(subscription.subscriberId, () => [])
          .add(subscription);
    }

    return {
      for (final row in rows)
        row.id: _statusForSubscriptions(
          subscriptionsBySubscriber[row.id] ?? const [],
        ),
    };
  }

  SubscriberStatus _statusForSubscriptions(List<Subscription> subscriptions) {
    String? latestExpiry;
    for (final subscription in subscriptions) {
      if (latestExpiry == null ||
          subscription.expiryDate.compareTo(latestExpiry) > 0) {
        latestExpiry = subscription.expiryDate;
      }
    }
    return SubscriberStatus(
      status: SubscriptionStatusResolver.resolve(subscriptions),
      expiryDate: latestExpiry,
    );
  }

  Expression<bool> _subscribersFilter(String search) {
    final table = _database.subscribers;
    final active = table.archivedAt.isNull();
    final query = search.trim();
    if (query.isEmpty) return active;
    final literal = query
        .replaceAll('\\', '\\\\')
        .replaceAll('%', '\\%')
        .replaceAll('_', '\\_');
    final pattern = '%$literal%';
    return active &
        (table.name.like(pattern, escapeChar: '\\') |
            table.email.like(pattern, escapeChar: '\\') |
            table.phone.like(pattern, escapeChar: '\\') |
            table.postalCode.equals(query));
  }

  Expression<bool> _statusFilter(SubscriberFilter filter) {
    if (filter == SubscriberFilter.all) return const Constant(true);

    final status = filter == SubscriberFilter.active
        ? SubscriptionStatus.active
        : SubscriptionStatus.expired;
    return _subscriptionExpiry.statusForSubscriber(
      status,
      _database.subscribers.id,
    );
  }

  Expression<bool> _originFilter(SubscriberOriginFilter filter) {
    return switch (filter) {
      SubscriberOriginFilter.all => const Constant(true),
      SubscriberOriginFilter.domestic => _database.subscribers.isForeign.not(),
      SubscriberOriginFilter.foreign => _database.subscribers.isForeign,
    };
  }

  Future<Subscriber> createSubscriber({
    required String name,
    String? email,
    String? phone,
    String? postalAddress,
    String? postalCode,
    bool isForeign = false,
  }) async {
    final now = _now();

    return _database.transaction(() async {
      final id = await _database
          .into(_database.subscribers)
          .insert(
            SubscribersCompanion.insert(
              name: name.trim(),
              email: Value(_optional(email)),
              phone: Value(_optional(phone)),
              postalAddress: Value(_optional(postalAddress)),
              postalCode: Value(_optional(postalCode)),
              isForeign: Value(isForeign),
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

  Future<SubscriberImportPreview> previewImport(
    List<SubscriberImportEntry> entries,
  ) async {
    final seen = await _importIdentities();
    return SubscriberImportPreview(
      total: entries.length,
      entries: [
        for (final entry in entries)
          if (seen.add(entry.identity)) entry,
      ],
    );
  }

  Future<SubscriberImportResult> importSubscribers(
    SubscriberImportPreview preview,
  ) {
    return _database.transaction(() async {
      final seen = await _importIdentities();
      var inserted = 0;
      for (final entry in preview.entries) {
        if (!seen.add(entry.identity)) continue;
        await createSubscriber(
          name: entry.name,
          postalAddress: entry.address,
          postalCode: entry.pincode,
        );
        inserted++;
      }
      return SubscriberImportResult(
        inserted: inserted,
        skipped: preview.total - inserted,
      );
    });
  }

  Future<Set<(String, String, String)>> _importIdentities() async {
    final table = _database.subscribers;
    final query = _database.selectOnly(table)
      ..addColumns([table.name, table.postalAddress, table.postalCode])
      ..where(table.archivedAt.isNull());
    final rows = await query.get();
    return {
      for (final row in rows)
        (
          row.read(table.name)!.trim(),
          row.read(table.postalAddress)?.trim() ?? '',
          row.read(table.postalCode)?.trim() ?? '',
        ),
    };
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

      if (subscriber.updatedAt != previous.updatedAt) {
        throw StateError('Subscriber has changed. Reload it before saving');
      }
      if (subscriber.archivedAt != previous.archivedAt) {
        throw StateError('Use archiveSubscriber or restoreSubscriber');
      }
      final updated = subscriber.copyWith(
        createdAt: previous.createdAt,
        updatedAt: nextUpdateTimestamp(previous.updatedAt),
      );
      final changed =
          await (_database.update(_database.subscribers)..where(
                (row) =>
                    row.id.equals(subscriber.id) &
                    row.updatedAt.equals(previous.updatedAt),
              ))
              .write(updated.toCompanion(false));
      if (changed != 1) {
        throw StateError('Subscriber has changed. Reload it before saving');
      }
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

      final now = nextUpdateTimestamp(subscriber.updatedAt);
      final updated = SubscribersCompanion(
        updatedAt: Value(now),
        archivedAt: Value(archive ? now : null),
      );
      await (_database.update(
        _database.subscribers,
      )..where((row) => row.id.equals(id))).write(updated);
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

  String? _optional(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
