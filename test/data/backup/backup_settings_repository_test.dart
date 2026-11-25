import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vanithabodhini/data/backup/backup_settings.dart';
import 'package:vanithabodhini/data/backup/backup_settings_repository.dart';

void main() {
  late Directory tempDir;
  late File settingsFile;
  late BackupSettingsRepository repository;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('backup_settings_test_');
    settingsFile = File(p.join(tempDir.path, 'backup_settings.json'));
    repository = BackupSettingsRepository(
      settingsFileLocator: () async => settingsFile,
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('BackupSettingsRepository', () {
    test('loadSettings returns default settings when file does not exist', () async {
      final settings = await repository.loadSettings();
      expect(settings.backupDirectory, isNull);
      expect(settings.lastBackupDate, isNull);
      expect(settings.isEnabled, isTrue);
      expect(settings.retentionDays, 30);
      expect(settings.isConfigured, isFalse);
    });

    test('saveSettings and loadSettings round-trips all fields', () async {
      const initial = BackupSettings(
        backupDirectory: '/path/to/backup',
        lastBackupDate: '2026-11-24',
        lastBackupTimestamp: '2026-11-24T10:00:00.000Z',
        lastBackupStatus: 'success',
        lastBackupError: null,
        isEnabled: true,
        retentionDays: 30,
      );

      await repository.saveSettings(initial);
      expect(settingsFile.existsSync(), isTrue);

      final loaded = await repository.loadSettings();
      expect(loaded.backupDirectory, '/path/to/backup');
      expect(loaded.lastBackupDate, '2026-11-24');
      expect(loaded.lastBackupTimestamp, '2026-11-24T10:00:00.000Z');
      expect(loaded.lastBackupStatus, 'success');
      expect(loaded.lastBackupError, isNull);
      expect(loaded.isEnabled, isTrue);
      expect(loaded.retentionDays, 30);
      expect(loaded.isConfigured, isTrue);
    });

    test('shouldRunDailyBackup checks enabled, directory, and date', () {
      final now = DateTime(2026, 11, 24, 15, 30);

      // Disabled -> false
      expect(
        repository.shouldRunDailyBackup(
          const BackupSettings(
            backupDirectory: '/backups',
            isEnabled: false,
          ),
          now,
        ),
        isFalse,
      );

      // No directory -> false
      expect(
        repository.shouldRunDailyBackup(
          const BackupSettings(
            backupDirectory: null,
            isEnabled: true,
          ),
          now,
        ),
        isFalse,
      );

      // Directory configured, never backed up -> true
      expect(
        repository.shouldRunDailyBackup(
          const BackupSettings(
            backupDirectory: '/backups',
            lastBackupDate: null,
            isEnabled: true,
          ),
          now,
        ),
        isTrue,
      );

      // Backed up on previous day -> true
      expect(
        repository.shouldRunDailyBackup(
          const BackupSettings(
            backupDirectory: '/backups',
            lastBackupDate: '2026-11-23',
            isEnabled: true,
          ),
          now,
        ),
        isTrue,
      );

      // Backed up today -> false
      expect(
        repository.shouldRunDailyBackup(
          const BackupSettings(
            backupDirectory: '/backups',
            lastBackupDate: '2026-11-24',
            isEnabled: true,
          ),
          now,
        ),
        isFalse,
      );
    });

    test('formatDate formats DateTime as YYYY-MM-DD', () {
      expect(
        BackupSettingsRepository.formatDate(DateTime(2026, 1, 5)),
        '2026-01-05',
      );
      expect(
        BackupSettingsRepository.formatDate(DateTime(2026, 12, 31)),
        '2026-12-31',
      );
    });
  });
}
