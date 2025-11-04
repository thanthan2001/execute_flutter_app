import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category_entity.dart';
import '../repositories/category_management_repository.dart';

/// UseCase để cập nhật category
class UpdateCategoryUseCase implements UseCase<void, UpdateCategoryParams> {
  final CategoryManagementRepository repository;

  UpdateCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateCategoryParams params) async {
    return await repository.updateCategory(params.category);
  }
}

/// Parameters cho UpdateCategoryUseCase
class UpdateCategoryParams extends Equatable {
  final CategoryEntity category;

  const UpdateCategoryParams({required this.category});

  @override
  List<Object?> get props => [category];
}
