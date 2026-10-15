import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';
import 'package:vanithabodhini/data/repositories/subscription_repository.dart';

void main() {
  late AppDatabase database;
  late SubscriberRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = SubscriberRepository(database);
  });

  tearDown(() => database.close());

  test('returns an empty mailing list for an empty database', () async {
    expect(await repository.getMailingList(), isEmpty);
  });

  test('returns all non-archived subscribers without a page limit', () async {
    await database.batch(
      (batch) => batch.insertAll(database.subscribers, [
        for (var i = 0; i < 125; i++)
          SubscribersCompanion.insert(
            name: 'Reader ${i.toString().padLeft(3, '0')}',
            postalAddress: const Value('Main Street'),
            postalCode: const Value('682001'),
          ),
      ]),
    );
    final archived = await repository.createSubscriber(name: 'Archived');
    await repository.archiveSubscriber(archived.id);

    final rows = await repository.getMailingList();

    expect(rows, hasLength(125));
    expect(
      rows.map((row) => row.subscriberId),
      List.generate(125, (i) => i + 1),
    );
    expect(rows.first.name, 'Reader 000');
    expect(rows.first.postalAddress, 'Main Street');
    expect(rows.first.postalCode, '682001');
    expect(rows.every((row) => !row.hasIncompleteMailingDetails), isTrue);

    await repository.restoreSubscriber(archived.id);
    expect(await repository.getMailingList(), hasLength(126));
  });

  test(
    'orders names case-insensitively, breaks ties by ID, and puts missing PINs last',
    () async {
      Future<Subscriber> add(String name, String? pin) =>
          repository.createSubscriber(name: name, postalCode: pin);

      final missingZ = await add('Zara', null);
      final zara = await add('Zara', '100001');
      final firstAnita = await add('anita', '900001');
      final secondAnita = await add('ANITA', '100001');
      final missingA = await add('Anita', '  ');
      final missingATie = await add('ANITA', null);
      final bela = await add('Bela', '500001');

      expect(
        (await repository.getMailingList()).map((row) => row.subscriberId),
        [
          firstAnita.id,
          secondAnita.id,
          bela.id,
          zara.id,
          missingA.id,
          missingATie.id,
          missingZ.id,
        ],
      );
    },
  );

  test(
    'keeps distinct subscribers with identical details and emits one row per subscriber regardless of subscriptions',
    () async {
      final first = await repository.createSubscriber(
        name: 'Same Reader',
        postalAddress: 'Same Address',
        postalCode: '682001',
      );
      final second = await repository.createSubscriber(
        name: first.name,
        postalAddress: first.postalAddress,
        postalCode: first.postalCode,
      );
      final subscriptions = SubscriptionRepository(database);
      for (final edition in ['online', 'offline']) {
        await subscriptions.createSubscription(
          subscriberId: first.id,
          edition: edition,
          planType: 'annual',
          durationYears: 1,
          startDate: DateTime(2020),
        );
      }

      final rows = await repository.getMailingList();
      expect(rows.map((row) => row.subscriberId), [first.id, second.id]);
      expect(rows.map((row) => row.name), ['Same Reader', 'Same Reader']);
      expect(rows.map((row) => row.postalAddress), [
        'Same Address',
        'Same Address',
      ]);
      expect(rows.map((row) => row.postalCode), ['682001', '682001']);
    },
  );

  test(
    'retains null, empty, and whitespace details and flags each missing field',
    () async {
      final expected = <int, (String?, String?, bool, bool)>{};
      for (final address in <String?>[null, '', ' \t\n ', 'Main Street']) {
        for (final pin in <String?>[null, '', ' \t\n ', '682001']) {
          // Insert directly to cover legacy blanks that creation normalizes to null.
          final id = await database
              .into(database.subscribers)
              .insert(
                SubscribersCompanion.insert(
                  name: 'Reader',
                  postalAddress: Value(address),
                  postalCode: Value(pin),
                ),
              );
          expected[id] = (
            address,
            pin,
            address == null || address.trim().isEmpty,
            pin == null || pin.trim().isEmpty,
          );
        }
      }

      final rows = await repository.getMailingList();
      expect(rows, hasLength(expected.length));
      expect(
        rows.map((row) => row.subscriberId).toSet(),
        expected.keys.toSet(),
      );
      for (final row in rows) {
        final (address, pin, addressMissing, pinMissing) =
            expected[row.subscriberId]!;
        expect(row.postalAddress, address);
        expect(row.postalCode, pin);
        expect(row.isAddressMissing, addressMissing);
        expect(row.isPostalCodeMissing, pinMissing);
        expect(row.hasIncompleteMailingDetails, addressMissing || pinMissing);
      }
      final pinMissing = rows.map((row) => row.isPostalCodeMissing).toList();
      expect(pinMissing, [
        false,
        false,
        false,
        false,
        ...List.filled(12, true),
      ]);
    },
  );
}
