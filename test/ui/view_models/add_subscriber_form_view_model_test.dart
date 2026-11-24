import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_registration_repository.dart';
import 'package:vanithabodhini/ui/subscribers/view_models/add_subscriber_form_view_model.dart';

void main() {
  late AppDatabase database;
  late AddSubscriberFormViewModel viewModel;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    viewModel = AddSubscriberFormViewModel(
      SubscriberRegistrationRepository(database),
    );
    viewModel
      ..setName('Anita Rao')
      ..setEdition('online')
      ..setPlanType('multi_year')
      ..setStartDate(DateTime.utc(2026, 1, 1));
  });

  tearDown(() async {
    viewModel.dispose();
    await database.close();
  });

  test('requires a duration and saves the entered multi-year value', () async {
    expect(viewModel.durationYears, isEmpty);
    expect(viewModel.validateDuration(viewModel.durationYears), isNotNull);
    expect(await viewModel.save(), isFalse);
    expect(viewModel.submitError, 'Enter a duration greater than one year');
    expect(await database.select(database.subscribers).get(), isEmpty);

    viewModel.setDurationYears('3');
    expect(viewModel.validateDuration(viewModel.durationYears), isNull);
    expect(await viewModel.save(), isTrue);

    final subscription = await database
        .select(database.subscriptions)
        .getSingle();
    expect(subscription.durationYears, 3);
    expect(subscription.expiryDate, '2028-12');
  });

  test('rejects multi-year durations over 50 years', () async {
    viewModel.setDurationYears('51');

    expect(
      viewModel.validateDuration(viewModel.durationYears),
      'Enter a duration of 50 years or less',
    );
    expect(await viewModel.save(), isFalse);
    expect(viewModel.submitError, 'Enter a duration of 50 years or less');
    expect(await database.select(database.subscribers).get(), isEmpty);
  });

  test('sets 15 years duration for lifetime plan and saves it', () async {
    viewModel.setPlanType('lifetime');
    expect(viewModel.durationYears, '15');
    expect(viewModel.showsDuration, isFalse);
    expect(await viewModel.save(), isTrue);

    final subscription = await database
        .select(database.subscriptions)
        .getSingle();
    expect(subscription.planType, 'lifetime');
    expect(subscription.durationYears, 15);
    expect(subscription.expiryDate, '2040-12');
  });
}
