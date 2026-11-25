import 'dart:io';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Resolves the storage location for the application's SQLite database.
class DatabaseLocator {
  static const String appDirectoryName = 'VanithaBodhini';

  /// Resolves the Drift native options to configure the database path.
  ///
  /// On Windows, sets [DriftNativeOptions.databasePath] to use
  /// `%LOCALAPPDATA%\VanithaBodhini\<databaseName>.sqlite` with migration from
  /// the legacy `Documents` location if needed.
  /// On non-Windows platforms, returns null so Drift uses default behavior.
  static DriftNativeOptions? nativeOptions({
    String databaseName = 'vanithabodhini',
    bool? isWindowsOverride,
    Map<String, String>? environmentOverride,
    Future<Directory> Function()? documentsDirectoryLookup,
  }) {
    final isWindows = isWindowsOverride ?? Platform.isWindows;
    if (!isWindows) return null;

    return DriftNativeOptions(
      databasePath: () => resolveWindowsDatabasePath(
        databaseName: databaseName,
        environment: environmentOverride,
        documentsDirectoryLookup: documentsDirectoryLookup,
      ),
    );
  }

  /// Resolves the Windows database path, creating directories and migrating
  /// any existing legacy database from Documents if necessary.
  static Future<String> resolveWindowsDatabasePath({
    String databaseName = 'vanithabodhini',
    Map<String, String>? environment,
    Future<Directory> Function()? documentsDirectoryLookup,
  }) async {
    final env = environment ?? Platform.environment;
    final baseDir = resolveWindowsBaseDir(env);
    final targetDir = Directory(p.join(baseDir, appDirectoryName));

    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }

    final targetFile = File(p.join(targetDir.path, '$databaseName.sqlite'));

    if (!targetFile.existsSync()) {
      await _migrateLegacyDatabase(
        targetFile: targetFile,
        databaseName: databaseName,
        environment: env,
        documentsDirectoryLookup: documentsDirectoryLookup,
      );
    }

    return targetFile.path;
  }

  static String resolveWindowsBaseDir(Map<String, String> env) {
    final localAppData = env['LOCALAPPDATA'];
    if (localAppData != null && localAppData.trim().isNotEmpty) {
      return localAppData.trim();
    }

    final appData = env['APPDATA'];
    if (appData != null && appData.trim().isNotEmpty) {
      return appData.trim();
    }

    final userProfile = env['USERPROFILE'];
    if (userProfile != null && userProfile.trim().isNotEmpty) {
      return p.join(userProfile.trim(), 'AppData', 'Local');
    }

    return Directory.current.path;
  }

  static Future<void> _migrateLegacyDatabase({
    required File targetFile,
    required String databaseName,
    required Map<String, String> environment,
    Future<Directory> Function()? documentsDirectoryLookup,
  }) async {
    Directory? docsDir;
    if (documentsDirectoryLookup != null) {
      try {
        docsDir = await documentsDirectoryLookup();
      } catch (_) {}
    } else {
      try {
        docsDir = await getApplicationDocumentsDirectory();
      } catch (_) {
        final userProfile = environment['USERPROFILE'];
        if (userProfile != null && userProfile.trim().isNotEmpty) {
          docsDir = Directory(p.join(userProfile.trim(), 'Documents'));
        }
      }
    }

    if (docsDir == null || !docsDir.existsSync()) return;

    final legacyFile = File(p.join(docsDir.path, '$databaseName.sqlite'));
    if (!legacyFile.existsSync()) return;

    // Migrate main database file
    legacyFile.copySync(targetFile.path);

    // Safely migrate auxiliary SQLite WAL and SHM files if present
    for (final ext in ['-wal', '-shm']) {
      final legacyAux = File('${legacyFile.path}$ext');
      if (legacyAux.existsSync()) {
        legacyAux.copySync('${targetFile.path}$ext');
        try {
          legacyAux.renameSync('${legacyAux.path}.migrated_backup');
        } catch (_) {}
      }
    }

    // Rename legacy main database to preserve as backup
    try {
      legacyFile.renameSync('${legacyFile.path}.migrated_backup');
    } catch (_) {}
  }
}
