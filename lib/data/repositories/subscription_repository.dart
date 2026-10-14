import 'package:drift/drift.dart';

import '../app_database.dart';
import '../subscription_archive.dart';
import '../subscription_renewal.dart';
import 'update_timestamp.dart';

class SubscriptionRepository {
  SubscriptionRepository(this._database);

  final AppDatabase _database;

  Future<Subscription> createSubscription({
    required int subscriberId,
    required String edition,
    required String planType,
    required int durationYears,
    required DateTime startDate,
  }) async {
    final now = _now();
    final normalizedStartDate = _dateOnly(startDate);
    final effectiveDuration = _durationForPlan(planType, durationYears);
    final expiryDate = _addYears(normalizedStartDate, effectiveDuration);

    return _database.transaction(() async {
      await _ensureActiveSubscriber(subscriberId);
      final id = await _database
          .into(_database.subscriptions)
          .insert(
            SubscriptionsCompanion.insert(
              subscriberId: subscriberId,
              edition: edition,
              planType: planType,
              durationYears: effectiveDuration,
              startDate: _formatDate(normalizedStartDate),
              expiryDate: _formatDate(expiryDate),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      final subscription = await getSubscription(id);
      if (subscription == null) {
        throw StateError('Subscription $id was not created');
      }
      return subscription;
    });
  }

  Future<Subscription> renewSubscription({
    required int subscriberId,
    required String edition,
    required String planType,
    required int durationYears,
    required DateTime startDate,
  }) => _database.transaction(() async {
    final rules = SubscriptionRenewal(
      await getSubscriptionsForSubscriber(subscriberId),
    );
    if (!rules.allows(startDate)) {
      throw StateError(
        'Subscription dates have changed or renewal is not allowed. Reopen the form.',
      );
    }
    return createSubscription(
      subscriberId: subscriberId,
      edition: edition,
      planType: planType,
      durationYears: durationYears,
      startDate: startDate,
    );
  });

  Future<void> _ensureActiveSubscriber(int subscriberId) async {
    final subscriber = await (_database.select(
      _database.subscribers,
    )..where((row) => row.id.equals(subscriberId))).getSingleOrNull();
    if (subscriber == null) {
      throw StateError('Subscriber $subscriberId was not found');
    }
    if (subscriber.archivedAt != null) {
      throw StateError('Subscriber $subscriberId is not active');
    }
  }

  Future<Subscription?> getSubscription(
    int id, {
    bool includeArchived = false,
  }) {
    final query = _database.select(_database.subscriptions)
      ..where((subscription) => subscription.id.equals(id));
    if (!includeArchived) {
      query.where((subscription) => subscription.archivedAt.isNull());
    }
    return query.getSingleOrNull();
  }

  Future<List<Subscription>> getSubscriptionsForSubscriber(
    int subscriberId, {
    bool includeArchived = false,
  }) {
    final query = _database.select(_database.subscriptions)
      ..where((subscription) => subscription.subscriberId.equals(subscriberId))
      ..orderBy([(subscription) => OrderingTerm.desc(subscription.startDate)]);
    if (!includeArchived) {
      query.where((subscription) => subscription.archivedAt.isNull());
    }
    return query.get();
  }

  Future<Subscription> updateSubscription(Subscription subscription) async {
    return _database.transaction(() async {
      final previous = await getSubscription(
        subscription.id,
        includeArchived: true,
      );
      if (previous == null) {
        throw StateError('Subscription ${subscription.id} was not found');
      }
      if (subscription.updatedAt != previous.updatedAt) {
        throw StateError('Subscription has changed. Reload it before saving');
      }
      if (subscription.archivedAt != previous.archivedAt) {
        throw StateError('Use archiveSubscription or restoreSubscription');
      }
      final startDate = _parseDate(subscription.startDate);
      final effectiveDuration = _durationForPlan(
        subscription.planType,
        subscription.durationYears,
      );
      final updated = subscription.copyWith(
        durationYears: effectiveDuration,
        startDate: _formatDate(startDate),
        expiryDate: _formatDate(_addYears(startDate, effectiveDuration)),
        createdAt: previous.createdAt,
        updatedAt: nextUpdateTimestamp(previous.updatedAt),
      );
      final changed =
          await (_database.update(_database.subscriptions)..where(
                (row) =>
                    row.id.equals(subscription.id) &
                    row.updatedAt.equals(previous.updatedAt),
              ))
              .write(updated.toCompanion(false));
      if (changed == 0) {
        throw StateError('Subscription has changed. Reload it before saving');
      }
      final saved = await getSubscription(
        subscription.id,
        includeArchived: true,
      );
      if (saved == null) {
        throw StateError('Subscription ${subscription.id} was not updated');
      }
      return saved;
    });
  }

  Future<void> deleteSubscription(int id) async {
    await archiveSubscription(id);
  }

  Future<Subscription> archiveSubscription(int id) =>
      _changeArchiveState(id, archive: true);

  Future<Subscription> restoreSubscription(int id) =>
      _changeArchiveState(id, archive: false);

  Future<Subscription> _changeArchiveState(int id, {required bool archive}) {
    return _database.transaction(() async {
      final previous = await getSubscription(id, includeArchived: true);
      if (previous == null) {
        throw StateError('Subscription $id was not found');
      }
      if ((previous.archivedAt != null) == archive) return previous;
      if (archive &&
          latestSubscriptionId(
                await getSubscriptionsForSubscriber(previous.subscriberId),
              ) !=
              id) {
        throw StateError('Only the latest subscription can be archived');
      }
      final now = nextUpdateTimestamp(previous.updatedAt);
      await (_database.update(
        _database.subscriptions,
      )..where((row) => row.id.equals(id))).write(
        SubscriptionsCompanion(
          updatedAt: Value(now),
          archivedAt: Value(archive ? now : null),
        ),
      );
      return (await getSubscription(id, includeArchived: true))!;
    });
  }

  String _now() => DateTime.now().toUtc().toIso8601String();

  DateTime _dateOnly(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  DateTime _addYears(DateTime date, int years) =>
      DateTime.utc(date.year + years, date.month, date.day);

  int _durationForPlan(String planType, int requestedDuration) {
    switch (planType) {
      case 'annual':
        return 1;
      case 'lifetime':
        return 10;
      case 'multi_year':
        if (requestedDuration > 50) {
          throw ArgumentError(
            'A multi-year plan cannot be longer than 50 years',
          );
        }
        if (requestedDuration > 1) return requestedDuration;
        throw ArgumentError('A multi-year plan must be longer than one year');
      default:
        throw ArgumentError('Unsupported subscription plan: $planType');
    }
  }

  DateTime _parseDate(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})(?:$|T)').firstMatch(value);
    final parsed = DateTime.tryParse(value);
    if (match == null || parsed == null) {
      throw FormatException('Invalid subscription start date: $value');
    }

    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final normalized = DateTime.utc(year, month, day);
    if (normalized.year != year ||
        normalized.month != month ||
        normalized.day != day) {
      throw FormatException('Invalid subscription start date: $value');
    }
    return normalized;
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
