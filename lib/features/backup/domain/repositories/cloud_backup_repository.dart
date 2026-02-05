import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cloud_backup_file.dart';
import '../entities/cloud_backup_result.dart';

abstract class CloudBackupRepository {
  Future<Either<Failure, CloudBackupResult>> uploadBackup(File file);
  Future<Either<Failure, List<CloudBackupFile>>> listBackups();
  Future<Either<Failure, File>> downloadBackup(String id);
}
