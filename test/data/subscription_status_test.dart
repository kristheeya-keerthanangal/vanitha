import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/subscription_status.dart';

void main() {
  final today = DateTime(2026, 10, 13, 12);

  Subscription subscription(String startDate, String expiryDate) =>
      Subscription(
        id: 1,
        subscriberId: 1,
        edition: 'online',
        planType: 'annual',
        durationYears: 1,
        startDate: startDate,
        expiryDate: expiryDate,
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      );

  test('future-only subscriptions and gaps are not active', () {
    final future = subscription('2026-12-01', '2027-11-30');
    final expired = subscription('2026-01-01', '2026-09-30');

    for (final subscriptions in [
      [future],
      [expired, future],
      [future, expired],
    ]) {
      expect(
        SubscriptionStatusResolver.resolve(subscriptions, today: today),
        isNot(SubscriptionStatus.active),
      );
    }
  });

  test('active date boundaries are inclusive', () {
    for (final subscription in [
      subscription('2026-01-01', '2026-12-31'),
      subscription('2026-10-13', '2027-10-13'),
      subscription('2025-10-13', '2026-10-13'),
    ]) {
      expect(
        SubscriptionStatusResolver.resolve([subscription], today: today),
        SubscriptionStatus.active,
      );
    }
  });

  test(
    'expired subscriptions and archived active subscriptions are not active',
    () {
      expect(
        SubscriptionStatusResolver.resolve([
          subscription('2026-01-01', '2026-09-30'),
        ], today: today),
        SubscriptionStatus.expired,
      );
      expect(
        SubscriptionStatusResolver.resolve([
          subscription(
            '2026-01-01',
            '2026-12-31',
          ).copyWith(archivedAt: const Value('2026-10-12T00:00:00Z')),
        ], today: today),
        SubscriptionStatus.notSubscribed,
      );
    },
  );
}
