import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/backup_file_entity.dart';
import '../../domain/entities/backup_import_result.dart';
import '../../domain/entities/backup_metadata.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../../../category/data/models/category_model.dart';
import '../../../budget/data/models/budget_model.dart';
import '../../../recurring_transaction/data/models/recurring_transaction_model.dart';

class BackupRepositoryImpl implements BackupRepository {
  static const String _transactionsBox = 'transactions';
  static const String _categoriesBox = 'categories';
  static const String _budgetsBox = 'budgets';
  static const String _recurringBox = 'recurring_transactions';

  static const int _schemaVersion = 1;
  static const String _appVersion = '1.0.0+1';

  Future<Box<TransactionModel>> _getTransactionsBox() async {
    if (!Hive.isBoxOpen(_transactionsBox)) {
      return await Hive.openBox<TransactionModel>(_transactionsBox);
    }
    return Hive.box<TransactionModel>(_transactionsBox);
  }

  Future<Box<CategoryModel>> _getCategoriesBox() async {
    if (!Hive.isBoxOpen(_categoriesBox)) {
      return await Hive.openBox<CategoryModel>(_categoriesBox);
    }
    return Hive.box<CategoryModel>(_categoriesBox);
  }

  Future<Box<BudgetModel>> _getBudgetsBox() async {
    if (!Hive.isBoxOpen(_budgetsBox)) {
      return await Hive.openBox<BudgetModel>(_budgetsBox);
    }
    return Hive.box<BudgetModel>(_budgetsBox);
  }

  Future<Box<RecurringTransactionModel>> _getRecurringBox() async {
    if (!Hive.isBoxOpen(_recurringBox)) {
      return await Hive.openBox<RecurringTransactionModel>(_recurringBox);
    }
    return Hive.box<RecurringTransactionModel>(_recurringBox);
  }

  @override
  Future<Either<Failure, File>> exportData({String? outputPath}) async {
    try {
      final transactionsBox = await _getTransactionsBox();
      final categoriesBox = await _getCategoriesBox();
      final budgetsBox = await _getBudgetsBox();
      final recurringBox = await _getRecurringBox();

      final data = {
        'transactions': transactionsBox.values.map((e) => e.toJson()).toList(),
        'categories': categoriesBox.values.map((e) => e.toJson()).toList(),
        'budgets': budgetsBox.values.map((e) => e.toJson()).toList(),
        'recurring_transactions':
            recurringBox.values.map((e) => e.toJson()).toList(),
      };

      final backup = BackupFileEntity(
        metadata: BackupMetadata(
          appVersion: _appVersion,
          schemaVersion: _schemaVersion,
          createdAt: DateTime.now(),
        ),
        data: data,
      );

      final jsonString = jsonEncode(backup.toJson());

      // Nếu có outputPath và không rỗng (user chọn), dùng path đó
      // Nếu không (backup lên Drive), dùng app directory
      final File file;
      if (outputPath != null && outputPath.isNotEmpty) {
        file = File(outputPath);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
        file = File('${dir.path}/moni_backup_$timestamp.json');
      }
      
      await file.writeAsString(jsonString);

      return Right(file);
    } catch (e) {
      return Left(CacheFailure(message: 'Không thể export dữ liệu: $e'));
    }
  }

  @override
  Future<Either<Failure, BackupFileEntity>> readBackupFile(File file) async {
    try {
      final jsonString = await file.readAsString();
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final backup = BackupFileEntity.fromJson(jsonMap);
      return Right(backup);
    } catch (e) {
      return Left(CacheFailure(message: 'invalid_format'));
    }
  }

  @override
  Future<Either<Failure, BackupImportResult>> restoreData(
    BackupFileEntity backup,
    BackupImportMode mode,
  ) async {
    try {
      final transactionsBox = await _getTransactionsBox();
      final categoriesBox = await _getCategoriesBox();
      final budgetsBox = await _getBudgetsBox();
      final recurringBox = await _getRecurringBox();

      final transactions = (backup.data['transactions'] as List)
          .map((e) => TransactionModel.fromJson(e))
          .toList();
      final categories = (backup.data['categories'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
      final budgets = (backup.data['budgets'] as List)
          .map((e) => BudgetModel.fromJson(e))
          .toList();
      final recurrings = (backup.data['recurring_transactions'] as List)
          .map((e) => RecurringTransactionModel.fromJson(e))
          .toList();

      if (mode == BackupImportMode.replaceAll) {
        await transactionsBox.clear();
        await categoriesBox.clear();
        await budgetsBox.clear();
        await recurringBox.clear();
      }

      for (final model in transactions) {
        if (mode == BackupImportMode.merge &&
            transactionsBox.containsKey(model.id)) {
          continue;
        }
        await transactionsBox.put(model.id, model);
      }

      for (final model in categories) {
        if (mode == BackupImportMode.merge &&
            categoriesBox.containsKey(model.id)) {
          continue;
        }
        await categoriesBox.put(model.id, model);
      }

      for (final model in budgets) {
        if (mode == BackupImportMode.merge && budgetsBox.containsKey(model.id)) {
          continue;
        }
        await budgetsBox.put(model.id, model);
      }

      for (final model in recurrings) {
        if (mode == BackupImportMode.merge &&
            recurringBox.containsKey(model.id)) {
          continue;
        }
        await recurringBox.put(model.id, model);
      }

      return const Right(BackupImportResult.success());
    } catch (e) {
      return Left(CacheFailure(message: 'Không thể import dữ liệu: $e'));
    }
  }
}
