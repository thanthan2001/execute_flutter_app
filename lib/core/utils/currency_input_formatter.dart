import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// TextInputFormatter để format số tiền theo định dạng Việt Nam
/// Ví dụ: 2000000 → 2.000.000
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'vi_VN');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Nếu text rỗng, return ngay
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Xóa tất cả dấu chấm và khoảng trắng
    String newText = newValue.text.replaceAll('.', '').replaceAll(' ', '');

    // Chỉ giữ lại số
    if (!RegExp(r'^\d+$').hasMatch(newText)) {
      return oldValue;
    }

    // Parse thành số
    final number = int.tryParse(newText);
    if (number == null) {
      return oldValue;
    }

    // Format lại với dấu chấm phân cách
    final formatted = _formatter.format(number);

    // Tính toán vị trí cursor mới
    final oldLength = oldValue.text.replaceAll('.', '').length;
    final newLength = newText.length;
    final diff = newLength - oldLength;

    int newOffset = newValue.selection.baseOffset;

    if (diff > 0) {
      // Thêm ký tự
      newOffset = newValue.selection.baseOffset;
    } else if (diff < 0) {
      // Xóa ký tự
      newOffset = newValue.selection.baseOffset;
    }

    // Đếm số dấu chấm trước cursor trong text mới
    int dotsBeforeCursor = 0;
    for (int i = 0; i < newOffset && i < formatted.length; i++) {
      if (formatted[i] == '.') {
        dotsBeforeCursor++;
      }
    }

    // Tính vị trí cursor trong text formatted
    final cursorPosition = newOffset + dotsBeforeCursor;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: cursorPosition.clamp(0, formatted.length),
      ),
    );
  }

  /// Helper method để lấy giá trị số từ formatted text
  static double? getNumericValue(String formattedText) {
    if (formattedText.isEmpty) return null;
    final cleaned = formattedText.replaceAll('.', '').replaceAll(' ', '');
    return double.tryParse(cleaned);
  }
}
