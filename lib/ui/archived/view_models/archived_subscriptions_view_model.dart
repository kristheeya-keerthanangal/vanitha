import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/subscription_repository.dart';
import '../../../providers/database_provider.dart';

final archivedSubscriptionsViewModelProvider =
    StreamProvider.autoDispose<List<ArchivedSubscriptionDetails>>((ref) {
      return ref
          .watch(subscriptionRepositoryProvider)
          .watchArchivedSubscriptions();
    });

final archivedSubscriptionDetailsViewModelProvider = StreamProvider.autoDispose
    .family<ArchivedSubscriptionDetails?, int>((ref, id) {
      return ref
          .watch(subscriptionRepositoryProvider)
          .watchArchivedSubscription(id);
    });
