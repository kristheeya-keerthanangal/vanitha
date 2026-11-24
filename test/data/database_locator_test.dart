import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vanithabodhini/data/database_locator.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('db_locator_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('DatabaseLocator.nativeOptions', () {
    test('returns null for non-Windows platforms', () {
      final options = DatabaseLocator.nativeOptions(
        isWindowsOverride: false,
      );
      expect(options, isNull);
    });

    test('returns DriftNativeOptions with databasePath on Windows', () {
      final options = DatabaseLocator.nativeOptions(
        isWindowsOverride: true,
        environmentOverride: {'LOCALAPPDATA': tempDir.path},
      );
      expect(options, isNotNull);
      expect(options!.databasePath, isNotNull);
    });
  });

  group('DatabaseLocator.resolveWindowsDatabasePath', () {
    test('resolves target path using LOCALAPPDATA', () async {
      final localAppData = Directory(p.join(tempDir.path, 'LocalAppData'))
        ..createSync();

      final resolvedPath = await DatabaseLocator.resolveWindowsDatabasePath(
        databaseName: 'vanithabodhini',
        environment: {'LOCALAPPDATA': localAppData.path},
      );

      final expectedDir = p.join(localAppData.path, 'VanithaBodhini');
      expect(resolvedPath, p.join(expectedDir, 'vanithabodhini.sqlite'));
      expect(Directory(expectedDir).existsSync(), isTrue);
    });

    test('falls back to APPDATA when LOCALAPPDATA is absent', () async {
      final appData = Directory(p.join(tempDir.path, 'Roaming'))
        ..createSync();

      final resolvedPath = await DatabaseLocator.resolveWindowsDatabasePath(
        databaseName: 'vanithabodhini',
        environment: {'APPDATA': appData.path},
      );

      final expectedDir = p.join(appData.path, 'VanithaBodhini');
      expect(resolvedPath, p.join(expectedDir, 'vanithabodhini.sqlite'));
      expect(Directory(expectedDir).existsSync(), isTrue);
    });

    test('falls back to USERPROFILE\\AppData\\Local when both are absent', () async {
      final userProfile = Directory(p.join(tempDir.path, 'User'))
        ..createSync();

      final resolvedPath = await DatabaseLocator.resolveWindowsDatabasePath(
        databaseName: 'vanithabodhini',
        environment: {'USERPROFILE': userProfile.path},
      );

      final expectedDir = p.join(userProfile.path, 'AppData', 'Local', 'VanithaBodhini');
      expect(resolvedPath, p.join(expectedDir, 'vanithabodhini.sqlite'));
      expect(Directory(expectedDir).existsSync(), isTrue);
    });

    test('migrates existing legacy database, wal, and shm from Documents', () async {
      final localAppData = Directory(p.join(tempDir.path, 'LocalAppData'))
        ..createSync();
      final docsDir = Directory(p.join(tempDir.path, 'Documents'))
        ..createSync();

      final legacyDb = File(p.join(docsDir.path, 'vanithabodhini.sqlite'))
        ..writeAsStringSync('SQLITE_DATA');
      final legacyWal = File(p.join(docsDir.path, 'vanithabodhini.sqlite-wal'))
        ..writeAsStringSync('WAL_DATA');
      final legacyShm = File(p.join(docsDir.path, 'vanithabodhini.sqlite-shm'))
        ..writeAsStringSync('SHM_DATA');

      final resolvedPath = await DatabaseLocator.resolveWindowsDatabasePath(
        databaseName: 'vanithabodhini',
        environment: {'LOCALAPPDATA': localAppData.path},
        documentsDirectoryLookup: () async => docsDir,
      );

      final targetDb = File(resolvedPath);
      final targetWal = File('$resolvedPath-wal');
      final targetShm = File('$resolvedPath-shm');

      expect(targetDb.existsSync(), isTrue);
      expect(targetDb.readAsStringSync(), 'SQLITE_DATA');
      expect(targetWal.existsSync(), isTrue);
      expect(targetWal.readAsStringSync(), 'WAL_DATA');
      expect(targetShm.existsSync(), isTrue);
      expect(targetShm.readAsStringSync(), 'SHM_DATA');

      // Verify legacy files were renamed to backups
      expect(legacyDb.existsSync(), isFalse);
      expect(File('${legacyDb.path}.migrated_backup').existsSync(), isTrue);
      expect(File('${legacyWal.path}.migrated_backup').existsSync(), isTrue);
      expect(File('${legacyShm.path}.migrated_backup').existsSync(), isTrue);
    });

    test('does not overwrite existing target database if already present', () async {
      final localAppData = Directory(p.join(tempDir.path, 'LocalAppData'))
        ..createSync();
      final docsDir = Directory(p.join(tempDir.path, 'Documents'))
        ..createSync();

      final targetDir = Directory(p.join(localAppData.path, 'VanithaBodhini'))
        ..createSync();
      File(p.join(targetDir.path, 'vanithabodhini.sqlite'))
        .writeAsStringSync('NEW_DATA');

      final legacyDb = File(p.join(docsDir.path, 'vanithabodhini.sqlite'))
        ..writeAsStringSync('OLD_DATA');

      final resolvedPath = await DatabaseLocator.resolveWindowsDatabasePath(
        databaseName: 'vanithabodhini',
        environment: {'LOCALAPPDATA': localAppData.path},
        documentsDirectoryLookup: () async => docsDir,
      );

      expect(File(resolvedPath).readAsStringSync(), 'NEW_DATA');
      // Legacy file should not have been touched
      expect(legacyDb.existsSync(), isTrue);
      expect(legacyDb.readAsStringSync(), 'OLD_DATA');
      expect(File('${legacyDb.path}.migrated_backup').existsSync(), isFalse);
    });
  });
}
