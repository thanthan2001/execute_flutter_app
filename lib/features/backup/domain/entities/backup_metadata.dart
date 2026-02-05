class BackupMetadata {
  final String appVersion;
  final int schemaVersion;
  final DateTime createdAt;

  const BackupMetadata({
    required this.appVersion,
    required this.schemaVersion,
    required this.createdAt,
  });

  factory BackupMetadata.fromJson(Map<String, dynamic> json) {
    return BackupMetadata(
      appVersion: json['appVersion'] as String,
      schemaVersion: json['schemaVersion'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appVersion': appVersion,
      'schemaVersion': schemaVersion,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
