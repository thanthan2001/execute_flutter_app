import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../dashboard/data/datasources/dashboard_local_data_source.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../../domain/usecases/generate_pending_transactions_usecase.dart';

/// Service xử lý background tasks cho recurring transactions
/// - Chạy khi app mở
/// - Kiểm tra recurring transactions đến hạn
/// - Sinh transactions mới
/// - Lưu vào database
class RecurringTransactionService {
  final GeneratePendingTransactionsUseCase generatePendingTransactionsUseCase;
  final DashboardLocalDataSource dashboardLocalDataSource;

  RecurringTransactionService({
    required this.generatePendingTransactionsUseCase,
    required this.dashboardLocalDataSource,
  });

  /// Chạy service để generate pending transactions
  /// Gọi method này khi:
  /// - App khởi động (main.dart)
  /// - User mở RecurringTransactionPage
  /// - Sau khi tạo/update recurring transaction
  Future<Either<Failure, int>> processRecurringTransactions() async {
    try {
      // 1. Generate pending transactions
      final result = await generatePendingTransactionsUseCase(NoParams());

      return result.fold(
        (failure) => Left(failure),
        (generatedTransactions) async {
          if (generatedTransactions.isEmpty) {
            return const Right(0); // Không có transaction nào được tạo
          }

          // 2. Lưu transactions vào database
          int successCount = 0;
          for (final transaction in generatedTransactions) {
            try {
              final model = TransactionModel.fromEntity(transaction);
              await dashboardLocalDataSource.addTransaction(model);
              successCount++;
            } catch (e) {
              // Log error nhưng tiếp tục với transactions khác
              print('❌ Failed to save transaction: $e');
            }
          }

          print(
            '✅ RecurringTransactionService: Generated $successCount transactions',
          );

          return Right(successCount);
        },
      );
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Không thể xử lý giao dịch định kỳ: $e',
        ),
      );
    }
  }

  /// Check và log các recurring transactions cần được generate
  /// (Useful cho debugging)
  Future<void> checkPendingRecurring() async {
    final result = await generatePendingTransactionsUseCase(NoParams());

    result.fold(
      (failure) {
        print('❌ Failed to check pending recurring: ${failure.toString()}');
      },
      (transactions) {
        if (transactions.isEmpty) {
          print('✅ No pending recurring transactions');
        } else {
          print('📋 Found ${transactions.length} pending recurring transactions');
          for (final transaction in transactions) {
            print('  - ${transaction.description}: ${transaction.amount}đ');
          }
        }
      },
    );
  }
}
