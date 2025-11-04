import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/configs/app_colors.dart';
import 'category_local_data_source.dart';
import '../models/category_model.dart';

/// Helper class để khởi tạo categories mặc định
class CategoryMockData {
  /// Khởi tạo dữ liệu mẫu cho categories
  static Future<void> initDefaultCategories(
    CategoryLocalDataSource dataSource,
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
        colorValue: AppColors.red.value,
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

      // Categories cho thu nhập
      CategoryModel(
        id: 'salary',
        name: 'Lương',
        iconCodePoint: FontAwesomeIcons.moneyBill.codePoint,
        iconFontFamily: 'FontAwesomeSolid',
        iconFontPackage: 'font_awesome_flutter',
        colorValue: AppColors.green.value,
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
      CategoryModel(
        id: 'other',
        name: 'Khác',
        iconCodePoint: FontAwesomeIcons.ellipsis.codePoint,
        iconFontFamily: 'FontAwesomeSolid',
        iconFontPackage: 'font_awesome_flutter',
        colorValue: Colors.grey.value,
        type: 'both',
      ),
    ];

    for (var category in categories) {
      await dataSource.addCategory(category);
    }
  }
}
