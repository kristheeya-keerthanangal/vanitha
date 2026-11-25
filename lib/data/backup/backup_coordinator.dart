import 'dart:io';
import 'dart:ui' show AppExitResponse, AppExitType;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show ServicesBinding;

import 'backup_settings.dart';
import 'backup_settings_repository.dart';
import 'database_backup_service.dart';

class BackupCoordinator extends ChangeNotifier {
  BackupCoordinator({
    required this.backupService,
    required this.settingsRepository,
    Future<String?> Function()? directoryPicker,
    Future<void> Function()? appExitHandler,
    DateTime Function()? nowProvider,
  })  : _directoryPicker = directoryPicker ?? getDirectoryPath,
        _appExitHandler = appExitHandler ?? _defaultExitHandler,
        _nowProvider = nowProvider ?? DateTime.now {
    _initSettings();
  }

  final DatabaseBackupService backupService;
  final BackupSettingsRepository settingsRepository;
  final Future<String?> Function() _directoryPicker;
  final Future<void> Function() _appExitHandler;
  final DateTime Function() _nowProvider;

  BackupSettings _settings = const BackupSettings();
  BackupSettings get settings => _settings;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _isBackingUp = false;
  bool get isBackingUp => _isBackingUp;

  bool _isExitPending = false;
  bool get isExitPending => _isExitPending;

  String? _progressMessage;
  String? get progressMessage => _progressMessage;

  String? _lastError;
  String? get lastError => _lastError;

  String? _lastSuccessMessage;
  String? get lastSuccessMessage => _lastSuccessMessage;

  static Future<void> _defaultExitHandler() async {
    await ServicesBinding.instance.exitApplication(AppExitType.required);
  }

  Future<void> _initSettings() async {
    _settings = await settingsRepository.loadSettings();
    _isInitialized = true;
    notifyListeners();
  }

  /// Checks if a daily backup is due on startup, and runs it if required.
  Future<void> checkAndRunDailyBackup() async {
    if (!_isInitialized) {
      await _initSettings();
    }
    final now = _nowProvider();
    if (settingsRepository.shouldRunDailyBackup(_settings, now)) {
      await runBackup(isStartup: true);
    }
  }

  /// Triggers a backup (either manual or automatic).
  Future<bool> runBackup({bool isStartup = false}) async {
    if (_isBackingUp) return false;
    if (!_settings.isConfigured) {
      _lastError = 'No backup folder selected. Please choose a folder first.';
      notifyListeners();
      return false;
    }

    final targetDir = Directory(_settings.backupDirectory!);
    _isBackingUp = true;
    _progressMessage = isStartup
        ? 'Running daily backup...'
        : 'Backing up database and export...';
    _lastError = null;
    _lastSuccessMessage = null;
    notifyListeners();

    final now = _nowProvider();
    var success = false;

    try {
      final result = await backupService.createBackup(
        targetDirectory: targetDir,
        now: now,
        retentionLimit: _settings.retentionDays,
      );

      _settings = _settings.copyWith(
        lastBackupDate: result.date,
        lastBackupTimestamp: result.timestamp.toIso8601String(),
        lastBackupStatus: 'success',
        clearError: true,
      );
      await settingsRepository.saveSettings(_settings);
      _lastSuccessMessage = 'Backup completed successfully.';
      success = true;
    } catch (e) {
      final errorMsg = 'Backup failed: $e';
      _lastError = errorMsg;
      _settings = _settings.copyWith(
        lastBackupStatus: 'failed',
        lastBackupError: errorMsg,
      );
      try {
        await settingsRepository.saveSettings(_settings);
      } catch (_) {}
      success = false;
    } finally {
      _isBackingUp = false;
      _progressMessage = null;
      notifyListeners();

      // If an exit request arrived while backing up, proceed with the exit now.
      if (_isExitPending) {
        await _appExitHandler();
      }
    }

    return success;
  }

  /// Handles desktop window close requests.
  ///
  /// If a backup is actively in progress, intercepts the exit by returning
  /// [AppExitResponse.cancel], displays a blocking message, and defers
  /// termination until the backup finishes.
  Future<AppExitResponse> handleExitRequest() async {
    if (!_isBackingUp) {
      return AppExitResponse.exit;
    }

    _isExitPending = true;
    notifyListeners();
    return AppExitResponse.cancel;
  }

  /// Allows the user to select a directory (local folder, Google Drive, OneDrive).
  Future<void> selectBackupDirectory() async {
    final selected = await _directoryPicker();
    if (selected != null && selected.trim().isNotEmpty) {
      _settings = _settings.copyWith(backupDirectory: selected.trim());
      await settingsRepository.saveSettings(_settings);
      _lastError = null;
      notifyListeners();
    }
  }

  /// Toggles whether daily backup is enabled.
  Future<void> setEnabled(bool enabled) async {
    _settings = _settings.copyWith(isEnabled: enabled);
    await settingsRepository.saveSettings(_settings);
    notifyListeners();
  }
}
