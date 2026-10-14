import 'app_database.dart';

int? latestSubscriptionId(Iterable<Subscription> subscriptions) {
  Subscription? latest;
  for (final subscription in subscriptions) {
    if (subscription.archivedAt != null) continue;
    final comparison = latest == null
        ? 1
        : subscription.expiryDate.compareTo(latest.expiryDate);
    if (comparison > 0 || (comparison == 0 && subscription.id > latest!.id)) {
      latest = subscription;
    }
  }
  return latest?.id;
}
