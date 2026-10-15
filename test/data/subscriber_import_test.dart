import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/subscriber_import.dart';

void main() {
  const sample = {
    'subscriber_name': 'SALLY BABU',
    'address': 'CHAKKALA KIZHAKKETHIL, ELANGAMANGALAM, ENATHU P. O.',
    'pincode': '691526',
  };

  test(
    'parses the sample, trims whitespace, and preserves Unicode and zeroes',
    () {
      final entries = parseSubscriberImport(
        '\uFEFF${jsonEncode([
          sample,
          {'subscriber_name': '  സാലി  ', 'address': '  Main Street  ', 'pincode': ' 0682001 '},
        ])}',
      );
      expect(entries, hasLength(2));
      expect(entries.first.identity, (
        sample['subscriber_name'],
        sample['address'],
        '691526',
      ));
      expect(entries.last.identity, ('സാലി', 'Main Street', '0682001'));
      expect(() => entries.clear(), throwsUnsupportedError);
    },
  );

  for (final value in [
    'not json',
    '',
    '{}',
    'null',
    '1',
    '[]',
    '[null]',
    '[[]]',
    '["name"]',
  ]) {
    test('rejects invalid root or entry: $value', () {
      expect(() => parseSubscriberImport(value), throwsFormatException);
    });
  }

  for (final field in sample.keys) {
    test('rejects a missing $field with its entry number', () {
      final row = Map<String, Object?>.of(sample)..remove(field);
      expect(
        () => parseSubscriberImport(jsonEncode([sample, row])),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            allOf(contains('Entry 2'), contains(field)),
          ),
        ),
      );
    });
    for (final invalid in [null, 691526, true, [], {}, '', '   ']) {
      test('rejects $field value $invalid', () {
        final row = Map<String, Object?>.of(sample)..[field] = invalid;
        expect(
          () => parseSubscriberImport(jsonEncode([sample, row])),
          throwsFormatException,
        );
      });
    }
  }

  test('rejects extra fields', () {
    expect(
      () => parseSubscriberImport(
        jsonEncode([
          {...sample, 'email': 'sally@example.com'},
        ]),
      ),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('unexpected field "email"'),
        ),
      ),
    );
  });
}
