import 'package:flutter/material.dart';
import 'app_button.dart';

/// Helper class cho AppDialog
class AppDialog {
  /// Hiển thị dialog xác nhận
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Xác nhận',
    String cancelText = 'Hủy',
    bool isDanger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          AppButton.text(
            text: cancelText,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          isDanger
              ? AppButton.danger(
                  text: confirmText,
                  onPressed: () => Navigator.of(context).pop(true),
                )
              : AppButton.primary(
                  text: confirmText,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
        ],
      ),
    );
  }

  /// Hiển thị loading dialog
  static void showLoading({
    required BuildContext context,
    String message = 'Đang xử lý...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }

  /// Đóng loading dialog
  static void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Hiển thị info dialog
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'Đóng',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          AppButton.primary(
            text: buttonText,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Hiển thị error dialog
  static Future<void> showError({
    required BuildContext context,
    required String message,
    String title = 'Lỗi',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          AppButton.text(
            text: 'Đóng',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Hiển thị success dialog
  static Future<void> showSuccess({
    required BuildContext context,
    required String message,
    String title = 'Thành công',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          AppButton.primary(
            text: 'Đóng',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Hiển thị bottom sheet với options
  static Future<T?> showOptions<T>({
    required BuildContext context,
    required String title,
    required List<AppDialogOption<T>> options,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1),
          ...options.map((option) => ListTile(
                leading: option.icon != null
                    ? Icon(option.icon, color: option.iconColor)
                    : null,
                title: Text(option.label),
                subtitle: option.subtitle != null ? Text(option.subtitle!) : null,
                onTap: () => Navigator.of(context).pop(option.value),
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Option cho showOptions
class AppDialogOption<T> {
  final String label;
  final String? subtitle;
  final T value;
  final IconData? icon;
  final Color? iconColor;

  const AppDialogOption({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.subtitle,
  });
}
