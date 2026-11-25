import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../app_database.dart';
import '../repositories/subscriber_repository.dart';

class BackupResult {
  const BackupResult({
    required this.zipFile,
    required this.jsonFile,
    required this.date,
    required this.timestamp,
    required this.zipSizeBytes,
  });

  final File zipFile;
  final File jsonFile;
  final String date;
  final DateTime timestamp;
  final int zipSizeBytes;
}

class DatabaseBackupService {
  DatabaseBackupService({
    required this.database,
    required this.subscriberRepository,
  });

  final AppDatabase database;
  final SubscriberRepository subscriberRepository;

  static final RegExp _backupZipRegex =
      RegExp(r'^vanithabodhini_backup_(\d{4}-\d{2}-\d{2})(?:_.*)?\.zip$');
  static final RegExp _backupJsonRegex =
      RegExp(r'^vanithabodhini_export_(\d{4}-\d{2}-\d{2})(?:_.*)?\.json$');

  /// Creates a point-in-time consistent backup in [targetDirectory].
  ///
  /// Steps:
  /// 1. Staging directory created.
  /// 2. SQLite VACUUM INTO produces an atomic, WAL-merged database snapshot.
  /// 3. Snapshot verified via PRAGMA quick_check.
  /// 4. Complete JSON export generated and written.
  /// 5. Snapshot and JSON packaged into a staging zip.
  /// 6. Zip archive verified with CRC32 checks via ZipDecoder.
  /// 7. Verified zip and JSON files atomically copied/renamed into [targetDirectory].
  /// 8. Backups older than [retentionLimit] days pruned from [targetDirectory].
  /// 9. Staging files cleaned up.
  Future<BackupResult> createBackup({
    required Directory targetDirectory,
    DateTime? now,
    int retentionLimit = 30,
  }) async {
    final timestamp = now ?? DateTime.now();
    final dateStr = _formatDate(timestamp);

    if (!targetDirectory.existsSync()) {
      targetDirectory.createSync(recursive: true);
    }

    final stagingDir = Directory.systemTemp.createTempSync(
      'vb_backup_${timestamp.millisecondsSinceEpoch}_',
    );

    try {
      final stagingDb = File(p.join(stagingDir.path, 'vanithabodhini.sqlite'));
      final stagingJson = File(p.join(stagingDir.path, 'data_export.json'));

      // 1. Consistent SQLite point-in-time snapshot
      if (stagingDb.existsSync()) {
        stagingDb.deleteSync();
      }
      final escapedDbPath = stagingDb.path.replaceAll("'", "''");
      await database.customStatement("VACUUM INTO '$escapedDbPath'");

      if (!stagingDb.existsSync() || stagingDb.lengthSync() == 0) {
        throw StateError('VACUUM INTO failed to create a valid SQLite snapshot.');
      }

      // Verify SQLite snapshot integrity
      _verifySqliteSnapshot(stagingDb);

      // 2. Full JSON data export
      final jsonContents =
          await subscriberRepository.exportCompleteSubscribers();
      if (jsonContents.trim().isEmpty) {
        throw StateError('Exported subscriber JSON data is empty.');
      }
      await stagingJson.writeAsString(jsonContents);

      // 3. Package staging zip archive
      final stagingZip = File(p.join(stagingDir.path, 'staging.zip'));
      final encoder = ZipFileEncoder();
      encoder.create(stagingZip.path);
      await encoder.addFile(stagingDb, 'vanithabodhini.sqlite');
      await encoder.addFile(stagingJson, 'data_export.json');
      await encoder.close();

      // 4. Verify zip archive integrity
      verifyZipArchive(stagingZip);

      // 5. Standalone JSON export in destination folder
      final targetJson = File(
        p.join(targetDirectory.path, 'vanithabodhini_export_$dateStr.json'),
      );
      await stagingJson.copy(targetJson.path);

      // 6. Atomically finalize zip file in destination folder
      final targetZip = File(
        p.join(targetDirectory.path, 'vanithabodhini_backup_$dateStr.zip'),
      );
      final targetTmpZip = File(
        p.join(targetDirectory.path, '.vanithabodhini_backup_$dateStr.zip.tmp'),
      );
      if (targetTmpZip.existsSync()) {
        targetTmpZip.deleteSync();
      }
      await stagingZip.copy(targetTmpZip.path);

      // Double-check destination temporary file before final rename
      verifyZipArchive(targetTmpZip);

      if (targetZip.existsSync()) {
        targetZip.deleteSync();
      }
      await targetTmpZip.rename(targetZip.path);

      // 7. Prune backups older than the retention limit
      await pruneOldBackups(targetDirectory, retentionLimit: retentionLimit);

      return BackupResult(
        zipFile: targetZip,
        jsonFile: targetJson,
        date: dateStr,
        timestamp: timestamp,
        zipSizeBytes: targetZip.lengthSync(),
      );
    } finally {
      if (stagingDir.existsSync()) {
        stagingDir.deleteSync(recursive: true);
      }
    }
  }

