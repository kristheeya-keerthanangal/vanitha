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

  group('parseCompleteSubscriberImport', () {
    const completeSample = {
      'id': 10,
      'name': 'FOREIGN READER',
      'email': 'foreign@example.com',
      'phone': '+44 7911 123456',
      'postalAddress': 'London, UK',
      'postalCode': null,
      'isForeign': true,
      'createdAt': '2026-11-20T10:00:00.000Z',
      'updatedAt': '2026-11-20T10:00:00.000Z',
      'archivedAt': null,
      'subscriptions': [
        {
          'id': 1,
          'subscriberId': 10,
          'edition': 'online',
          'planType': 'lifetime',
          'durationYears': 15,
          'startDate': '2026-01',
          'expiryDate': '2040-12',
          'createdAt': '2026-11-20T10:00:00.000Z',
          'updatedAt': '2026-11-20T10:00:00.000Z',
          'archivedAt': null,
        },
        {
          'id': 2,
          'subscriberId': 10,
          'edition': 'offline',
          'planType': 'multi_year',
          'durationYears': 3,
          'startDate': '2026-01',
          'expiryDate': '2028-12',
          'createdAt': '2026-11-20T10:00:00.000Z',
          'updatedAt': '2026-11-20T10:00:00.000Z',
          'archivedAt': '2026-11-20T10:05:00.000Z',
        },
      ],
    };

    test('parses full subscriber with subscriptions, isForeign, and null postalCode', () {
      final entries = parseCompleteSubscriberImport(
        '\uFEFF${jsonEncode([completeSample])}',
      );
      expect(entries, hasLength(1));
      final entry = entries.single;
      expect(entry.name, 'FOREIGN READER');
      expect(entry.email, 'foreign@example.com');
      expect(entry.phone, '+44 7911 123456');
      expect(entry.postalAddress, 'London, UK');
      expect(entry.postalCode, isNull);
      expect(entry.isForeign, isTrue);
      expect(entry.subscriptions, hasLength(2));
      expect(entry.subscriptions[0].edition, 'online');
      expect(entry.subscriptions[0].planType, 'lifetime');
      expect(entry.subscriptions[0].durationYears, 15);
      expect(entry.subscriptions[1].edition, 'offline');
      expect(entry.subscriptions[1].planType, 'multi_year');
      expect(entry.subscriptions[1].durationYears, 3);
      expect(entry.subscriptions[1].archivedAt, '2026-11-20T10:05:00.000Z');
    });

    test('parses wrapped object format with subscribers key', () {
      final entries = parseCompleteSubscriberImport(
        jsonEncode({'subscribers': [completeSample]}),
      );
      expect(entries, hasLength(1));
      expect(entries.single.name, 'FOREIGN READER');
    });

    test('parses domestic subscriber and defaults isForeign to false when absent', () {
      final entries = parseCompleteSubscriberImport(
        jsonEncode([
          {
            'name': 'Domestic Reader',
            'postalAddress': 'Ernakulam',
            'postalCode': '682001',
          },
        ]),
      );
      expect(entries.single.isForeign, isFalse);
      expect(entries.single.subscriptions, isEmpty);
    });

    for (final invalid in [
      'not json',
      '',
      '{}',
      '[]',
      '[null]',
      '{"subscribers": []}',
    ]) {
      test('rejects invalid JSON structure: $invalid', () {
        expect(
          () => parseCompleteSubscriberImport(invalid),
          throwsFormatException,
        );
      });
    }

    test('rejects missing or blank subscriber name', () {
      expect(
        () => parseCompleteSubscriberImport(jsonEncode([{'name': ''}])),
        throwsFormatException,
      );
      expect(
        () => parseCompleteSubscriberImport(jsonEncode([{'email': 'a@b.com'}])),
        throwsFormatException,
      );
    });

    test('rejects invalid subscription edition', () {
      final invalid = {
        'name': 'Reader',
        'subscriptions': [
          {
            'edition': 'digital',
            'planType': 'annual',
            'durationYears': 1,
            'startDate': '2026-01',
            'expiryDate': '2026-12',
          },
        ],
      };
      expect(
        () => parseCompleteSubscriberImport(jsonEncode([invalid])),
        throwsFormatException,
      );
    });

    test('rejects mismatched planType and durationYears', () {
      final invalidAnnual = {
        'name': 'Reader',
        'subscriptions': [
          {
            'edition': 'online',
            'planType': 'annual',
            'durationYears': 2,
            'startDate': '2026-01',
            'expiryDate': '2027-12',
          },
        ],
      };
      expect(
        () => parseCompleteSubscriberImport(jsonEncode([invalidAnnual])),
        throwsFormatException,
      );

      final invalidLifetime = {
        'name': 'Reader',
        'subscriptions': [
          {
            'edition': 'online',
            'planType': 'lifetime',
            'durationYears': 10,
            'startDate': '2026-01',
            'expiryDate': '2035-12',
          },
        ],
      };
      expect(
        () => parseCompleteSubscriberImport(jsonEncode([invalidLifetime])),
        throwsFormatException,
      );
    });
  });
}
