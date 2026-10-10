import 'package:drift/drift.dart';

import '../app_database.dart';

class SubscriptionRepository {
  SubscriptionRepository(this._database);

  final AppDatabase _database;

  Future<Subscription> createSubscription({
    required int subscriberId,
    required String edition,
    required String planType,
    required int durationYears,
    required DateTime startDate,
    required String paymentStatus,
  }) async {
    final now = _now();
    final normalizedStartDate = _dateOnly(startDate);
    final effectiveDuration = _durationForPlan(planType, durationYears);
    final expiryDate = _addYears(normalizedStartDate, effectiveDuration);

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
            paymentStatus: paymentStatus,
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    final subscription = await getSubscription(id);
    if (subscription == null) {
      throw StateError('Subscription $id was not created');
    }
    return subscription;
  }

  Future<Subscription?> getSubscription(int id) {
    return (_database.select(
      _database.subscriptions,
    )..where((subscription) => subscription.id.equals(id))).getSingleOrNull();
  }

  Future<List<Subscription>> getSubscriptionsForSubscriber(int subscriberId) {
    return (_database.select(_database.subscriptions)
          ..where(
            (subscription) => subscription.subscriberId.equals(subscriberId),
          )
          ..orderBy([
            (subscription) => OrderingTerm.desc(subscription.startDate),
          ]))
        .get();
  }

  Future<Subscription> updateSubscription(Subscription subscription) async {
    final startDate = _parseDate(subscription.startDate);
    final effectiveDuration = _durationForPlan(
      subscription.planType,
      subscription.durationYears,
    );
    final updated = subscription.copyWith(
      durationYears: effectiveDuration,
      expiryDate: _formatDate(_addYears(startDate, effectiveDuration)),
      updatedAt: _now(),
    );
    final changed =
        await (_database.update(_database.subscriptions)
              ..where((row) => row.id.equals(subscription.id)))
            .write(updated.toCompanion(false));
    if (changed == 0) {
      throw StateError('Subscription ${subscription.id} was not found');
    }
    final saved = await getSubscription(subscription.id);
    if (saved == null) {
      throw StateError('Subscription ${subscription.id} was not updated');
    }
    return saved;
  }

  Future<void> deleteSubscription(int id) async {
    final deleted = await (_database.delete(
      _database.subscriptions,
    )..where((subscription) => subscription.id.equals(id))).go();
    if (deleted == 0) {
      throw StateError('Subscription $id was not found');
    }
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
        if (requestedDuration > 1) return requestedDuration;
        throw ArgumentError('A multi-year plan must be longer than one year');
      default:
        throw ArgumentError('Unsupported subscription plan: $planType');
    }
  }

  DateTime _parseDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw FormatException('Invalid subscription start date: $value');
    }
    return _dateOnly(parsed);
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
