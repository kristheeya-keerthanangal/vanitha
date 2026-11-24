import '../app_database.dart';
import 'subscriber_repository.dart';
import 'subscription_repository.dart';

typedef SubscriberRegistration = ({
  Subscriber subscriber,
  Subscription subscription,
});

class SubscriberRegistrationRepository {
  SubscriberRegistrationRepository(AppDatabase database)
    : _database = database,
      _subscriberRepository = SubscriberRepository(database),
      _subscriptionRepository = SubscriptionRepository(database);

  final AppDatabase _database;
  final SubscriberRepository _subscriberRepository;
  final SubscriptionRepository _subscriptionRepository;

  Future<SubscriberRegistration> registerSubscriber({
    required String name,
    String? email,
    String? phone,
    String? postalAddress,
    String? postalCode,
    required String edition,
    required String planType,
    required int durationYears,
    required int startYear,
    required int startMonth,
  }) async {
    return _database.transaction(() async {
      final subscriber = await _subscriberRepository.createSubscriber(
        name: name,
        email: email,
        phone: phone,
        postalAddress: postalAddress,
        postalCode: postalCode,
      );
      final subscription = await _subscriptionRepository.createSubscription(
        subscriberId: subscriber.id,
        edition: edition,
        planType: planType,
        durationYears: durationYears,
        startYear: startYear,
        startMonth: startMonth,
      );

      return (subscriber: subscriber, subscription: subscription);
    });
  }
}
