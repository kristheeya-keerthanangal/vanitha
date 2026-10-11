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

  IntColumn get durationYears => integer().customConstraint('''
    NOT NULL CHECK (
      (plan_type = 'annual' AND duration_years = 1) OR
      (plan_type = 'multi_year' AND duration_years > 1) OR
      (plan_type = 'lifetime' AND duration_years = 10)
    )
  ''')();

  TextColumn get startDate => text()();
  TextColumn get expiryDate => text()();

  TextColumn get paymentStatus => text().customConstraint(
    "NOT NULL CHECK (payment_status IN ('paid', 'unpaid'))",
  )();

  TextColumn get createdAt =>
      text().customConstraint('NOT NULL DEFAULT CURRENT_TIMESTAMP')();

  TextColumn get updatedAt =>
      text().customConstraint('NOT NULL DEFAULT CURRENT_TIMESTAMP')();

  TextColumn get archivedAt => text().nullable()();
}
