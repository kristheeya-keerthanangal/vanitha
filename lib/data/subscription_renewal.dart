import 'app_database.dart';

class SubscriptionRenewal {
  SubscriptionRenewal(Iterable<Subscription> subscriptions, {DateTime? today}) {
    final now = today ?? DateTime.now();
    final date = DateTime(now.year, now.month, now.day);
    DateTime? latestExpiry;
    var upcoming = false;
    for (final subscription in subscriptions) {
      if (subscription.archivedAt != null) continue;
      final start = DateTime.parse(subscription.startDate);
      final expiry = DateTime.parse(subscription.expiryDate);
      if (start.isAfter(date)) upcoming = true;
      if (latestExpiry == null || expiry.isAfter(latestExpiry)) {
        latestExpiry = expiry;
      }
    }
    hasUpcoming = upcoming;
    locked = latestExpiry != null && !date.isAfter(latestExpiry);
    firstDate = latestExpiry == null
        ? DateTime(2020)
        : DateTime(latestExpiry.year, latestExpiry.month, latestExpiry.day + 1);
    startDate = locked ? firstDate : date;
    lastDate = locked ? firstDate : date;
  }

  late final bool hasUpcoming;
  late final bool locked;
  late final DateTime startDate;
  late final DateTime firstDate;
  late final DateTime lastDate;

  bool allows(DateTime value) {
    final date = DateTime(value.year, value.month, value.day);
    return !hasUpcoming && !date.isBefore(firstDate) && !date.isAfter(lastDate);
  }
}
