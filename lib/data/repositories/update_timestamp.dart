/// Every successful edit gets a distinct version, even if the clock moves back.
String nextUpdateTimestamp(String previous) {
  final now = DateTime.now().toUtc();
  final last = DateTime.tryParse(previous)?.toUtc();
  return (last != null && !now.isAfter(last)
          ? last.add(const Duration(microseconds: 1))
          : now)
      .toIso8601String();
}
