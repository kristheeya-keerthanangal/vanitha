import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/pincode_matcher.dart';

PostalOfficeRule createRule({
  int id = 1,
  int postalOfficeId = 1,
  required String operation,
  required String matchMethod,
  required String startValue,
  String? endValue,
}) {
  return PostalOfficeRule(
    id: id,
    postalOfficeId: postalOfficeId,
    operation: operation,
    matchMethod: matchMethod,
    startValue: startValue,
    endValue: endValue,
  );
}

void main() {
  const matcher = PincodeMatcher();

  group('PincodeMatcher - In-Memory Logic', () {
    test('Prefix matching matches prefix and rejects others', () {
      final rules = [
        createRule(
          operation: 'include',
          matchMethod: 'prefix',
          startValue: '671',
        ),
      ];

      expect(matcher.testPincode('671001', rules).matches, isTrue);
      expect(matcher.testPincode('671321', rules).matches, isTrue);
      expect(matcher.testPincode('670999', rules).matches, isFalse);
      expect(matcher.testPincode('672000', rules).matches, isFalse);
    });

    test('Range matching matches boundaries and middle, rejects outside', () {
      final rules = [
        createRule(
          operation: 'include',
          matchMethod: 'range',
          startValue: '670101',
          endValue: '670107',
        ),
      ];

      // Boundaries
      expect(matcher.testPincode('670101', rules).matches, isTrue);
      expect(matcher.testPincode('670107', rules).matches, isTrue);
      // Inside range
      expect(matcher.testPincode('670104', rules).matches, isTrue);
      // Outside
      expect(matcher.testPincode('670100', rules).matches, isFalse);
      expect(matcher.testPincode('670108', rules).matches, isFalse);
    });

    test('Exact matching matches only that specific pincode', () {
      final rules = [
        createRule(
          operation: 'include',
          matchMethod: 'exact',
          startValue: '689590',
        ),
      ];

      expect(matcher.testPincode('689590', rules).matches, isTrue);
      expect(matcher.testPincode('689591', rules).matches, isFalse);
      expect(matcher.testPincode('689589', rules).matches, isFalse);
    });

    test('Multiple Include rules match if any one matches', () {
      final rules = [
        createRule(id: 1, operation: 'include', matchMethod: 'prefix', startValue: '670'),
        createRule(id: 2, operation: 'include', matchMethod: 'prefix', startValue: '671'),
      ];

      expect(matcher.testPincode('670001', rules).matches, isTrue);
      expect(matcher.testPincode('671001', rules).matches, isTrue);
      expect(matcher.testPincode('672001', rules).matches, isFalse);
    });

    test('Multiple Exclude rules exclude if any exclude matches', () {
      final rules = [
        createRule(id: 1, operation: 'include', matchMethod: 'prefix', startValue: '689'),
        createRule(id: 2, operation: 'exclude', matchMethod: 'exact', startValue: '689590'),
        createRule(id: 3, operation: 'exclude', matchMethod: 'exact', startValue: '689595'),
      ];

      expect(matcher.testPincode('689101', rules).matches, isTrue);
      expect(matcher.testPincode('689590', rules).matches, isFalse);
      expect(matcher.testPincode('689595', rules).matches, isFalse);
    });

    test('Exclusion overrides inclusion', () {
      final rules = [
        createRule(id: 1, operation: 'include', matchMethod: 'prefix', startValue: '689'),
        createRule(id: 2, operation: 'exclude', matchMethod: 'exact', startValue: '689590'),
      ];

      final result = matcher.testPincode('689590', rules);
      expect(result.matches, isFalse);
      expect(result.matchedIncludeRule?.id, 1);
      expect(result.blockedByExcludeRule?.id, 2);
    });

    test('Office without Include rules matches nothing', () {
      final rules = [
        createRule(id: 1, operation: 'exclude', matchMethod: 'exact', startValue: '689590'),
      ];

      expect(matcher.testPincode('689590', rules).matches, isFalse);
      expect(matcher.testPincode('670001', rules).matches, isFalse);
      expect(matcher.testPincode('689591', []).matches, isFalse);
    });

    test('Overlapping office rules can match same pincode independently', () {
      // Office A: 670 prefix
      final officeARules = [
        createRule(id: 1, postalOfficeId: 1, operation: 'include', matchMethod: 'prefix', startValue: '670'),
      ];
      // Office B: 670101 to 670107 range
      final officeBRules = [
        createRule(id: 2, postalOfficeId: 2, operation: 'include', matchMethod: 'range', startValue: '670101', endValue: '670107'),
      ];

      const pincode = '670105';
      expect(matcher.testPincode(pincode, officeARules).matches, isTrue);
      expect(matcher.testPincode(pincode, officeBRules).matches, isTrue);
    });

    test('Invalid or missing pincodes return false', () {
      final rules = [
        createRule(operation: 'include', matchMethod: 'prefix', startValue: '671'),
      ];

      expect(matcher.testPincode(null, rules).matches, isFalse);
      expect(matcher.testPincode('', rules).matches, isFalse);
      expect(matcher.testPincode('   ', rules).matches, isFalse);
      expect(matcher.testPincode('671', rules).matches, isFalse); // Not 6 digits
      expect(matcher.testPincode('6710001', rules).matches, isFalse); // 7 digits
      expect(matcher.testPincode('67100A', rules).matches, isFalse); // Non-numeric
    });
  });

  group('PincodeMatcher - SQL Database Level Filtering', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      // Insert test subscribers
      await database.into(database.subscribers).insert(
        SubscribersCompanion.insert(
          name: 'Kasaragod Reader',
          postalCode: const Value('671001'),
        ),
      );
      await database.into(database.subscribers).insert(
        SubscribersCompanion.insert(
          name: 'Kannur Reader',
          postalCode: const Value('670001'),
        ),
      );
      await database.into(database.subscribers).insert(
        SubscribersCompanion.insert(
          name: 'Thalassery Reader',
          postalCode: const Value('670105'),
        ),
      );
      await database.into(database.subscribers).insert(
        SubscribersCompanion.insert(
          name: 'Thiruvalla Regular',
          postalCode: const Value('689101'),
        ),
      );
      await database.into(database.subscribers).insert(
        SubscribersCompanion.insert(
          name: 'Thiruvalla Excluded',
          postalCode: const Value('689590'),
        ),
      );
      await database.into(database.subscribers).insert(
        SubscribersCompanion.insert(
          name: 'No Pincode Reader',
          postalCode: const Value(null),
        ),
      );
    });

    tearDown(() => database.close());

    test('SQL expression filters correctly for Thiruvalla RMS (prefix + exclude)', () async {
      final rules = [
        createRule(id: 1, operation: 'include', matchMethod: 'prefix', startValue: '689'),
        createRule(id: 2, operation: 'exclude', matchMethod: 'exact', startValue: '689590'),
      ];

      final expr = matcher.subscriberMatchesOffice(database.subscribers.postalCode, rules);
      final query = database.select(database.subscribers)..where((_) => expr);
      final results = await query.get();

      expect(results.length, 1);
      expect(results.first.name, 'Thiruvalla Regular');
    });

    test('SQL expression filters correctly for Thalassery STO (range)', () async {
      final rules = [
        createRule(id: 1, operation: 'include', matchMethod: 'range', startValue: '670101', endValue: '670107'),
      ];

      final expr = matcher.subscriberMatchesOffice(database.subscribers.postalCode, rules);
      final query = database.select(database.subscribers)..where((_) => expr);
      final results = await query.get();

      expect(results.length, 1);
      expect(results.first.name, 'Thalassery Reader');
    });

    test('SQL expression with empty include rules returns empty result', () async {
      final rules = <PostalOfficeRule>[];
      final expr = matcher.subscriberMatchesOffice(database.subscribers.postalCode, rules);
      final query = database.select(database.subscribers)..where((_) => expr);
      final results = await query.get();

      expect(results, isEmpty);
    });
  });
}
