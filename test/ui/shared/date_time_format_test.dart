import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/ui/shared/date_time_format.dart';

void main() {
  test('formats UTC timestamps in a readable IST format', () {
    expect(
      formatIstDateTime('2026-08-09T14:30:00.000Z'),
      'August 9, 2026 at 8:00 PM',
    );
  });

  test('handles midnight and invalid timestamps', () {
    expect(
      formatIstDateTime('2026-08-08T18:30:00.000Z'),
      'August 9, 2026 at 12:00 AM',
    );
    expect(formatIstDateTime('not a timestamp'), 'not a timestamp');
  });
}
