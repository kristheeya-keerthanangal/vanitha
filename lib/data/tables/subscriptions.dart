import 'package:drift/drift.dart';

import 'subscribers.dart';

@TableIndex(name: 'idx_subscriptions_subscriber', columns: {#subscriberId})
@TableIndex(name: 'idx_subscriptions_expiry_date', columns: {#expiryDate})
class Subscriptions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get subscriberId => integer().references(Subscribers, #id)();

  TextColumn get edition => text().customConstraint(
    "NOT NULL CHECK (edition IN ('online', 'offline'))",
  )();

  TextColumn get planType => text().customConstraint(
    "NOT NULL CHECK (plan_type IN ('annual', 'multi_year', 'lifetime'))",
  )();

  IntColumn get durationYears =>
      integer().customConstraint('NOT NULL CHECK (duration_years > 0)')();

  TextColumn get startDate => text()();
  TextColumn get expiryDate => text()();

  TextColumn get paymentStatus => text().customConstraint(
    "NOT NULL CHECK (payment_status IN ('paid', 'unpaid'))",
  )();

  TextColumn get createdAt =>
      text().customConstraint('NOT NULL DEFAULT CURRENT_TIMESTAMP')();

  TextColumn get updatedAt =>
      text().customConstraint('NOT NULL DEFAULT CURRENT_TIMESTAMP')();
}