  /// Verifies that [zipFile] is in good condition, containing valid entries
  /// that pass CRC32 and extraction checks.
  void verifyZipArchive(File zipFile) {
    if (!zipFile.existsSync()) {
      throw StateError('Backup zip file does not exist: ${zipFile.path}');
    }
    final bytes = zipFile.readAsBytesSync();
    if (bytes.isEmpty) {
      throw StateError('Backup zip file is empty.');
    }

    final decoder = ZipDecoder();
    final archive = decoder.decodeBytes(bytes, verify: true, throwOnError: true);

    final fileNames = archive.files.map((e) => e.name).toSet();
    if (!fileNames.contains('vanithabodhini.sqlite')) {
      throw StateError('Zip archive is missing vanithabodhini.sqlite database.');
    }
    if (!fileNames.contains('data_export.json')) {
      throw StateError('Zip archive is missing data_export.json export.');
    }

    for (final entry in archive.files) {
      if (entry.isFile) {
        if (entry.content.isEmpty) {
          throw StateError('Archive entry ${entry.name} has no valid content.');
        }
      }
    }
  }

  void _verifySqliteSnapshot(File dbFile) {
    final checkDb = sqlite.sqlite3.open(dbFile.path);
    try {
      final rows = checkDb.select('PRAGMA quick_check');
      if (rows.isEmpty || rows.first['quick_check'] != 'ok') {
        throw StateError(
          'SQLite snapshot failed integrity check: ${rows.isNotEmpty ? rows.first : "no result"}',
        );
      }
    } finally {
      checkDb.close();
    }
  }

  /// Prunes backups in [directory] keeping only the most recent [retentionLimit] daily backup dates.
  Future<int> pruneOldBackups(
    Directory directory, {
    int retentionLimit = 30,
  }) async {
    if (!directory.existsSync() || retentionLimit <= 0) return 0;

    final entities = directory.listSync();
    final dateToZipFiles = <String, List<File>>{};
    final dateToJsonFiles = <String, List<File>>{};

    for (final entity in entities) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);

      final zipMatch = _backupZipRegex.firstMatch(name);
      if (zipMatch != null) {
        final date = zipMatch.group(1)!;
        dateToZipFiles.putIfAbsent(date, () => []).add(entity);
        continue;
      }

      final jsonMatch = _backupJsonRegex.firstMatch(name);
      if (jsonMatch != null) {
        final date = jsonMatch.group(1)!;
        dateToJsonFiles.putIfAbsent(date, () => []).add(entity);
      }
    }

    final allDates = {...dateToZipFiles.keys, ...dateToJsonFiles.keys}.toList()
      ..sort((a, b) => b.compareTo(a)); // Descending order (newest first)

    if (allDates.length <= retentionLimit) {
      return 0;
    }

    final datesToDelete = allDates.sublist(retentionLimit);
    var deletedCount = 0;

    for (final date in datesToDelete) {
      for (final zip in dateToZipFiles[date] ?? const <File>[]) {
        try {
          if (zip.existsSync()) {
            zip.deleteSync();
            deletedCount++;
          }
        } catch (_) {}
      }
      for (final json in dateToJsonFiles[date] ?? const <File>[]) {
        try {
          if (json.existsSync()) {
            json.deleteSync();
            deletedCount++;
          }
        } catch (_) {}
      }
    }

    return deletedCount;
  }

  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
