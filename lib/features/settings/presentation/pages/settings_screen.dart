import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

/// Màn hình Cài đặt
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
      ),
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is TransactionsCleared) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã xóa toàn bộ giao dịch'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            // Reset về initial state
            Navigator.of(context).pop();
          } else if (state is ClearTransactionsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return ListView(
              children: [
                // Thông tin ứng dụng
                _buildAppInfoSection(context),

                const Divider(height: 1),

                // Quản lý dữ liệu
                _buildDataManagementSection(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Section thông tin ứng dụng
  Widget _buildAppInfoSection(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.info_outline, color: Colors.blue),
      title: const Text(
        'Thông tin ứng dụng',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Tên app
              const Text(
                'Quản lý chi tiêu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Phiên bản
              Text(
                'Phiên bản 1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),

              // Thông tin thêm
              _buildInfoRow('Tác giả', 'Clean Architecture Team'),
              const SizedBox(height: 8),
              _buildInfoRow('Liên hệ', 'support@example.com'),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget hiển thị thông tin dạng row
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Section quản lý dữ liệu
  Widget _buildDataManagementSection(
      BuildContext context, SettingsState state) {
    final isLoading = state is ClearingTransactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Quản lý dữ liệu',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Nút xóa toàn bộ dữ liệu
        ListTile(
          leading: Icon(
            Icons.delete_sweep,
            color: isLoading ? Colors.grey : Colors.red,
          ),
          title: Text(
            'Xóa toàn bộ dữ liệu giao dịch',
            style: TextStyle(
              color: isLoading ? Colors.grey : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: const Text(
            'Xóa tất cả giao dịch đã lưu (không thể hoàn tác)',
            style: TextStyle(fontSize: 12),
          ),
          trailing: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.chevron_right),
          enabled: !isLoading,
          onTap: () => _showClearDataDialog(context),
        ),
      ],
    );
  }

  /// Hiển thị dialog xác nhận xóa dữ liệu
  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa toàn bộ dữ liệu giao dịch không? '
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          // Nút Hủy
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),

          // Nút Xóa
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Dispatch event xóa dữ liệu (sử dụng context gốc, không phải dialogContext)
              context
                  .read<SettingsBloc>()
                  .add(const ClearAllTransactionsEvent());
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text(
              'Xóa',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
