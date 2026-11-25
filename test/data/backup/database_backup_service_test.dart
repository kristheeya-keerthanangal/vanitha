import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/backup/database_backup_service.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';

void main() {
  late Directory tempDir;
  late AppDatabase database;
  late SubscriberRepository subscriberRepository;
  late DatabaseBackupService backupService;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('db_backup_service_test_');
    final dbFile = File(p.join(tempDir.path, 'source_test.sqlite'));
    database = AppDatabase(NativeDatabase(dbFile));
    subscriberRepository = SubscriberRepository(database);
    backupService = DatabaseBackupService(
      database: database,
      subscriberRepository: subscriberRepository,
    );

    // Seed test data
    await database.into(database.subscribers).insert(
          SubscribersCompanion.insert(
            name: 'Priya Sharma',
            email: const drift.Value('priya@example.com'),
            phone: const drift.Value('9876543210'),
            postalAddress: const drift.Value('123 MG Road'),
            postalCode: const drift.Value('560001'),
          ),
        );
    final subscriber = await database.select(database.subscribers).getSingle();
    await database.into(database.subscriptions).insert(
          SubscriptionsCompanion.insert(
            subscriberId: subscriber.id,
            edition: 'offline',
            planType: 'annual',
            durationYears: 1,
            startDate: '2026-01-01',
            expiryDate: '2026-12-31',
          ),
        );
    final officeId = await database.into(database.postalOffices).insert(
          PostalOfficesCompanion.insert(
            name: 'Kannur RMS',
            isActive: const drift.Value(true),
          ),
        );
    await database.into(database.postalOfficeRules).insert(
          PostalOfficeRulesCompanion.insert(
            postalOfficeId: officeId,
            operation: 'include',
            matchMethod: 'prefix',
            startValue: '670',
          ),
        );
  });

  tearDown(() async {
    await database.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('DatabaseBackupService', () {
    test('creates consistent SQLite snapshot, JSON export, and verified zip archive', () async {
      final backupDir = Directory(p.join(tempDir.path, 'backup_target'));
      final fixedDate = DateTime(2026, 11, 24, 10, 30);

      final result = await backupService.createBackup(
        targetDirectory: backupDir,
        now: fixedDate,
      );

      expect(result.date, '2026-11-24');
      expect(result.timestamp, fixedDate);
      expect(result.zipFile.existsSync(), isTrue);
      expect(result.jsonFile.existsSync(), isTrue);
      expect(result.zipSizeBytes, greaterThan(0));

      expect(
        p.basename(result.zipFile.path),
        'vanithabodhini_backup_2026-11-24.zip',
      );
      expect(
        p.basename(result.jsonFile.path),
        'vanithabodhini_export_2026-11-24.json',
      );

      // Verify standalone JSON export
      final jsonString = result.jsonFile.readAsStringSync();
      expect(jsonString, contains('Priya Sharma'));
      expect(jsonString, contains('123 MG Road'));
      expect(jsonString, contains('560001'));
      expect(jsonString, contains('Kannur RMS'));
      expect(jsonString, contains('670'));

      // Verify zip archive contents
      final zipBytes = result.zipFile.readAsBytesSync();
      final decoder = ZipDecoder();
      final archive = decoder.decodeBytes(zipBytes, verify: true, throwOnError: true);

      final entryNames = archive.files.map((e) => e.name).toSet();
      expect(entryNames, containsAll(['vanithabodhini.sqlite', 'data_export.json']));

      // Extract and verify SQLite file inside the zip
      final sqliteEntry = archive.files.firstWhere((e) => e.name == 'vanithabodhini.sqlite');
      final extractedDbFile = File(p.join(tempDir.path, 'extracted.sqlite'))
        ..writeAsBytesSync(sqliteEntry.content as List<int>);

      final checkDb = sqlite.sqlite3.open(extractedDbFile.path);
      try {
        final rows = checkDb.select('SELECT name, postal_address FROM subscribers');
        expect(rows.length, 1);
        expect(rows.first['name'], 'Priya Sharma');
        expect(rows.first['postal_address'], '123 MG Road');

        final officeRows = checkDb.select('SELECT name FROM postal_offices');
        expect(officeRows.length, 1);
        expect(officeRows.first['name'], 'Kannur RMS');

        final integrity = checkDb.select('PRAGMA quick_check');
        expect(integrity.first['quick_check'], 'ok');
      } finally {
        checkDb.close();
      }
    });

    test('verifyZipArchive throws when archive is corrupt or missing expected files', () {
      final nonExistent = File(p.join(tempDir.path, 'missing.zip'));
      expect(
        () => backupService.verifyZipArchive(nonExistent),
        throwsA(isA<StateError>()),
      );

      final emptyFile = File(p.join(tempDir.path, 'empty.zip'))..writeAsBytesSync([]);
      expect(
        () => backupService.verifyZipArchive(emptyFile),
        throwsA(isA<StateError>()),
      );

      final corruptFile = File(p.join(tempDir.path, 'corrupt.zip'))
        ..writeAsBytesSync([1, 2, 3, 4, 5]);
      expect(
        () => backupService.verifyZipArchive(corruptFile),
        throwsA(anything),
      );

      // Zip with missing sqlite file
      final partialZip = File(p.join(tempDir.path, 'partial.zip'));
      final encoder = ZipFileEncoder();
      encoder.create(partialZip.path);
      final dummyFile = File(p.join(tempDir.path, 'dummy.txt'))..writeAsStringSync('dummy');
      encoder.addFile(dummyFile, 'dummy.txt');
      encoder.close();

      expect(
        () => backupService.verifyZipArchive(partialZip),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('missing vanithabodhini.sqlite'),
        )),
      );
    });

    test('pruneOldBackups retains only the 30 most recent daily backups', () async {
      final targetDir = Directory(p.join(tempDir.path, 'retention_test'))
        ..createSync();

      // Create 35 daily backups (from day 01 to day 35)
      for (var day = 1; day <= 35; day++) {
        final dayStr = day.toString().padLeft(2, '0');
        final date = '2026-01-$dayStr';
        File(p.join(targetDir.path, 'vanithabodhini_backup_$date.zip'))
            .writeAsStringSync('zip_$date');
        File(p.join(targetDir.path, 'vanithabodhini_export_$date.json'))
            .writeAsStringSync('json_$date');
      }

      // Add an unrelated user file
      final unrelatedFile = File(p.join(targetDir.path, 'notes.txt'))
        ..writeAsStringSync('do not delete');

      final deletedCount = await backupService.pruneOldBackups(
        targetDir,
        retentionLimit: 30,
      );

      // 5 oldest dates pruned * 2 files each (zip + json) = 10 files
      expect(deletedCount, 10);

      // Days 01 through 05 should be deleted
      for (var day = 1; day <= 5; day++) {
        final dayStr = day.toString().padLeft(2, '0');
        final date = '2026-01-$dayStr';
        expect(
          File(p.join(targetDir.path, 'vanithabodhini_backup_$date.zip')).existsSync(),
          isFalse,
        );
        expect(
          File(p.join(targetDir.path, 'vanithabodhini_export_$date.json')).existsSync(),
          isFalse,
        );
      }

      // Days 06 through 35 (the 30 most recent) must still exist
      for (var day = 6; day <= 35; day++) {
        final dayStr = day.toString().padLeft(2, '0');
        final date = '2026-01-$dayStr';
        expect(
          File(p.join(targetDir.path, 'vanithabodhini_backup_$date.zip')).existsSync(),
          isTrue,
        );
        expect(
          File(p.join(targetDir.path, 'vanithabodhini_export_$date.json')).existsSync(),
          isTrue,
        );
      }

      // Unrelated file must be preserved
      expect(unrelatedFile.existsSync(), isTrue);
    });
  });
}
