import 'dart:io';
import 'dart:ui' show AppExitResponse;

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vanithabodhini/data/backup/backup_coordinator.dart';
import 'package:vanithabodhini/data/backup/backup_settings.dart';
import 'package:vanithabodhini/data/backup/backup_settings_repository.dart';
import 'package:vanithabodhini/data/backup/database_backup_service.dart';

class FakeDatabaseBackupService implements DatabaseBackupService {
  FakeDatabaseBackupService({
    this.shouldFail = false,
    this.delay = Duration.zero,
  });

  bool shouldFail;
  Duration delay;
  int backupCalls = 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<BackupResult> createBackup({
    required Directory targetDirectory,
    DateTime? now,
    int retentionLimit = 30,
  }) async {
    backupCalls++;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (shouldFail) {
      throw StateError('Simulated backup error');
    }
    final time = now ?? DateTime.now();
    return BackupResult(
      zipFile: File(p.join(targetDirectory.path, 'vanithabodhini_backup_2026-11-24.zip')),
      jsonFile: File(p.join(targetDirectory.path, 'vanithabodhini_export_2026-11-24.json')),
      date: '2026-11-24',
      timestamp: time,
      zipSizeBytes: 1024,
    );
  }
}

void main() {
  late Directory tempDir;
  late File settingsFile;
  late BackupSettingsRepository settingsRepo;
  late FakeDatabaseBackupService fakeService;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('backup_coordinator_test_');
    settingsFile = File(p.join(tempDir.path, 'settings.json'));
    settingsRepo = BackupSettingsRepository(
      settingsFileLocator: () async => settingsFile,
    );
    fakeService = FakeDatabaseBackupService();
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('BackupCoordinator', () {
    test('reports error if backup is triggered without configured folder', () async {
      final coordinator = BackupCoordinator(
        backupService: fakeService,
        settingsRepository: settingsRepo,
      );
      // Wait for async _initSettings
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final success = await coordinator.runBackup();
      expect(success, isFalse);
      expect(coordinator.lastError, contains('No backup folder selected'));
      expect(fakeService.backupCalls, 0);
    });

    test('runs backup and updates settings when configured', () async {
      await settingsRepo.saveSettings(
        const BackupSettings(
          backupDirectory: '/test/folder',
          isEnabled: true,
        ),
      );

      final coordinator = BackupCoordinator(
        backupService: fakeService,
        settingsRepository: settingsRepo,
        nowProvider: () => DateTime(2026, 11, 24, 12, 0),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final success = await coordinator.runBackup();
      expect(success, isTrue);
      expect(fakeService.backupCalls, 1);
      expect(coordinator.settings.lastBackupDate, '2026-11-24');
      expect(coordinator.settings.lastBackupStatus, 'success');
      expect(coordinator.lastSuccessMessage, contains('completed successfully'));
    });

    test('checkAndRunDailyBackup triggers backup if not backed up today', () async {
      await settingsRepo.saveSettings(
        const BackupSettings(
          backupDirectory: '/test/folder',
          lastBackupDate: '2026-11-23',
          isEnabled: true,
        ),
      );

      final coordinator = BackupCoordinator(
        backupService: fakeService,
        settingsRepository: settingsRepo,
        nowProvider: () => DateTime(2026, 11, 24, 9, 0),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await coordinator.checkAndRunDailyBackup();
      expect(fakeService.backupCalls, 1);
      expect(coordinator.settings.lastBackupDate, '2026-11-24');
    });

    test('checkAndRunDailyBackup skips backup if already backed up today', () async {
      await settingsRepo.saveSettings(
        const BackupSettings(
          backupDirectory: '/test/folder',
          lastBackupDate: '2026-11-24',
          isEnabled: true,
        ),
      );

      final coordinator = BackupCoordinator(
        backupService: fakeService,
        settingsRepository: settingsRepo,
        nowProvider: () => DateTime(2026, 11, 24, 18, 0),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await coordinator.checkAndRunDailyBackup();
      expect(fakeService.backupCalls, 0);
    });

    test('handleExitRequest returns exit when idle', () async {
      final coordinator = BackupCoordinator(
        backupService: fakeService,
        settingsRepository: settingsRepo,
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final response = await coordinator.handleExitRequest();
      expect(response, AppExitResponse.exit);
      expect(coordinator.isExitPending, isFalse);
    });

    test('handleExitRequest returns cancel while backing up and calls exit handler on completion', () async {
      fakeService.delay = const Duration(milliseconds: 100);
      var exitHandlerCalled = false;

      await settingsRepo.saveSettings(
        const BackupSettings(
          backupDirectory: '/test/folder',
          isEnabled: true,
        ),
      );

      final coordinator = BackupCoordinator(
        backupService: fakeService,
        settingsRepository: settingsRepo,
        appExitHandler: () async {
          exitHandlerCalled = true;
        },
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Start long-running backup
      final backupFuture = coordinator.runBackup();
      expect(coordinator.isBackingUp, isTrue);

      // User attempts to close app window while backup is in progress
      final response = await coordinator.handleExitRequest();
      expect(response, AppExitResponse.cancel);
      expect(coordinator.isExitPending, isTrue);
      expect(exitHandlerCalled, isFalse);

      // Wait for backup to finish
      await backupFuture;
      expect(coordinator.isBackingUp, isFalse);
      expect(exitHandlerCalled, isTrue);
    });

    test('selectBackupDirectory updates directory in settings', () async {
      final coordinator = BackupCoordinator(
        backupService: fakeService,
        settingsRepository: settingsRepo,
        directoryPicker: () async => '/chosen/google_drive/backups',
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await coordinator.selectBackupDirectory();
      expect(coordinator.settings.backupDirectory, '/chosen/google_drive/backups');

      final saved = await settingsRepo.loadSettings();
      expect(saved.backupDirectory, '/chosen/google_drive/backups');
    });

    test('setEnabled toggles isEnabled in settings', () async {
      final coordinator = BackupCoordinator(
        backupService: fakeService,
        settingsRepository: settingsRepo,
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await coordinator.setEnabled(false);
      expect(coordinator.settings.isEnabled, isFalse);

      final saved = await settingsRepo.loadSettings();
      expect(saved.isEnabled, isFalse);
    });
  });
}
