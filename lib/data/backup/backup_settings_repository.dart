import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database_locator.dart';
import 'backup_settings.dart';

class BackupSettingsRepository {
  BackupSettingsRepository({
    Future<File> Function()? settingsFileLocator,
  }) : _settingsFileLocator = settingsFileLocator ?? _defaultSettingsFile;

  final Future<File> Function() _settingsFileLocator;

  static Future<File> _defaultSettingsFile() async {
    Directory dir;
    if (Platform.isWindows) {
      final baseDir = DatabaseLocator.resolveWindowsBaseDir(
        Platform.environment,
      );
      dir = Directory(p.join(baseDir, DatabaseLocator.appDirectoryName));
    } else {
      try {
        dir = await getApplicationSupportDirectory();
      } catch (_) {
        dir = await getApplicationDocumentsDirectory();
      }
    }
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return File(p.join(dir.path, 'backup_settings.json'));
  }

  Future<BackupSettings> loadSettings() async {
    try {
      final file = await _settingsFileLocator();
      if (!file.existsSync()) {
        return const BackupSettings();
      }
      final contents = await file.readAsString();
      if (contents.trim().isEmpty) {
        return const BackupSettings();
      }
      final json = jsonDecode(contents) as Map<String, dynamic>;
      return BackupSettings.fromJson(json);
    } catch (_) {
      return const BackupSettings();
    }
  }

  Future<void> saveSettings(BackupSettings settings) async {
    final file = await _settingsFileLocator();
    if (!file.parent.existsSync()) {
      file.parent.createSync(recursive: true);
    }
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(settings.toJson()));
  }

  bool shouldRunDailyBackup(BackupSettings settings, [DateTime? now]) {
    if (!settings.isEnabled || !settings.isConfigured) {
      return false;
    }
    final current = now ?? DateTime.now();
    final today = formatDate(current);
    return settings.lastBackupDate != today;
  }

  static String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
