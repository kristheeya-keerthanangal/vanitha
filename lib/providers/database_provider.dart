import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../data/repositories/subscriber_repository.dart';
import '../data/repositories/subscription_repository.dart';

/// The database is an infrastructure dependency. UI code should depend on
/// [subscriberRepositoryProvider] instead of mutating Drift tables directly.
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final subscriberRepositoryProvider = Provider<SubscriberRepository>((ref) {
  return SubscriberRepository(ref.watch(databaseProvider));
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(ref.watch(databaseProvider));
});
