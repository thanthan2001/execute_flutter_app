class CloudBackupResult {
  final bool success;
  final String? message;

  const CloudBackupResult({
    required this.success,
    this.message,
  });

  factory CloudBackupResult.success() =>
      const CloudBackupResult(success: true);

  factory CloudBackupResult.failure(String message) =>
      CloudBackupResult(success: false, message: message);
}
