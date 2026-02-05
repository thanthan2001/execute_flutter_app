import 'dart:io';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/backup_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class ExportDataParams extends Equatable {
  final String outputPath;

  const ExportDataParams({required this.outputPath});

  @override
  List<Object?> get props => [outputPath];
}

class ExportDataUseCase implements UseCase<File, ExportDataParams> {
  final BackupRepository repository;

  ExportDataUseCase(this.repository);

  @override
  Future<Either<Failure, File>> call(ExportDataParams params) {
    return repository.exportData(outputPath: params.outputPath);
  }
}
