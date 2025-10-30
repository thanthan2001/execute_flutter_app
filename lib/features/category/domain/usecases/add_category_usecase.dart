import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../dashboard/domain/entities/category_entity.dart';
import '../repositories/category_management_repository.dart';

/// UseCase để thêm category mới
class AddCategoryUseCase implements UseCase<void, AddCategoryParams> {
  final CategoryManagementRepository repository;

  AddCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddCategoryParams params) async {
    return await repository.addCategory(params.category);
  }
}

/// Parameters cho AddCategoryUseCase
class AddCategoryParams extends Equatable {
  final CategoryEntity category;

  const AddCategoryParams({required this.category});

  @override
  List<Object?> get props => [category];
}
