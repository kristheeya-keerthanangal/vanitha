import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../data/repositories/subscriber_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final subscriberRepositoryProvider = Provider<SubscriberRepository>((ref) {
  return SubscriberRepository(ref.watch(databaseProvider));
});
