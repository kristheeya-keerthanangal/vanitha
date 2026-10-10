import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';

typedef SubscriberRegistration = ({
  Subscriber subscriber,
  Subscription subscription,
});

class SubscriberRegistrationRepository {
  SubscriberRegistrationRepository(this._database);

  final AppDatabase _database;

  Future<SubscriberRegistration> registerSubscriber({
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
    required String edition,
    required String planType,
    required int durationYears,
    required DateTime startDate,
    required String paymentStatus,
  }) async {
    final now = _now();
    final normalizedStartDate = _dateOnly(startDate);
    final effectiveDuration = _durationForPlan(planType, durationYears);

    return _database.transaction(() async {
      final subscriberId = await _database
          .into(_database.subscribers)
          .insert(
            SubscribersCompanion.insert(
              subscriberType: subscriberType,
              name: name.trim(),
              contactPersonName: Value(_optional(contactPersonName)),
              email: Value(_optional(email)),
              phone: Value(_optional(phone)),
              postalAddress: Value(_optional(postalAddress)),
              city: Value(_optional(city)),
              state: Value(_optional(state)),
              postalCode: Value(_optional(postalCode)),
              country: Value(_optional(country)),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      final subscriber = await (_database.select(
        _database.subscribers,
      )..where((row) => row.id.equals(subscriberId))).getSingle();
      await _writeAudit(subscriberId: subscriberId, updated: subscriber);

      final subscriptionId = await _database
          .into(_database.subscriptions)
          .insert(
            SubscriptionsCompanion.insert(
              subscriberId: subscriberId,
              edition: edition,
              planType: planType,
              durationYears: effectiveDuration,
              startDate: _formatDate(normalizedStartDate),
              expiryDate: _formatDate(
                _addYears(normalizedStartDate, effectiveDuration),
              ),
              paymentStatus: paymentStatus,
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      final subscription = await (_database.select(
        _database.subscriptions,
      )..where((row) => row.id.equals(subscriptionId))).getSingle();

      return (subscriber: subscriber, subscription: subscription);
    });
  }

  Future<void> _writeAudit({
    required int subscriberId,
    required Subscriber updated,
  }) {
    return _database
        .into(_database.auditLogs)
        .insert(
          AuditLogsCompanion.insert(
            subscriberId: subscriberId,
            previousValues: const Value(null),
            updatedValues: jsonEncode(updated.toJson()),
            modifiedAt: Value(_now()),
          ),
        );
  }

  String? _optional(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
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

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
