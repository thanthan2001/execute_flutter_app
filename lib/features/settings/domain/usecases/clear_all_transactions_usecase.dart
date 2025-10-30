import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../dashboard/domain/repositories/dashboard_repository.dart';

/// UseCase để xóa toàn bộ dữ liệu giao dịch
class ClearAllTransactionsUseCase implements UseCase<void, NoParams> {
  final DashboardRepository repository;

  ClearAllTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.clearAllTransactions();
  }
}
