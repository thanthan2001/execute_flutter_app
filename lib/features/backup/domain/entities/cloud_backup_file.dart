class CloudBackupFile {
  final String id;
  final String name;
  final DateTime? createdTime;
  final int? size;

  const CloudBackupFile({
    required this.id,
    required this.name,
    this.createdTime,
    this.size,
  });
}
