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

  test('active renewal locks to next month after maximum inclusive expiry', () {
    final rules = SubscriptionRenewal([
      row('2025-01', '2026-01'),
      row('2026-02', '2026-10'),
    ], today: today);
    expect(rules.locked, isTrue);
    expect(rules.startDate, DateTime(2026, 11));
    expect(rules.startYear, 2026);
    expect(rules.startMonth, 11);
    expect(rules.allows(DateTime(2026, 11)), isTrue);
    expect(rules.allows(today), isFalse);
    expect(rules.allows(DateTime(2026, 12)), isFalse);
  });

  test(
    'expired renewal permits backdating after expiry through current month only',
    () {
      final rules = SubscriptionRenewal([
        row('2025-08', '2026-07'),
      ], today: today);
      expect(rules.locked, isFalse);
      expect(rules.startDate, DateTime(2026, 10));
      expect(rules.firstDate, DateTime(2026, 8));
      expect(rules.lastDate, DateTime(2026, 10));
      expect(rules.allows(DateTime(2026, 7)), isFalse);
      expect(rules.allows(DateTime(2026, 8)), isTrue);
      expect(rules.allows(today), isTrue);
      expect(rules.allows(DateTime(2026, 11)), isFalse);
    },
  );

  test('unsubscribed and archived-only default to current month with past limit', () {
    for (final rows in <List<Subscription>>[
      [],
      [
        row(
          '2027-01',
          '2027-12',
        ).copyWith(archivedAt: const Value('archived')),
      ],
    ]) {
      final rules = SubscriptionRenewal(rows, today: today);
      expect(rules.hasUpcoming, isFalse);
      expect(rules.locked, isFalse);
      expect(rules.startDate, DateTime(2026, 10));
      expect(rules.firstDate, DateTime(2000));
      expect(rules.allows(DateTime(1999, 12)), isFalse);
      expect(rules.allows(DateTime(2015, 6)), isTrue);
      expect(rules.allows(today), isTrue);
      expect(rules.allows(DateTime(2026, 11)), isFalse);
    }
  });

  test('upcoming subscription blocks renewal; starting this month does not', () {
    final rules = SubscriptionRenewal([
      row('2026-11', '2027-10'),
    ], today: today);
    expect(rules.hasUpcoming, isTrue);
    expect(rules.allows(rules.startDate), isFalse);
    expect(
      SubscriptionRenewal([
        row('2026-10', '2027-09'),
      ], today: today).hasUpcoming,
      isFalse,
    );
  });
}
