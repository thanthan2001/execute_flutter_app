import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/backup_import_result.dart';
import '../repositories/backup_repository.dart';
import 'restore_data_usecase.dart';
import 'validate_backup_file_usecase.dart';

class ImportDataParams extends Equatable {
  final File file;
  final BackupImportMode mode;

  const ImportDataParams({
    required this.file,
    required this.mode,
  });

  @override
  List<Object> get props => [file.path, mode];
}

class ImportDataUseCase implements UseCase<BackupImportResult, ImportDataParams> {
  final ValidateBackupFileUseCase validateBackupFileUseCase;
  final RestoreDataUseCase restoreDataUseCase;

  ImportDataUseCase({
    required this.validateBackupFileUseCase,
    required this.restoreDataUseCase,
  });

  @override
  Future<Either<Failure, BackupImportResult>> call(
    ImportDataParams params,
  ) async {
    final validation = await validateBackupFileUseCase(
      ValidateBackupFileParams(params.file),
    );

    return await validation.fold(
      (failure) => Right(_mapFailureToResult(failure)),
      (backup) async {
        final restore = await restoreDataUseCase(
          RestoreDataParams(backup: backup, mode: params.mode),
        );
        return restore.fold(
          (failure) => Right(_mapFailureToResult(failure)),
          (result) => Right(result),
        );
      },
    );
  }

  BackupImportResult _mapFailureToResult(Failure failure) {
    if (failure is CacheFailure) {
      if (failure.message == 'invalid_format') {
        return const BackupImportResult.failure(
          BackupImportError.invalidFormat,
        );
      }
      if (failure.message == 'incompatible_version') {
        return const BackupImportResult.failure(
          BackupImportError.incompatibleVersion,
        );
      }
    }
    return const BackupImportResult.failure(BackupImportError.invalidFormat);
  }
}
