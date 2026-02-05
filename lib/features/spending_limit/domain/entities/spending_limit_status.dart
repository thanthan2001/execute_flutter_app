import 'package:equatable/equatable.dart';

/// Entity chứa thông tin trạng thái giới hạn chi tiêu
class SpendingLimitStatus extends Equatable {
  final String limitId;
  final double limitAmount; // Số tiền giới hạn đã đặt
  final double usedAmount; // Số tiền đã chi tiêu
  final double percentage; // Phần trăm đã sử dụng (0-100+)
  final SpendingLimitAlertLevel alertLevel; // Mức độ cảnh báo
  final DateTime periodStart; // Ngày bắt đầu period hiện tại
  final DateTime periodEnd; // Ngày kết thúc period hiện tại

  const SpendingLimitStatus({
    required this.limitId,
    required this.limitAmount,
    required this.usedAmount,
    required this.percentage,
    required this.alertLevel,
    required this.periodStart,
    required this.periodEnd,
  });

  /// Số tiền còn lại
  double get remainingAmount => limitAmount - usedAmount;

  /// Có vượt giới hạn không
  bool get isOverLimit => usedAmount > limitAmount;

  @override
  List<Object?> get props => [
        limitId,
        limitAmount,
        usedAmount,
        percentage,
        alertLevel,
        periodStart,
        periodEnd,
      ];
}

/// Enum cho mức độ cảnh báo giới hạn chi tiêu
enum SpendingLimitAlertLevel {
  normal, // < 80%
  warning, // >= 80% và < 100%
  exceeded, // >= 100% và < 120%
  critical, // >= 120%
}

/// Extension để xác định alert level từ percentage
extension SpendingLimitAlertLevelExtension on SpendingLimitAlertLevel {
  /// Lấy alert level từ percentage
  static SpendingLimitAlertLevel fromPercentage(double percentage) {
    if (percentage < 80) {
      return SpendingLimitAlertLevel.normal;
    } else if (percentage < 100) {
      return SpendingLimitAlertLevel.warning;
    } else if (percentage < 120) {
      return SpendingLimitAlertLevel.exceeded;
    } else {
      return SpendingLimitAlertLevel.critical;
    }
  }

  /// Lấy màu sắc theo alert level
  int get colorValue {
    switch (this) {
      case SpendingLimitAlertLevel.normal:
        return 0xFF4CAF50; // Green
      case SpendingLimitAlertLevel.warning:
        return 0xFFFF9800; // Orange
      case SpendingLimitAlertLevel.exceeded:
        return 0xFFFF5722; // Deep Orange
      case SpendingLimitAlertLevel.critical:
        return 0xFFF44336; // Red
    }
  }

  /// Lấy message theo alert level
  String get message {
    switch (this) {
      case SpendingLimitAlertLevel.normal:
        return 'Chi tiêu ổn định';
      case SpendingLimitAlertLevel.warning:
        return '⚠️ Sắp đạt giới hạn chi tiêu';
      case SpendingLimitAlertLevel.exceeded:
        return '🚨 Đã vượt giới hạn';
      case SpendingLimitAlertLevel.critical:
        return '🔴 Vượt giới hạn nghiêm trọng';
    }
  }
}
