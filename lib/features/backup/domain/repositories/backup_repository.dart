import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/backup_file_entity.dart';
import '../entities/backup_import_result.dart';

enum BackupImportMode { replaceAll, merge }

abstract class BackupRepository {
  Future<Either<Failure, File>> exportData({String? outputPath});
  Future<Either<Failure, BackupFileEntity>> readBackupFile(File file);
  Future<Either<Failure, BackupImportResult>> restoreData(
    BackupFileEntity backup,
    BackupImportMode mode,
  );
}
