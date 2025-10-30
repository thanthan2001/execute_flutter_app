import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../dashboard/domain/entities/category_entity.dart';
import '../repositories/transaction_repository.dart';

/// UseCase để lấy tất cả categories
class GetAllCategoriesUseCase
    implements UseCase<List<CategoryEntity>, NoParams> {
  final TransactionRepository repository;

  GetAllCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(NoParams params) async {
    return await repository.getAllCategories();
  }
}
