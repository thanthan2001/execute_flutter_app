import 'package:equatable/equatable.dart';

/// Enum cho chế độ filter theo thời gian
enum DateMode {
  day, // Chọn 1 ngày cụ thể
  month, // Chọn tháng + năm
  year, // Chọn năm
  range, // Chọn khoảng thời gian từ startDate đến endDate
}

/// Enum cho loại giao dịch
enum TransactionType {
  all, // Tất cả
  income, // Thu
  expense, // Chi
}

/// Entity chứa các tùy chọn filter cho statistics
class FilterOptions extends Equatable {
  final DateMode dateMode; // Chế độ filter (day/month/year/range)
  final DateTime? singleDate; // Dùng cho mode = day
  final int? month; // Dùng cho mode = month (1-12)
  final int? year; // Dùng cho mode = month hoặc year
  final DateTime? startDate; // Dùng cho mode = range
  final DateTime? endDate; // Dùng cho mode = range
  final String? categoryId; // Filter theo category (null = all)
  final TransactionType type; // Filter theo loại (all/income/expense)

  const FilterOptions({
    required this.dateMode,
    this.singleDate,
    this.month,
    this.year,
    this.startDate,
    this.endDate,
    this.categoryId,
    this.type = TransactionType.all,
  });

  /// Factory: Filter mặc định (tháng hiện tại)
  factory FilterOptions.defaultFilter() {
    final now = DateTime.now();
    return FilterOptions(
      dateMode: DateMode.month,
      month: now.month,
      year: now.year,
      type: TransactionType.all,
    );
  }

  /// Factory: Filter theo ngày hôm nay
  factory FilterOptions.today() {
    final now = DateTime.now();
    return FilterOptions(
      dateMode: DateMode.day,
      singleDate: DateTime(now.year, now.month, now.day),
      type: TransactionType.all,
    );
  }

  /// Factory: Filter theo tuần này (range)
  factory FilterOptions.thisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return FilterOptions(
      dateMode: DateMode.range,
      startDate: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      endDate:
          DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59),
      type: TransactionType.all,
    );
  }

  /// Factory: Filter theo tháng này
  factory FilterOptions.thisMonth() {
    final now = DateTime.now();
    return FilterOptions(
      dateMode: DateMode.month,
      month: now.month,
      year: now.year,
      type: TransactionType.all,
    );
  }

  /// Factory: Filter theo năm này
  factory FilterOptions.thisYear() {
    final now = DateTime.now();
    return FilterOptions(
      dateMode: DateMode.year,
      year: now.year,
      type: TransactionType.all,
    );
  }

  /// Factory: Filter 7 ngày gần nhất
  factory FilterOptions.last7Days() {
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final startDate = endDate.subtract(const Duration(days: 6));
    return FilterOptions(
      dateMode: DateMode.range,
      startDate: DateTime(startDate.year, startDate.month, startDate.day),
      endDate: endDate,
      type: TransactionType.all,
    );
  }

  /// Factory: Filter 30 ngày gần nhất
  factory FilterOptions.last30Days() {
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final startDate = endDate.subtract(const Duration(days: 29));
    return FilterOptions(
      dateMode: DateMode.range,
      startDate: DateTime(startDate.year, startDate.month, startDate.day),
      endDate: endDate,
      type: TransactionType.all,
    );
  }

  /// Copy với các giá trị mới
  FilterOptions copyWith({
    DateMode? dateMode,
    DateTime? singleDate,
    int? month,
    int? year,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    TransactionType? type,
    bool clearCategory = false,
  }) {
    return FilterOptions(
      dateMode: dateMode ?? this.dateMode,
      singleDate: singleDate ?? this.singleDate,
      month: month ?? this.month,
      year: year ?? this.year,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      type: type ?? this.type,
    );
  }

  /// Lấy date range đã normalize dựa trên dateMode
  /// Day → 00:00:00 đến 23:59:59 của ngày đó
  /// Month → ngày đầu tháng 00:00 đến ngày cuối tháng 23:59
  /// Year → 1/1 00:00 đến 31/12 23:59
  /// Range → giữ nguyên startDate và endDate
  ({DateTime start, DateTime end}) getNormalizedDateRange() {
    switch (dateMode) {
      case DateMode.day:
        if (singleDate == null) {
          throw Exception('singleDate is required for DateMode.day');
        }
        final start =
            DateTime(singleDate!.year, singleDate!.month, singleDate!.day);
        final end = DateTime(
            singleDate!.year, singleDate!.month, singleDate!.day, 23, 59, 59);
        return (start: start, end: end);

      case DateMode.month:
        if (month == null || year == null) {
          throw Exception('month and year are required for DateMode.month');
        }
        final start = DateTime(year!, month!, 1);
        // Cuối tháng = ngày đầu tháng sau - 1 ngày
        final end = DateTime(year!, month! + 1, 0, 23, 59, 59);
        return (start: start, end: end);

      case DateMode.year:
        if (year == null) {
          throw Exception('year is required for DateMode.year');
        }
        final start = DateTime(year!, 1, 1);
        final end = DateTime(year!, 12, 31, 23, 59, 59);
        return (start: start, end: end);

      case DateMode.range:
        if (startDate == null || endDate == null) {
          throw Exception(
              'startDate and endDate are required for DateMode.range');
        }
        return (start: startDate!, end: endDate!);
    }
  }

  @override
  List<Object?> get props => [
        dateMode,
        singleDate,
        month,
        year,
        startDate,
        endDate,
        categoryId,
        type,
      ];
}
