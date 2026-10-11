const _monthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String formatIstDateTime(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;

  final utc = parsed.isUtc
      ? parsed
      : DateTime.utc(
          parsed.year,
          parsed.month,
          parsed.day,
          parsed.hour,
          parsed.minute,
          parsed.second,
        );
  final ist = utc.add(const Duration(hours: 5, minutes: 30));
  final hour = ist.hour % 12 == 0 ? 12 : ist.hour % 12;
  final minute = ist.minute.toString().padLeft(2, '0');
  final period = ist.hour >= 12 ? 'PM' : 'AM';

  return '${_monthNames[ist.month - 1]} ${ist.day}, ${ist.year} '
      'at $hour:$minute $period';
}
