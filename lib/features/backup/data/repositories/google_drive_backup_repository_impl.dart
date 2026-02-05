import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cloud_backup_file.dart';
import '../../domain/entities/cloud_backup_result.dart';
import '../../domain/repositories/cloud_backup_repository.dart';
import '../datasources/google_drive/google_drive_data_source.dart';

class GoogleDriveBackupRepositoryImpl implements CloudBackupRepository {
  final GoogleDriveDataSource dataSource;

  GoogleDriveBackupRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, CloudBackupResult>> uploadBackup(File file) async {
    try {
      await dataSource.uploadFile(file);
      return Right(CloudBackupResult.success());
    } catch (e) {
      return Left(CacheFailure(message: 'Upload thất bại: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CloudBackupFile>>> listBackups() async {
    try {
      final files = await dataSource.listFiles();
      final result = files
          .map(
            (file) => CloudBackupFile(
              id: file.id ?? '',
              name: file.name ?? 'backup.json',
              createdTime: file.createdTime,
              size: file.size != null ? int.tryParse(file.size!) : null,
            ),
          )
          .toList();

      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: 'Không thể lấy danh sách backup: $e'));
    }
  }

  @override
  Future<Either<Failure, File>> downloadBackup(String id) async {
    try {
      final file = await dataSource.downloadFile(id);
      return Right(file);
    } catch (e) {
      return Left(CacheFailure(message: 'Không thể tải backup: $e'));
    }
  }
}
