import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dashboard_local_data_source.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

/// Helper class để tạo mock data cho Dashboard
class DashboardMockData {
  /// Khởi tạo dữ liệu mẫu cho categories
  static Future<void> initMockCategories(
    DashboardLocalDataSource dataSource,
  ) async {
    final categories = [
      // Categories cho chi tiêu
      CategoryModel(
        id: 'food',
        name: 'Ăn uống',
        iconCodePoint: FontAwesomeIcons.utensils.codePoint,
        iconFontFamily: 'FontAwesomeSolid',
        iconFontPackage: 'font_awesome_flutter',
        colorValue: Colors.orange.value,
        type: 'expense',
      ),
      CategoryModel(
        id: 'transport',
        name: 'Di chuyển',
        iconCodePoint: FontAwesomeIcons.car.codePoint,
        iconFontFamily: 'FontAwesomeSolid',
        iconFontPackage: 'font_awesome_flutter',
        colorValue: Colors.blue.value,
        type: 'expense',
      ),
      CategoryModel(
        id: 'shopping',
        name: 'Mua sắm',
        iconCodePoint: FontAwesomeIcons.shoppingBag.codePoint,
        iconFontFamily: 'FontAwesomeSolid',
        iconFontPackage: 'font_awesome_flutter',
        colorValue: Colors.purple.value,
        type: 'expense',
      ),
      CategoryModel(
        id: 'entertainment',
        name: 'Giải trí',
        iconCodePoint: FontAwesomeIcons.gamepad.codePoint,
        iconFontFamily: 'FontAwesomeSolid',
        iconFontPackage: 'font_awesome_flutter',
        colorValue: Colors.pink.value,
        type: 'expense',
      ),
      CategoryModel(
        id: 'health',
        name: 'Sức khỏe',
        iconCodePoint: FontAwesomeIcons.heartPulse.codePoint,
        iconFontFamily: 'FontAwesomeSolid',
        iconFontPackage: 'font_awesome_flutter',
        colorValue: Colors.red.value,
        type: 'expense',
      ),
      CategoryModel(
        id: 'education',
        name: 'Giáo dục',
        iconCodePoint: FontAwesomeIcons.graduationCap.codePoint,
        iconFontFamily: 'FontAwesomeSolid',
        iconFontPackage: 'font_awesome_flutter',
        colorValue: Colors.teal.value,
        type: 'expense',
      ),
      CategoryModel(
        id: 'other',
        name: 'Khác',
        iconCodePoint: FontAwesomeIcons.ellipsis.codePoint,
        iconFontFamily: 'FontAwesomeSolid',
        iconFontPackage: 'font_awesome_flutter',
        colorValue: Colors.grey.value,
        type: 'both',
      ),

      // Categories cho thu nhập
      CategoryModel(
        id: 'salary',
        name: 'Lương',
        iconCodePoint: FontAwesomeIcons.moneyBill.codePoint,
        iconFontFamily: 'FontAwesomeSolid',
        iconFontPackage: 'font_awesome_flutter',
        colorValue: Colors.green.value,
        type: 'income',
      ),
      CategoryModel(
        id: 'bonus',
        name: 'Thưởng',
        iconCodePoint: FontAwesomeIcons.gift.codePoint,
        iconFontFamily: 'FontAwesomeSolid',
        iconFontPackage: 'font_awesome_flutter',
        colorValue: Colors.lightGreen.value,
        type: 'income',
      ),
      CategoryModel(
        id: 'investment',
        name: 'Đầu tư',
        iconCodePoint: FontAwesomeIcons.chartLine.codePoint,
        iconFontFamily: 'FontAwesomeSolid',
        iconFontPackage: 'font_awesome_flutter',
        colorValue: Colors.indigo.value,
        type: 'income',
      ),
    ];

    for (var category in categories) {
      await dataSource.addCategory(category);
    }
  }

  /// Khởi tạo dữ liệu mẫu cho transactions
  static Future<void> initMockTransactions(
    DashboardLocalDataSource dataSource,
  ) async {
    final now = DateTime.now();

    final transactions = [
      // Tháng hiện tại
      TransactionModel(
        id: 't1',
        amount: 50000,
        description: 'Ăn sáng',
        date: now.subtract(const Duration(days: 1)),
        categoryId: 'food',
        type: 'expense',
        note: 'Phở bò',
      ),
      TransactionModel(
        id: 't2',
        amount: 200000,
        description: 'Xăng xe',
        date: now.subtract(const Duration(days: 2)),
        categoryId: 'transport',
        type: 'expense',
        note: 'Shell',
      ),
      TransactionModel(
        id: 't3',
        amount: 15000000,
        description: 'Lương tháng',
        date: DateTime(now.year, now.month, 5),
        categoryId: 'salary',
        type: 'income',
        note: 'Lương tháng ${now.month}',
      ),
      TransactionModel(
        id: 't4',
        amount: 500000,
        description: 'Mua quần áo',
        date: now.subtract(const Duration(days: 3)),
        categoryId: 'shopping',
        type: 'expense',
      ),
      TransactionModel(
        id: 't5',
        amount: 300000,
        description: 'Xem phim',
        date: now.subtract(const Duration(days: 5)),
        categoryId: 'entertainment',
        type: 'expense',
        note: 'CGV Vincom',
      ),
      TransactionModel(
        id: 't6',
        amount: 150000,
        description: 'Ăn trưa',
        date: now.subtract(const Duration(days: 4)),
        categoryId: 'food',
        type: 'expense',
      ),

      // Tháng trước
      TransactionModel(
        id: 't7',
        amount: 14500000,
        description: 'Lương tháng trước',
        date: DateTime(now.year, now.month - 1, 5),
        categoryId: 'salary',
        type: 'income',
      ),
      TransactionModel(
        id: 't8',
        amount: 800000,
        description: 'Tiền điện',
        date: DateTime(now.year, now.month - 1, 10),
        categoryId: 'other',
        type: 'expense',
        note: 'EVN HANOI',
      ),
      TransactionModel(
        id: 't9',
        amount: 1200000,
        description: 'Mua sách',
        date: DateTime(now.year, now.month - 1, 15),
        categoryId: 'education',
        type: 'expense',
      ),
      TransactionModel(
        id: 't10',
        amount: 2000000,
        description: 'Thưởng dự án',
        date: DateTime(now.year, now.month - 1, 20),
        categoryId: 'bonus',
        type: 'income',
      ),

      // 2 tháng trước
      TransactionModel(
        id: 't11',
        amount: 14000000,
        description: 'Lương',
        date: DateTime(now.year, now.month - 2, 5),
        categoryId: 'salary',
        type: 'income',
      ),
      TransactionModel(
        id: 't12',
        amount: 600000,
        description: 'Khám bệnh',
        date: DateTime(now.year, now.month - 2, 12),
        categoryId: 'health',
        type: 'expense',
        note: 'Bệnh viện Bạch Mai',
      ),
    ];

    for (var transaction in transactions) {
      await dataSource.addTransaction(transaction);
    }
  }
}
