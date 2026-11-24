import 'app_database.dart';

enum SubscriptionStatus { active, expired, notSubscribed }

/// Applies the single set of rules used to classify a subscriber.
class SubscriptionStatusResolver {
  const SubscriptionStatusResolver._();

  static SubscriptionStatus resolve(
    Iterable<Subscription> subscriptions, {
    DateTime? today,
  }) {
    final now = today ?? DateTime.now();
    final currentMonth =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
    String? latestExpiry;

    for (final subscription in subscriptions) {
      if (subscription.archivedAt != null) continue;
      final expiryMonth = subscription.expiryDate.length >= 7
          ? subscription.expiryDate.substring(0, 7)
          : subscription.expiryDate;
      if (latestExpiry == null || expiryMonth.compareTo(latestExpiry) > 0) {
        latestExpiry = expiryMonth;
      }
    }

    if (latestExpiry == null) return SubscriptionStatus.notSubscribed;
    return currentMonth.compareTo(latestExpiry) > 0
        ? SubscriptionStatus.expired
        : SubscriptionStatus.active;
  }
}
