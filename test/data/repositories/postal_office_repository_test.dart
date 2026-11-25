import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/postal_office_repository.dart';

void main() {
  late AppDatabase database;
  late PostalOfficeRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = PostalOfficeRepository(database);
  });

  tearDown(() => database.close());

  test('createOffice creates and returns an office', () async {
    final office = await repository.createOffice(name: 'Kasaragod RMS');
    expect(office.id, isPositive);
    expect(office.name, 'Kasaragod RMS');
    expect(office.isActive, isTrue);

    final fetched = await repository.getOffice(office.id);
    expect(fetched?.name, 'Kasaragod RMS');
  });

  test('updateOffice updates name and active status', () async {
    final office = await repository.createOffice(name: 'Kannur STO');
    final updated = await repository.updateOffice(
      office.copyWith(name: 'Kannur RMS', isActive: false),
    );

    expect(updated.name, 'Kannur RMS');
    expect(updated.isActive, isFalse);
  });

  test('deleteOffice removes office and its rules', () async {
    final office = await repository.createOffice(name: 'Thalassery STO');
    await repository.addRule(
      postalOfficeId: office.id,
      operation: 'include',
      matchMethod: 'range',
      startValue: '670101',
      endValue: '670107',
    );

    await repository.deleteOffice(office.id);

    expect(await repository.getOffice(office.id), isNull);
    expect(await repository.getRulesForOffice(office.id), isEmpty);
  });

  test('getAllOffices and getActiveOffices return sorted lists', () async {
    await repository.createOffice(name: 'Thiruvalla RMS', isActive: false);
    await repository.createOffice(name: 'Alappuzha RMS', isActive: true);
    await repository.createOffice(name: 'Kottayam RMS', isActive: true);

    final all = await repository.getAllOffices();
    expect(all.map((o) => o.name).toList(), [
      'Alappuzha RMS',
      'Kottayam RMS',
      'Thiruvalla RMS',
    ]);

    final active = await repository.getActiveOffices();
    expect(active.map((o) => o.name).toList(), [
      'Alappuzha RMS',
      'Kottayam RMS',
    ]);
  });

  test('getRuleCountsByOffice returns count of rules per office', () async {
    final office1 = await repository.createOffice(name: 'Office 1');
    final office2 = await repository.createOffice(name: 'Office 2');

    await repository.addRule(
      postalOfficeId: office1.id,
      operation: 'include',
      matchMethod: 'prefix',
      startValue: '671',
    );
    await repository.addRule(
      postalOfficeId: office1.id,
      operation: 'exclude',
      matchMethod: 'exact',
      startValue: '671005',
    );
    await repository.addRule(
      postalOfficeId: office2.id,
      operation: 'include',
      matchMethod: 'prefix',
      startValue: '670',
    );

    final counts = await repository.getRuleCountsByOffice();
    expect(counts[office1.id], 2);
    expect(counts[office2.id], 1);
  });

  test('saveOfficeWithRules atomically creates and updates with rules', () async {
    final office = await repository.saveOfficeWithRules(
      name: 'Thiruvalla RMS',
      isActive: true,
      rules: [
        PostalOfficeRulesCompanion.insert(
          postalOfficeId: -1, // will be replaced
          operation: 'include',
          matchMethod: 'prefix',
          startValue: '689',
        ),
        PostalOfficeRulesCompanion.insert(
          postalOfficeId: -1,
          operation: 'exclude',
          matchMethod: 'exact',
          startValue: '689590',
        ),
      ],
    );

    expect(office.id, isPositive);
    var rules = await repository.getRulesForOffice(office.id);
    expect(rules.length, 2);
    expect(rules[0].startValue, '689');
    expect(rules[1].startValue, '689590');

    // Update with 1 rule
    final updated = await repository.saveOfficeWithRules(
      id: office.id,
      name: 'Thiruvalla Head Post Office',
      isActive: true,
      rules: [
        PostalOfficeRulesCompanion.insert(
          postalOfficeId: office.id,
          operation: 'include',
          matchMethod: 'prefix',
          startValue: '689',
        ),
      ],
    );

    expect(updated.name, 'Thiruvalla Head Post Office');
    rules = await repository.getRulesForOffice(office.id);
    expect(rules.length, 1);
  });
}
