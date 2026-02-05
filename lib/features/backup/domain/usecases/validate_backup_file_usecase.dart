import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/backup_file_entity.dart';
import '../repositories/backup_repository.dart';

class ValidateBackupFileParams extends Equatable {
  final File file;

  const ValidateBackupFileParams(this.file);

  @override
  List<Object> get props => [file.path];
}

class ValidateBackupFileUseCase
    implements UseCase<BackupFileEntity, ValidateBackupFileParams> {
  final BackupRepository repository;
  final int schemaVersion;

  ValidateBackupFileUseCase({
    required this.repository,
    this.schemaVersion = 1,
  });

  @override
  Future<Either<Failure, BackupFileEntity>> call(
    ValidateBackupFileParams params,
  ) async {
    final result = await repository.readBackupFile(params.file);
    return result.fold(
      (failure) => Left(failure),
      (backup) {
        final metadata = backup.metadata;
        final data = backup.data;

        if (metadata.schemaVersion != schemaVersion) {
          return Left(CacheFailure(message: 'incompatible_version'));
        }

        const requiredKeys = [
          'transactions',
          'categories',
          'budgets',
          'recurring_transactions',
        ];

        for (final key in requiredKeys) {
          if (!data.containsKey(key)) {
            return Left(CacheFailure(message: 'invalid_format'));
          }
        }

        return Right(backup);
      },
    );
  }
}
