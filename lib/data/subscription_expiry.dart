import 'package:drift/drift.dart';

/// Returns the database predicate used to determine whether a subscription has
/// expired. Expiry dates are inclusive, so a subscription expiring today has
/// not expired yet.
Expression<bool> isSubscriptionExpired(
  Expression<String> expiryDate,
  String today,
) => expiryDate.isSmallerThanValue(today);
