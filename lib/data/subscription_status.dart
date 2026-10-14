import 'app_database.dart';

enum SubscriptionStatus { active, expired, notSubscribed }

/// Applies the single set of rules used to classify a subscriber.
class SubscriptionStatusResolver {
  const SubscriptionStatusResolver._();

  static SubscriptionStatus resolve(
    Iterable<Subscription> subscriptions, {
    DateTime? today,
  }) {
    final date = _dateOnly(today ?? DateTime.now());
    DateTime? latestExpiry;

    for (final subscription in subscriptions) {
      if (subscription.archivedAt != null) continue;
      final expiryDate = _dateOnly(_parseDate(subscription.expiryDate));
      if (latestExpiry == null || expiryDate.isAfter(latestExpiry)) {
        latestExpiry = expiryDate;
      }
    }

    if (latestExpiry == null) return SubscriptionStatus.notSubscribed;
    return date.isAfter(latestExpiry)
        ? SubscriptionStatus.expired
        : SubscriptionStatus.active;
  }

  static DateTime _parseDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw FormatException('Invalid subscription date: $value');
    }
    return parsed;
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);
}
