import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/subscriber_import.dart';

void main() {
  const sample = {
    'id': 1,
    'name': 'SALLY BABU',
    'email': 'sally@example.com',
    'phone': '+91 1234567890',
    'postalAddress': 'CHAKKALA KIZHAKKETHIL, ELANGAMANGALAM, ENATHU P. O.',
    'postalCode': '691526',
    'createdAt': '2026-10-15T09:07:18.428487Z',
    'updatedAt': '2026-10-15T09:07:18.428487Z',
    'archivedAt': null,
  };

  test(
    'parses the sample, trims whitespace, and preserves Unicode and zeroes',
    () {
      final entries = parseSubscriberImport(
        '\uFEFF${jsonEncode([
          sample,
          {...sample, 'name': '  സാലി  ', 'postalAddress': '  Main Street  ', 'postalCode': ' 0682001 '},
        ])}',
      );
      expect(entries, hasLength(2));
      expect(entries.first.identity, (
        sample['name'],
        sample['postalAddress'],
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

  for (final field in ['name', 'postalAddress', 'postalCode']) {
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

  test('uses only supported fields from an export', () {
    final entries = parseSubscriberImport(jsonEncode([sample]));

    expect(entries.single.identity, (
      'SALLY BABU',
      'CHAKKALA KIZHAKKETHIL, ELANGAMANGALAM, ENATHU P. O.',
      '691526',
    ));
  });

  test('parses the provided subscriber export', () {
    final entries = parseSubscriberImport(
      File('subscribers.json').readAsStringSync(),
    );

    expect(entries, hasLength(930));
    expect(entries.first.identity, (
      'MINI RAJU',
      'PARAPPALLIL HOUSE, KANNAMANGALAM NORTH, CHETTIKULANGARA P.O',
      '690106',
    ));
  });
}
