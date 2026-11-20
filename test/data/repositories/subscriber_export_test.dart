import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';

void main() {
  late AppDatabase database;
  late SubscriberRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = SubscriberRepository(database);
  });
  tearDown(() => database.close());

  test('empty database exports a JSON array', () async {
    expect(jsonDecode(await repository.exportSubscribers()), isEmpty);
  });

  test(
    'exports all fields and archived records without pagination or writes',
    () async {
      final first = await repository.createSubscriber(
        name: 'മലയാളം "Reader"',
        email: 'reader@example.com',
        phone: '+91 1234567890',
        postalAddress: 'First line\nSecond line',
        postalCode: '0682001',
      );
      await repository.archiveSubscriber(first.id);
      for (var i = 0; i < 55; i++) {
        await repository.createSubscriber(name: 'Reader $i');
      }
      final before = await database.select(database.subscribers).get();
      final audits = await database.select(database.auditLogs).get();

      final decoded = jsonDecode(await repository.exportSubscribers()) as List;

      expect(decoded, hasLength(56));
      expect(decoded, before.map((row) => row.toJson()).toList());
      expect(decoded.first['archivedAt'], isNotNull);
      expect(decoded.first['postalCode'], '0682001');
      expect(decoded.first['name'], 'മലയാളം "Reader"');
      expect(decoded.last['postalAddress'], isNull);
      expect(await database.select(database.subscribers).get(), before);
      expect(await database.select(database.auditLogs).get(), audits);
    },
  );
}
