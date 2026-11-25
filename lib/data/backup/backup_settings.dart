class BackupSettings {
  const BackupSettings({
    this.backupDirectory,
    this.lastBackupDate,
    this.lastBackupTimestamp,
    this.lastBackupStatus,
    this.lastBackupError,
    this.isEnabled = true,
    this.retentionDays = 30,
  });

  final String? backupDirectory;
  final String? lastBackupDate;
  final String? lastBackupTimestamp;
  final String? lastBackupStatus;
  final String? lastBackupError;
  final bool isEnabled;
  final int retentionDays;

  bool get isConfigured =>
      backupDirectory != null && backupDirectory!.trim().isNotEmpty;

  BackupSettings copyWith({
    String? backupDirectory,
    String? lastBackupDate,
    String? lastBackupTimestamp,
    String? lastBackupStatus,
    String? lastBackupError,
    bool? isEnabled,
    int? retentionDays,
    bool clearBackupDirectory = false,
    bool clearError = false,
  }) {
    return BackupSettings(
      backupDirectory: clearBackupDirectory
          ? null
          : (backupDirectory ?? this.backupDirectory),
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      lastBackupTimestamp: lastBackupTimestamp ?? this.lastBackupTimestamp,
      lastBackupStatus: lastBackupStatus ?? this.lastBackupStatus,
      lastBackupError:
          clearError ? null : (lastBackupError ?? this.lastBackupError),
      isEnabled: isEnabled ?? this.isEnabled,
      retentionDays: retentionDays ?? this.retentionDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backupDirectory': backupDirectory,
      'lastBackupDate': lastBackupDate,
      'lastBackupTimestamp': lastBackupTimestamp,
      'lastBackupStatus': lastBackupStatus,
      'lastBackupError': lastBackupError,
      'isEnabled': isEnabled,
      'retentionDays': retentionDays,
    };
  }

  factory BackupSettings.fromJson(Map<String, dynamic> json) {
    return BackupSettings(
      backupDirectory: json['backupDirectory'] as String?,
      lastBackupDate: json['lastBackupDate'] as String?,
      lastBackupTimestamp: json['lastBackupTimestamp'] as String?,
      lastBackupStatus: json['lastBackupStatus'] as String?,
      lastBackupError: json['lastBackupError'] as String?,
      isEnabled: json['isEnabled'] as bool? ?? true,
      retentionDays: json['retentionDays'] as int? ?? 30,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupSettings &&
          runtimeType == other.runtimeType &&
          backupDirectory == other.backupDirectory &&
          lastBackupDate == other.lastBackupDate &&
          lastBackupTimestamp == other.lastBackupTimestamp &&
          lastBackupStatus == other.lastBackupStatus &&
          lastBackupError == other.lastBackupError &&
          isEnabled == other.isEnabled &&
          retentionDays == other.retentionDays;

  @override
  int get hashCode => Object.hash(
    backupDirectory,
    lastBackupDate,
    lastBackupTimestamp,
    lastBackupStatus,
    lastBackupError,
    isEnabled,
    retentionDays,
  );
}
