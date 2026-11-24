import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';
import 'package:vanithabodhini/ui/subscribers/view_models/edit_subscriber_form_view_model.dart';

void main() {
  late AppDatabase database;
  late SubscriberRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = SubscriberRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('prefills the form from the subscriber', () async {
    final subscriber = await repository.createSubscriber(
      name: 'Anita Rao',
      email: 'anita@example.com',
      phone: '9876543210',
      postalAddress: '10 Main Street',
      postalCode: '682001',
      isForeign: true,
    );
    final viewModel = EditSubscriberFormViewModel(repository, subscriber);
    addTearDown(viewModel.dispose);

    expect(viewModel.name, 'Anita Rao');
    expect(viewModel.email, 'anita@example.com');
    expect(viewModel.phone, '9876543210');
    expect(viewModel.postalAddress, '10 Main Street');
    expect(viewModel.postalCode, '682001');
    expect(viewModel.isForeign, isTrue);
  });

  test('updates personal details and clears blank optional fields', () async {
    final subscriber = await repository.createSubscriber(
      name: 'Original Reader',
      email: 'old@example.com',
      phone: '9876543210',
      postalAddress: 'Old address',
      postalCode: '682001',
    );
    final viewModel = EditSubscriberFormViewModel(repository, subscriber);
    addTearDown(viewModel.dispose);

    viewModel
      ..setName(' Updated Reader ')
      ..setEmail('')
      ..setPhone('  ')
      ..setPostalAddress('New address')
      ..setPostalCode('')
      ..setIsForeign(true);

    expect(await viewModel.save(), isTrue);

    final saved = await repository.getSubscriber(subscriber.id);
    expect(saved, isNotNull);
    expect(saved!.name, 'Updated Reader');
    expect(saved.email, isNull);
    expect(saved.phone, isNull);
    expect(saved.postalAddress, 'New address');
    expect(saved.postalCode, isNull);
    expect(saved.isForeign, isTrue);
    expect(await database.select(database.auditLogs).get(), hasLength(2));
  });

  test('validates email and phone formats', () async {
    final subscriber = await repository.createSubscriber(name: 'Reader');
    final viewModel = EditSubscriberFormViewModel(repository, subscriber);
    addTearDown(viewModel.dispose);

    expect(viewModel.validateEmail('invalid'), isNotNull);
    expect(viewModel.validatePhone('123'), isNotNull);
    expect(viewModel.validateEmail('reader@example.com'), isNull);
    expect(viewModel.validatePhone('9876543210'), isNull);
  });

  test('rejects an empty name', () async {
    final subscriber = await repository.createSubscriber(name: 'Reader');
    final viewModel = EditSubscriberFormViewModel(repository, subscriber);
    addTearDown(viewModel.dispose);

    viewModel.setName('   ');

    expect(await viewModel.save(), isFalse);
    expect(viewModel.submitError, 'Enter a subscriber name.');
    expect((await repository.getSubscriber(subscriber.id))!.name, 'Reader');
  });

  test('does not overwrite a subscriber changed elsewhere', () async {
    final original = await repository.createSubscriber(name: 'Original');
    final viewModel = EditSubscriberFormViewModel(repository, original);
    addTearDown(viewModel.dispose);

    await repository.updateSubscriber(original.copyWith(name: 'Latest'));
    viewModel.setName('Stale edit');

    expect(await viewModel.save(), isFalse);
    expect(
      viewModel.submitError,
      'This subscriber was changed elsewhere. Reload and try again.',
    );
    expect((await repository.getSubscriber(original.id))!.name, 'Latest');
  });
}
