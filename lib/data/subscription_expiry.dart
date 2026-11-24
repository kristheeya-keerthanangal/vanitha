import 'package:drift/drift.dart';

import 'app_database.dart';
import 'subscription_status.dart';
import 'tables/subscriptions.dart';

/// Centralizes the rules used to determine a subscriber's effective expiry.
///
/// Only non-archived subscriptions are considered. When a subscriber has more
/// than one such subscription, the latest expiry is the effective expiry. The
/// SQL predicate uses the equivalent `EXISTS`/`NOT EXISTS` form so it can be
/// used while filtering subscribers without loading every subscription row.
class SubscriptionExpiry {
  SubscriptionExpiry(this._database);

  final AppDatabase _database;

  /// Returns the latest non-archived expiry for an active subscriber.
  Future<String?> getEffectiveExpiryDate(int subscriberId) async {
    final subscriber =
        await (_database.select(_database.subscribers)..where(
              (row) => row.id.equals(subscriberId) & row.archivedAt.isNull(),
            ))
            .getSingleOrNull();
    if (subscriber == null) return null;

    final subscriptions = _database.subscriptions;
    final latestExpiry = subscriptions.expiryDate.max();
    final query = _database.selectOnly(subscriptions)
      ..addColumns([latestExpiry])
      ..where(
        subscriptions.subscriberId.equals(subscriberId) &
            subscriptions.archivedAt.isNull(),
      );
    return (await query.getSingle()).read(latestExpiry);
  }

  /// Returns the SQL predicate for an active subscriber having an expired
  /// effective subscription. A subscriber without a subscription is not
  /// considered expired.
  Expression<bool> isExpiredForSubscriber(Expression<int> subscriberId) {
    return statusForSubscriber(SubscriptionStatus.expired, subscriberId);
  }

  /// Returns the SQL predicate for an active subscriber having a subscription.
  Expression<bool> hasSubscriptionForSubscriber(
    Expression<int> subscriberId, {
    String? edition,
  }) {
    return _hasSubscriptionForSubscriber(subscriberId, edition: edition);
  }

  Expression<bool> _hasSubscriptionForSubscriber(
    Expression<int> subscriberId, {
    String? edition,
  }) {
    final subscriptions = _database.select(_database.subscriptions)
      ..where(
        (row) =>
            row.subscriberId.equalsExp(subscriberId) &
            row.archivedAt.isNull() &
            (edition == null
                ? const Constant(true)
                : row.edition.equals(edition)),
      );
    return existsQuery(subscriptions);
  }

  Expression<bool> _hasSubscriptionMatching(
    Expression<int> subscriberId,
    Expression<bool> Function(Subscriptions row, String currentMonth) predicate, {
    String? edition,
  }) {
    final thisMonth = currentMonth();
    final subscriptions = _database.select(_database.subscriptions)
      ..where(
        (row) =>
            row.subscriberId.equalsExp(subscriberId) &
            row.archivedAt.isNull() &
            (edition == null
                ? const Constant(true)
                : row.edition.equals(edition)) &
            predicate(row, thisMonth),
      );
    return existsQuery(subscriptions);
  }

  /// Returns the SQL predicate matching the shared subscriber status rules.
  Expression<bool> statusForSubscriber(
    SubscriptionStatus status,
    Expression<int> subscriberId, {
    String? edition,
  }) {
    final hasSubscription = _hasSubscriptionForSubscriber(
      subscriberId,
      edition: edition,
    );
    final hasActiveSubscription = _hasSubscriptionMatching(
      subscriberId,
      (row, thisMonth) => row.expiryDate.isSmallerThanValue(thisMonth).not(),
      edition: edition,
    );

    return switch (status) {
      SubscriptionStatus.active => hasActiveSubscription,
      SubscriptionStatus.expired =>
        hasSubscription & hasActiveSubscription.not(),
      SubscriptionStatus.notSubscribed => hasSubscription.not(),
    };
  }

  /// Expiry months are inclusive, so a subscription expiring in the current month
  /// has not expired yet.
  static bool isExpiryDateExpired(String expiryDate, {DateTime? todayDate}) {
    final thisMonth = formatMonth(todayDate ?? DateTime.now());
    final expiryMonth =
        expiryDate.length >= 7 ? expiryDate.substring(0, 7) : expiryDate;
    return expiryMonth.compareTo(thisMonth) < 0;
  }

  /// Returns the database predicate used for one subscription expiry date.
  static Expression<bool> isSubscriptionExpired(
    Expression<String> expiryDate,
    String thisMonth,
  ) => expiryDate.isSmallerThanValue(thisMonth);

  static String currentMonth([DateTime? date]) =>
      formatMonth(date ?? DateTime.now());

  static String today() => currentMonth();

  static String formatMonth(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}';

  static String formatDate(DateTime date) => formatMonth(date);
}

/// Backwards-compatible shorthand for the shared SQL expiry predicate.
Expression<bool> isSubscriptionExpired(
  Expression<String> expiryDate,
  String today,
) => SubscriptionExpiry.isSubscriptionExpired(expiryDate, today);
