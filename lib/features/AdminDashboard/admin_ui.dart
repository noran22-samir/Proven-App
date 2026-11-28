import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart';
import 'package:proven/core/theme/colors.dart';
import 'package:proven/features/projects/projects_repository.dart';

const adminGold = Color(0xFFF2B84B);
const adminGreen = Color(0xFF34D399);
const adminRed = Color(0xFFFF8A80);

BoxDecoration adminCard({Color? border}) => BoxDecoration(
      color: AppColors.tertiaryContainer.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: border ?? AppColors.outline.withValues(alpha: 0.25),
      ),
    );

num adminNum(dynamic v) => v is num ? v : 0;

String adminMoney(dynamic v) => ProjectsRepository.egp(adminNum(v));

String adminDate(dynamic ts) {
  if (ts is! Timestamp) return 'Just now';
  const m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final d = ts.toDate();
  return '${m[d.month - 1]} ${d.day}, ${d.year}';
}

IconData adminIcon(String category) {
  final c = category.toLowerCase();
  if (c.contains('health')) return Icons.medical_services_outlined;
  if (c.contains('educ')) return Icons.school_outlined;
  if (c.contains('financ')) return Icons.account_balance_wallet_outlined;
  if (c.contains('commerce') || c.contains('shop')) {
    return Icons.shopping_bag_outlined;
  }
  if (c.contains('ai') || c.contains('bot')) return Icons.smart_toy_outlined;
  return Icons.widgets_outlined;
}

Color adminStatusColor(String status) {
  switch (status) {
    case 'approved':
    case 'completed':
      return adminGreen;
    case 'delivered':
      return AppColors.inversePrimary;
    case 'rejected':
    case 'unpublished':
      return adminRed;
    default: // pending, paid
      return adminGold;
  }
}

class AdminChip extends StatelessWidget {
  const AdminChip(this.label, this.color, {super.key});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class AdminNotice extends StatelessWidget {
  const AdminNotice({super.key, required this.icon, required this.text, this.onRetry});
  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: AppColors.onTertiaryContainer),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onTertiaryContainer),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ],
        ),
      ),
    );
  }
}