import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/subscription_renewal.dart';

void main() {
  final today = DateTime(2026, 10, 14);
  Subscription row(String start, String end) => Subscription(
    id: 1,
    subscriberId: 1,
    edition: 'online',
    planType: 'annual',
    durationYears: 1,
    startDate: start,
    expiryDate: end,
    createdAt: '',
    updatedAt: '',
  );

  test('active renewal locks to one day after maximum inclusive expiry', () {
    final rules = SubscriptionRenewal([
      row('2025-01-01', '2026-01-01'),
      row('2026-01-02', '2026-10-14'),
    ], today: today);
    expect(rules.locked, isTrue);
    expect(rules.startDate, DateTime(2026, 10, 15));
    expect(rules.allows(DateTime(2026, 10, 15)), isTrue);
    expect(rules.allows(today), isFalse);
    expect(rules.allows(DateTime(2026, 10, 16)), isFalse);
  });

  test(
    'expired renewal permits backdating after expiry through today only',
    () {
      final rules = SubscriptionRenewal([
        row('2025-10-01', '2026-10-01'),
      ], today: today);
      expect(rules.locked, isFalse);
      expect(rules.startDate, today);
      expect(rules.firstDate, DateTime(2026, 10, 2));
      expect(rules.lastDate, today);
      expect(rules.allows(DateTime(2026, 10, 1)), isFalse);
      expect(rules.allows(DateTime(2026, 10, 2)), isTrue);
      expect(rules.allows(today), isTrue);
      expect(rules.allows(DateTime(2026, 10, 15)), isFalse);
    },
  );

  test('unsubscribed and archived-only default to today with past limit', () {
    for (final rows in <List<Subscription>>[
      [],
      [
        row(
          '2027-01-01',
          '2028-01-01',
        ).copyWith(archivedAt: const Value('archived')),
      ],
    ]) {
      final rules = SubscriptionRenewal(rows, today: today);
      expect(rules.hasUpcoming, isFalse);
      expect(rules.locked, isFalse);
      expect(rules.startDate, today);
      expect(rules.firstDate, DateTime(2020));
      expect(rules.allows(DateTime(2019, 12, 31)), isFalse);
      expect(rules.allows(today), isTrue);
      expect(rules.allows(DateTime(2026, 10, 15)), isFalse);
    }
  });

  test('upcoming subscription blocks renewal; starting today does not', () {
    final rules = SubscriptionRenewal([
      row('2026-10-15', '2027-10-15'),
    ], today: today);
    expect(rules.hasUpcoming, isTrue);
    expect(rules.allows(rules.startDate), isFalse);
    expect(
      SubscriptionRenewal([
        row('2026-10-14', '2027-10-14'),
      ], today: today).hasUpcoming,
      isFalse,
    );
  });
}
