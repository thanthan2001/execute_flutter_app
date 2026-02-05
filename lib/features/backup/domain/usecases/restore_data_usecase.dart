import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/backup_file_entity.dart';
import '../entities/backup_import_result.dart';
import '../repositories/backup_repository.dart';

class RestoreDataParams extends Equatable {
  final BackupFileEntity backup;
  final BackupImportMode mode;

  const RestoreDataParams({
    required this.backup,
    required this.mode,
  });

  @override
  List<Object> get props => [backup, mode];
}

class RestoreDataUseCase
    implements UseCase<BackupImportResult, RestoreDataParams> {
  final BackupRepository repository;

  RestoreDataUseCase(this.repository);

  @override
  Future<Either<Failure, BackupImportResult>> call(
    RestoreDataParams params,
  ) {
    return repository.restoreData(params.backup, params.mode);
  }
}
