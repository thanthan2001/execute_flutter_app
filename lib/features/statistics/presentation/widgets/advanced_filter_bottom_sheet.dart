import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../dashboard/domain/entities/category_entity.dart';
import '../../domain/entities/filter_options.dart';
import '../bloc/statistics_bloc.dart';
import '../bloc/statistics_event.dart';
import '../bloc/statistics_state.dart';

/// Siêu Bộ Lọc - Advanced Filter Bottom Sheet
/// Hỗ trợ Day/Month/Year/Range + Category + Type filter
class AdvancedFilterBottomSheet extends StatefulWidget {
  final FilterOptions currentFilter;
  final List<CategoryEntity> categories;

  const AdvancedFilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.categories,
  });

  @override
  State<AdvancedFilterBottomSheet> createState() =>
      _AdvancedFilterBottomSheetState();
}

class _AdvancedFilterBottomSheetState extends State<AdvancedFilterBottomSheet> {
  late DateMode _selectedMode;
  late DateTime _selectedDate;
  late int _selectedMonth;
  late int _selectedYear;
  late DateTime? _rangeStart;
  late DateTime? _rangeEnd;
  late String? _selectedCategoryId;
  late TransactionType _selectedType;

  @override
  void initState() {
    super.initState();
    // Init từ current filter
    _selectedMode = widget.currentFilter.dateMode;
    _selectedDate = widget.currentFilter.singleDate ?? DateTime.now();
    _selectedMonth = widget.currentFilter.month ?? DateTime.now().month;
    _selectedYear = widget.currentFilter.year ?? DateTime.now().year;
    _rangeStart = widget.currentFilter.startDate;
    _rangeEnd = widget.currentFilter.endDate;
    _selectedCategoryId = widget.currentFilter.categoryId;
    _selectedType = widget.currentFilter.type;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          const Divider(height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mode selector
                  _buildModeSelector(),
                  const SizedBox(height: 20),

                  // Date pickers based on mode
                  _buildDatePickers(),
                  const SizedBox(height: 20),

                  // Quick presets
                  _buildQuickPresets(),
                  const SizedBox(height: 20),

                  // Category filter
                  _buildCategoryFilter(),
                  const SizedBox(height: 20),

                  // Type filter
                  _buildTypeFilter(),
                ],
              ),
            ),
          ),

          // Bottom buttons
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.filter_alt, color: Colors.blue),
          const SizedBox(width: 8),
          const Text(
            'Bộ Lọc Nâng Cao',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chế độ thời gian',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            _buildModeChip('Ngày', DateMode.day, Icons.calendar_today),
            _buildModeChip('Tháng', DateMode.month, Icons.calendar_month),
            _buildModeChip('Năm', DateMode.year, Icons.calendar_view_month),
            _buildModeChip('Khoảng', DateMode.range, Icons.date_range),
          ],
        ),
      ],
    );
  }

  Widget _buildModeChip(String label, DateMode mode, IconData icon) {
    final isSelected = _selectedMode == mode;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedMode = mode;
            // Reset dates cho mode mới
            if (mode == DateMode.day) {
              _selectedDate = DateTime.now();
            } else if (mode == DateMode.month) {
              _selectedMonth = DateTime.now().month;
              _selectedYear = DateTime.now().year;
            } else if (mode == DateMode.year) {
              _selectedYear = DateTime.now().year;
            } else if (mode == DateMode.range) {
              final now = DateTime.now();
              _rangeStart = DateTime(now.year, now.month, 1);
              _rangeEnd = DateTime(now.year, now.month + 1, 0);
            }
          });
        }
      },
      selectedColor: Colors.blue,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildDatePickers() {
    switch (_selectedMode) {
      case DateMode.day:
        return _buildDayPicker();
      case DateMode.month:
        return _buildMonthPicker();
      case DateMode.year:
        return _buildYearPicker();
      case DateMode.range:
        return _buildRangePicker();
    }
  }

  Widget _buildDayPicker() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.today, color: Colors.blue),
        title: const Text('Chọn ngày'),
        subtitle:
            Text(DateFormat('EEEE, dd/MM/yyyy', 'vi').format(_selectedDate)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            setState(() {
              _selectedDate = picked;
            });
          }
        },
      ),
    );
  }

  Widget _buildMonthPicker() {
    final months = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12'
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Chọn tháng và năm',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedMonth,
                    decoration: const InputDecoration(
                      labelText: 'Tháng',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(months[index]),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMonth = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Năm',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(10, (index) {
                      final year = DateTime.now().year - 5 + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedYear = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearPicker() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_view_month, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Chọn năm',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _selectedYear,
              decoration: const InputDecoration(
                labelText: 'Năm',
                border: OutlineInputBorder(),
              ),
              items: List.generate(10, (index) {
                final year = DateTime.now().year - 5 + index;
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedYear = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangePicker() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.date_range, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Khoảng thời gian',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Từ ngày'),
              subtitle: Text(
                _rangeStart != null
                    ? DateFormat('dd/MM/yyyy').format(_rangeStart!)
                    : 'Chưa chọn',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _rangeStart ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _rangeStart = picked;
                  });
                }
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Đến ngày'),
              subtitle: Text(
                _rangeEnd != null
                    ? DateFormat('dd/MM/yyyy').format(_rangeEnd!)
                    : 'Chưa chọn',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _rangeEnd ?? DateTime.now(),
                  firstDate: _rangeStart ?? DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _rangeEnd = DateTime(
                        picked.year, picked.month, picked.day, 23, 59, 59);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lựa chọn nhanh',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPresetChip('Hôm nay', FilterOptions.today()),
            _buildPresetChip('Tuần này', FilterOptions.thisWeek()),
            _buildPresetChip('Tháng này', FilterOptions.thisMonth()),
            _buildPresetChip('Năm này', FilterOptions.thisYear()),
            _buildPresetChip('7 ngày qua', FilterOptions.last7Days()),
            _buildPresetChip('30 ngày qua', FilterOptions.last30Days()),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, FilterOptions preset) {
    return ActionChip(
      label: Text(label),
      avatar: const Icon(Icons.flash_on, size: 16),
      onPressed: () {
        setState(() {
          _selectedMode = preset.dateMode;
          _selectedDate = preset.singleDate ?? DateTime.now();
          _selectedMonth = preset.month ?? DateTime.now().month;
          _selectedYear = preset.year ?? DateTime.now().year;
          _rangeStart = preset.startDate;
          _rangeEnd = preset.endDate;
        });
      },
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nhóm',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String?>(
          value: _selectedCategoryId,
          decoration: InputDecoration(
            labelText: 'Chọn nhóm',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.category),
            suffixIcon: _selectedCategoryId != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _selectedCategoryId = null;
                      });
                    },
                  )
                : null,
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Tất cả'),
            ),
            ...widget.categories.map((cat) {
              return DropdownMenuItem<String?>(
                value: cat.id,
                child: Row(
                  children: [
                    Icon(cat.icon, size: 20, color: cat.color),
                    const SizedBox(width: 8),
                    Text(cat.name),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loại giao dịch',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<TransactionType>(
          segments: const [
            ButtonSegment(
              value: TransactionType.all,
              label: Text('Tất cả'),
              icon: Icon(Icons.list),
            ),
            ButtonSegment(
              value: TransactionType.income,
              label: Text('Thu'),
              icon: Icon(Icons.arrow_downward, color: Colors.green),
            ),
            ButtonSegment(
              value: TransactionType.expense,
              label: Text('Chi'),
              icon: Icon(Icons.arrow_upward, color: Colors.red),
            ),
          ],
          selected: {_selectedType},
          onSelectionChanged: (Set<TransactionType> newSelection) {
            setState(() {
              _selectedType = newSelection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Reset button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<StatisticsBloc>().add(const ResetFilter());
                Navigator.pop(context);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Đặt lại'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Apply button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _applyFilter,
              icon: const Icon(Icons.check),
              label: const Text('Áp dụng'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilter() {
    // Tạo FilterOptions từ current selections
    FilterOptions filter;

    switch (_selectedMode) {
      case DateMode.day:
        filter = FilterOptions(
          dateMode: DateMode.day,
          singleDate: _selectedDate,
          categoryId: _selectedCategoryId,
          type: _selectedType,
        );
        break;

      case DateMode.month:
        filter = FilterOptions(
          dateMode: DateMode.month,
          month: _selectedMonth,
          year: _selectedYear,
          categoryId: _selectedCategoryId,
          type: _selectedType,
        );
        break;

      case DateMode.year:
        filter = FilterOptions(
          dateMode: DateMode.year,
          year: _selectedYear,
          categoryId: _selectedCategoryId,
          type: _selectedType,
        );
        break;

      case DateMode.range:
        if (_rangeStart == null || _rangeEnd == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng chọn đủ ngày bắt đầu và kết thúc'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        filter = FilterOptions(
          dateMode: DateMode.range,
          startDate: _rangeStart,
          endDate: _rangeEnd,
          categoryId: _selectedCategoryId,
          type: _selectedType,
        );
        break;
    }

    // Dispatch event
    context.read<StatisticsBloc>().add(ApplyFilter(options: filter));
    Navigator.pop(context);
  }
}
