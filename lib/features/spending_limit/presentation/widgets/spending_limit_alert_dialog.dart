import 'package:flutter/material.dart';
import '../../../../global/widgets/widgets.dart';

/// Alert dialog cho spending limit feature
class SpendingLimitAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final String confirmText;
  final String cancelText;

  const SpendingLimitAlertDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.onCancel,
    this.confirmText = 'Xác nhận',
    this.cancelText = 'Hủy',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppText.heading5(title),
      content: AppText.body(message),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          child: AppText.body(cancelText),
        ),
        TextButton(
          onPressed: onConfirm,
          child: AppText.body(
            confirmText,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
