import 'package:flutter/material.dart';
import '../../../../global/widgets/widgets.dart';

/// Feature Card - Card hiển thị từng chức năng với icon đẹp
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 8),
            // Title
            AppText.label(
              title,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Subtitle
            Flexible(
              child: AppText.caption(
                subtitle,
                textAlign: TextAlign.center,
                color: Colors.grey.shade600,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Feature Cards Grid - Hiển thị các card chức năng theo lưới
class FeatureCardsGrid extends StatelessWidget {
  final Function(String) onNavigate;

  const FeatureCardsGrid({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppText.heading4('Chức năng'),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          childAspectRatio: 1.0,
          children: [
            FeatureCard(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Ngân sách',
              subtitle: 'Quản lý ngân sách theo danh mục',
              iconColor: Colors.blue,
              onTap: () => onNavigate('/budgets'),
            ),
            FeatureCard(
              icon: Icons.payments_outlined,
              title: 'Giới hạn',
              subtitle: 'Giới hạn chi tiêu',
              iconColor: Colors.orange,
              onTap: () => onNavigate('/spending-limit'),
            ),
            FeatureCard(
              icon: Icons.category_outlined,
              title: 'Nhóm',
              subtitle: 'Quản lý danh mục',
              iconColor: Colors.purple,
              onTap: () => onNavigate('/categories'),
            ),
            FeatureCard(
              icon: Icons.repeat_rounded,
              title: 'Định kỳ',
              subtitle: 'Giao dịch định kỳ',
              iconColor: Colors.teal,
              onTap: () => onNavigate('/recurring-transactions'),
            ),
            FeatureCard(
              icon: Icons.backup_outlined,
              title: 'Sao lưu',
              subtitle: 'Backup & Restore',
              iconColor: Colors.green,
              onTap: () => onNavigate('/backup'),
            ),
          ],
        ),
      ],
    );
  }
}
