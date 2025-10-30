import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/category_management_repository.dart';

/// UseCase để xóa category
class DeleteCategoryUseCase implements UseCase<void, DeleteCategoryParams> {
  final CategoryManagementRepository repository;

  DeleteCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteCategoryParams params) async {
    // Kiểm tra xem category có đang được sử dụng không
    final isInUseResult = await repository.isCategoryInUse(params.id);

    return isInUseResult.fold(
      (failure) => Left(failure),
      (isInUse) async {
        if (isInUse) {
          return const Left(
            CacheFailure(message: 'Không thể xóa nhóm đang được sử dụng'),
          );
        }
        return await repository.deleteCategory(params.id);
      },
    );
  }
}

/// Parameters cho DeleteCategoryUseCase
class DeleteCategoryParams extends Equatable {
  final String id;

  const DeleteCategoryParams({required this.id});

  @override
  List<Object?> get props => [id];
}
