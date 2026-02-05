enum BackupImportError {
  invalidFormat,
  incompatibleVersion,
}

class BackupImportResult {
  final bool success;
  final BackupImportError? error;

  const BackupImportResult.success()
      : success = true,
        error = null;

  const BackupImportResult.failure(this.error) : success = false;
}
