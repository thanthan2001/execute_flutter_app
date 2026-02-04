import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../dashboard/data/datasources/dashboard_local_data_source.dart';
import '../../../dashboard/domain/entities/category_entity.dart';
import '../../domain/entities/recurring_transaction_entity.dart';
import '../bloc/recurring_transaction_bloc.dart';
import '../bloc/recurring_transaction_event.dart';

class AddEditRecurringPage extends StatefulWidget {
  final RecurringTransactionEntity? recurring;

  const AddEditRecurringPage({super.key, this.recurring});

  @override
  State<AddEditRecurringPage> createState() => _AddEditRecurringPageState();
}

class _AddEditRecurringPageState extends State<AddEditRecurringPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<CategoryEntity> _categories = [];
  CategoryEntity? _selectedCategory;
  RecurringFrequency _selectedFrequency = RecurringFrequency.monthly;
  DateTime _nextDate = DateTime.now();
  DateTime? _endDate;
  bool _isActive = true;
  bool _isLoading = true;
  TransactionCategoryType _selectedType = TransactionCategoryType.expense;

  @override
  void initState() {
    super.initState();
    _loadCategories();

    if (widget.recurring != null) {
      _amountController.text = widget.recurring!.amount.toStringAsFixed(0);
      _descriptionController.text = widget.recurring!.description;
      _selectedFrequency = widget.recurring!.frequency;
      _nextDate = widget.recurring!.nextDate;
      _endDate = widget.recurring!.endDate;
      _isActive = widget.recurring!.isActive;
    }
  }

  Future<void> _loadCategories() async {
    try {
      final dashboardDataSource = sl<DashboardLocalDataSource>();
      final categories = await dashboardDataSource.getAllCategories();
      setState(() {
        _categories = categories
            .map((m) => m.toEntity())
            .where((c) => c.type == _selectedType)
            .toList();
        _isLoading = false;

        if (widget.recurring != null) {
          _selectedType = widget.recurring!.type;
          if (_categories.isNotEmpty) {
            _selectedCategory = _categories.firstWhere(
              (c) => c.id == widget.recurring!.categoryId,
              orElse: () => _categories.first,
            );
          }
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    final recurring = RecurringTransactionEntity(
      id: widget.recurring?.id ?? const Uuid().v4(),
      categoryId: _selectedCategory!.id,
      amount: CurrencyInputFormatter.getNumericValue(_amountController.text) ?? 0,
      description: _descriptionController.text,
      frequency: _selectedFrequency,
      nextDate: _nextDate,
      endDate: _endDate,
      isActive: _isActive,
      type: _selectedType,
    );

    if (widget.recurring == null) {
      context
          .read<RecurringTransactionBloc>()
          .add(CreateRecurringTransaction(recurring: recurring));
    } else {
      context
          .read<RecurringTransactionBloc>()
          .add(UpdateRecurringTransaction(recurring: recurring));
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recurring == null ? 'Thêm Định Kỳ' : 'Sửa Định Kỳ'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Loại giao dịch (Thu/Chi)
                    DropdownButtonFormField<TransactionCategoryType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Loại giao dịch',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: TransactionCategoryType.income,
                          child: Text('🔽 Thu'),
                        ),
                        const DropdownMenuItem(
                          value: TransactionCategoryType.expense,
                          child: Text('🔼 Chi'),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedType = val!;
                          _selectedCategory = null; // Reset category
                          _loadCategories();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<CategoryEntity>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Danh mục',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Row(
                            children: [
                              Icon(cat.icon, color: cat.color, size: 20),
                              const SizedBox(width: 8),
                              Text(cat.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Số tiền',
                        border: OutlineInputBorder(),
                        suffixText: 'VND',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Nhập số tiền' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Nhập mô tả' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<RecurringFrequency>(
                      value: _selectedFrequency,
                      decoration: const InputDecoration(
                        labelText: 'Tần suất',
                        border: OutlineInputBorder(),
                      ),
                      items: RecurringFrequency.values.map((freq) {
                        return DropdownMenuItem(
                          value: freq,
                          child: Text(freq.displayName),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedFrequency = val!),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Ngày kế tiếp'),
                      subtitle:
                          Text('${_nextDate.day}/${_nextDate.month}/${_nextDate.year}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _nextDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _nextDate = picked);
                        }
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Hoạt động'),
                      value: _isActive,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _save,
                        child: const Text('Lưu'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
