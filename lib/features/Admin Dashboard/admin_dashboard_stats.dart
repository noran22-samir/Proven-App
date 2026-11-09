import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

class AdminDashboardStats extends StatelessWidget {
  const AdminDashboardStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _StatCard(
            label: 'Total Sales',
            value: '124,500',
            helper: 'EGP Gross',
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Platform Earnings',
            value: '12,450',
            helper: '10% Total Rate',
            color: AppColors.brandNavy,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.helper,
    required this.color,
  });

  final String label;
  final String value;
  final String helper;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 12, 12, 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.borderOutline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050C3447),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            helper,
            style: TextStyle(
              fontSize: 8.5,
              color: color.withOpacity(.72),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
