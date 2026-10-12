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
    String? city,
    String? state,
    String? postalCode,
    String? country,
    required String edition,
    required String planType,
    required int durationYears,
    required DateTime startDate,
  }) async {
    return _database.transaction(() async {
      final subscriber = await _subscriberRepository.createSubscriber(
        name: name,
        email: email,
        phone: phone,
        postalAddress: postalAddress,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
      );
      final subscription = await _subscriptionRepository.createSubscription(
        subscriberId: subscriber.id,
        edition: edition,
        planType: planType,
        durationYears: durationYears,
        startDate: startDate,
      );

      return (subscriber: subscriber, subscription: subscription);
    });
  }
}
