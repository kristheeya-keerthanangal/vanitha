import 'dart:async';
import 'dart:io';
import 'dart:ui' show AppExitResponse;

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/backup/backup_coordinator.dart';
import 'package:vanithabodhini/data/backup/backup_settings.dart';
import 'package:vanithabodhini/data/backup/backup_settings_repository.dart';
import 'package:vanithabodhini/data/backup/database_backup_service.dart';
import 'package:vanithabodhini/providers/backup_provider.dart';
import 'package:vanithabodhini/providers/database_provider.dart';
import 'package:vanithabodhini/ui/backup/backup_exit_overlay.dart';
import 'package:vanithabodhini/ui/settings_page.dart';

class FakeBackupSettingsRepository implements BackupSettingsRepository {
  FakeBackupSettingsRepository([this.settings = const BackupSettings()]);
  BackupSettings settings;

  @override
  Future<BackupSettings> loadSettings() async => settings;

  @override
  Future<void> saveSettings(BackupSettings newSettings) async {
    settings = newSettings;
  }

  @override
  bool shouldRunDailyBackup(BackupSettings s, [DateTime? now]) {
    if (!s.isEnabled || !s.isConfigured) return false;
    final current = now ?? DateTime.now();
    final today = BackupSettingsRepository.formatDate(current);
    return s.lastBackupDate != today;
  }
}

class TestBackupService implements DatabaseBackupService {
  int backupCalls = 0;
  Completer<void>? pendingCompleter;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<BackupResult> createBackup({
    required Directory targetDirectory,
    DateTime? now,
    int retentionLimit = 30,
  }) async {
    backupCalls++;
    if (pendingCompleter != null) {
      await pendingCompleter!.future;
    }
    final time = now ?? DateTime.now();
    return BackupResult(
      zipFile: File(p.join(targetDirectory.path, 'vanithabodhini_backup.zip')),
      jsonFile: File(
        p.join(targetDirectory.path, 'vanithabodhini_export.json'),
      ),
      date: '2026-11-24',
      timestamp: time,
      zipSizeBytes: 2048,
    );
  }
}

void main() {
  late AppDatabase database;
  late ProviderContainer container;
  late FakeBackupSettingsRepository settingsRepo;
  late TestBackupService testBackupService;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    settingsRepo = FakeBackupSettingsRepository();
    testBackupService = TestBackupService();
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  group('DatabaseBackup UI in SettingsPage', () {
    testWidgets(
      'displays unconfigured state and allows selecting a backup folder',
      (tester) async {
        final coordinator = BackupCoordinator(
          backupService: testBackupService,
          settingsRepository: settingsRepo,
          directoryPicker: () async => '/my/google_drive/backup',
        );
        await coordinator.settingsRepository.loadSettings();

        container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(database),
            backupCoordinatorProvider.overrideWithValue(coordinator),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: Scaffold(body: SettingsPage())),
          ),
        );
        await tester.pump();

        await tester.ensureVisible(find.text('Database Backup'));
        expect(find.text('Database Backup'), findsOneWidget);
        expect(find.text('No backup folder selected'), findsOneWidget);

        await tester.ensureVisible(find.text('Choose folder'));
        await tester.tap(find.text('Choose folder'));
        await tester.pump();

        expect(find.text('/my/google_drive/backup'), findsOneWidget);
        expect(find.text('Change folder'), findsOneWidget);
      },
    );

    testWidgets('triggers backup and shows success message', (tester) async {
      settingsRepo.settings = const BackupSettings(
        backupDirectory: '/test/onedrive/folder',
        isEnabled: true,
      );

      var exited = false;
      final coordinator = BackupCoordinator(
        backupService: testBackupService,
        settingsRepository: settingsRepo,
        appExitHandler: () async {
          exited = true;
        },
      );
      await coordinator.settingsRepository.loadSettings();

      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(database),
          backupCoordinatorProvider.overrideWithValue(coordinator),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: SettingsPage())),
        ),
      );
      await tester.pump();

      await tester.ensureVisible(find.text('Back up now'));
      await tester.tap(find.text('Back up now'));
      await tester.pump();

      expect(testBackupService.backupCalls, 1);
      expect(find.text('Backup completed successfully.'), findsOneWidget);
      expect(exited, isFalse);
    });
  });

  group('BackupExitOverlay', () {
    testWidgets('does not show dialog when isExitPending is false', (
      tester,
    ) async {
      final coordinator = BackupCoordinator(
        backupService: testBackupService,
        settingsRepository: settingsRepo,
      );

      container = ProviderContainer(
        overrides: [backupCoordinatorProvider.overrideWithValue(coordinator)],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: BackupExitOverlay(
              child: Scaffold(body: Text('Main Content')),
            ),
          ),
        ),
      );

      expect(find.text('Main Content'), findsOneWidget);
      expect(find.text('Backup in progress, please wait...'), findsNothing);
    });

    testWidgets('shows non-dismissible dialog when isExitPending is true', (
      tester,
    ) async {
      final completer = Completer<void>();
      testBackupService.pendingCompleter = completer;

      settingsRepo.settings = const BackupSettings(
        backupDirectory: '/tmp/test',
        isEnabled: true,
      );

      var exited = false;
      final coordinator = BackupCoordinator(
        backupService: testBackupService,
        settingsRepository: settingsRepo,
        appExitHandler: () async {
          exited = true;
        },
      );
      await coordinator.settingsRepository.loadSettings();

      container = ProviderContainer(
        overrides: [backupCoordinatorProvider.overrideWithValue(coordinator)],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: BackupExitOverlay(
              child: Scaffold(body: Text('Main Content')),
            ),
          ),
        ),
      );

      expect(find.text('Backup in progress, please wait...'), findsNothing);

      // Start backup in background
      unawaited(coordinator.runBackup());
      await tester.pump();
      expect(coordinator.isBackingUp, isTrue);

      // Intercept exit request while backing up
      final exitResponse = await coordinator.handleExitRequest();
      expect(exitResponse, AppExitResponse.cancel);
      expect(coordinator.isExitPending, isTrue);

      await tester.pump();

      expect(find.text('Backup in progress, please wait...'), findsOneWidget);
      expect(
        find.text(
          'The application will close automatically once the backup completes.',
        ),
        findsOneWidget,
      );

      // Finish backup
      completer.complete();
      await tester.pump();
      expect(coordinator.isBackingUp, isFalse);
      expect(exited, isTrue);
    });
  });
}
