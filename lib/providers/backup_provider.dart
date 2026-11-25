import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/backup/backup_coordinator.dart';
import '../data/backup/backup_settings_repository.dart';
import '../data/backup/database_backup_service.dart';
import 'database_provider.dart';

final backupSettingsRepositoryProvider =
    Provider<BackupSettingsRepository>((ref) {
  return BackupSettingsRepository();
});

final databaseBackupServiceProvider = Provider<DatabaseBackupService>((ref) {
  return DatabaseBackupService(
    database: ref.watch(databaseProvider),
    subscriberRepository: ref.watch(subscriberRepositoryProvider),
  );
});

final backupCoordinatorProvider = Provider<BackupCoordinator>((ref) {
  final coordinator = BackupCoordinator(
    backupService: ref.watch(databaseBackupServiceProvider),
    settingsRepository: ref.watch(backupSettingsRepositoryProvider),
  );
  ref.onDispose(coordinator.dispose);
  return coordinator;
});
