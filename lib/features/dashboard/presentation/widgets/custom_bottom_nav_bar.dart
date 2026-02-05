import 'package:flutter/material.dart';
import '../../../../global/widgets/widgets.dart';

/// Custom Bottom Navigation Bar với thiết kế đẹp theo các chức năng hiện có
class CustomBottomNavBar extends StatelessWidget {
  final Function(String) onNavigate;

  const CustomBottomNavBar({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.list_alt_rounded,
                label: 'Giao dịch',
                onTap: () => onNavigate('/transactions'),
              ),
              _buildNavItem(
                context,
                icon: Icons.bar_chart_rounded,
                label: 'Thống kê',
                onTap: () => onNavigate('/statistics'),
              ),
              // Central FAB
              _buildCentralFAB(context),
              _buildNavItem(
                context,
                icon: Icons.apps_rounded,
                label: 'Thêm',
                onTap: () => onNavigate('/features'),
              ),
              _buildNavItem(
                context,
                icon: Icons.settings_rounded,
                label: 'Cài đặt',
                onTap: () => onNavigate('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  icon,
                  color: Colors.grey.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              AppText.caption(
                label,
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCentralFAB(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: 56,
      height: 56,
      child: FloatingActionButton(
        onPressed: () => onNavigate('/transactions/add'),
        elevation: 4,
        backgroundColor: theme.primaryColor,
        child: const Icon(
          Icons.add,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }
}
