import 'app_database.dart';

class SubscriptionRenewal {
  SubscriptionRenewal(Iterable<Subscription> subscriptions, {DateTime? today}) {
    final now = today ?? DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    final currentDateIndex = currentYear * 12 + (currentMonth - 1);

    int? latestExpiryIndex;
    var upcoming = false;

    for (final subscription in subscriptions) {
      if (subscription.archivedAt != null) continue;
      final start = _parseMonth(subscription.startDate);
      final expiry = _parseMonth(subscription.expiryDate);
      final startIndex = start.year * 12 + (start.month - 1);
      final expiryIndex = expiry.year * 12 + (expiry.month - 1);

      if (startIndex > currentDateIndex) upcoming = true;
      if (latestExpiryIndex == null || expiryIndex > latestExpiryIndex) {
        latestExpiryIndex = expiryIndex;
      }
    }

    hasUpcoming = upcoming;
    locked = latestExpiryIndex != null && currentDateIndex <= latestExpiryIndex;

    if (latestExpiryIndex == null) {
      firstYear = 2020;
      firstMonth = 1;
      startYear = currentYear;
      startMonth = currentMonth;
      lastYear = currentYear;
      lastMonth = currentMonth;
    } else if (locked) {
      final nextMonthIndex = latestExpiryIndex + 1;
      final nextY = nextMonthIndex ~/ 12;
      final nextM = nextMonthIndex % 12 + 1;
      firstYear = nextY;
      firstMonth = nextM;
      startYear = nextY;
      startMonth = nextM;
      lastYear = nextY;
      lastMonth = nextM;
    } else {
      final nextMonthIndex = latestExpiryIndex + 1;
      firstYear = nextMonthIndex ~/ 12;
      firstMonth = nextMonthIndex % 12 + 1;
      startYear = currentYear;
      startMonth = currentMonth;
      lastYear = currentYear;
      lastMonth = currentMonth;
    }
  }

  late final bool hasUpcoming;
  late final bool locked;
  late final int startYear;
  late final int startMonth;
  late final int firstYear;
  late final int firstMonth;
  late final int lastYear;
  late final int lastMonth;

  DateTime get startDate => DateTime(startYear, startMonth);
  DateTime get firstDate => DateTime(firstYear, firstMonth);
  DateTime get lastDate => DateTime(lastYear, lastMonth);

  String get startMonthLabel =>
      '${startYear.toString().padLeft(4, '0')}-${startMonth.toString().padLeft(2, '0')}';

  bool allows(DateTime value) => allowsYearMonth(value.year, value.month);

  bool allowsYearMonth(int year, int month) {
    if (hasUpcoming) return false;
    final index = year * 12 + (month - 1);
    final firstIndex = firstYear * 12 + (firstMonth - 1);
    final lastIndex = lastYear * 12 + (lastMonth - 1);
    return index >= firstIndex && index <= lastIndex;
  }

  static ({int year, int month}) _parseMonth(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})').firstMatch(value);
    if (match == null) {
      throw FormatException('Invalid subscription month: $value');
    }
    return (
      year: int.parse(match.group(1)!),
      month: int.parse(match.group(2)!),
    );
  }
}
