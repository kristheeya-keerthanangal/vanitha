import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/app_database.dart';
import '../../../providers/database_provider.dart';

typedef SubscriberDetails = ({
  Subscriber subscriber,
  List<Subscription> subscriptions,
});

final subscriberDetailsViewModelProvider = FutureProvider.autoDispose
    .family<SubscriberDetails?, int>((ref, id) async {
      final subscriberRepository = ref.watch(subscriberRepositoryProvider);
      final subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
      final subscriber = await subscriberRepository.getSubscriber(id);
      if (subscriber == null) return null;
      final subscriptions = await subscriptionRepository
          .getSubscriptionsForSubscriber(id);
      return (subscriber: subscriber, subscriptions: subscriptions);
    });
