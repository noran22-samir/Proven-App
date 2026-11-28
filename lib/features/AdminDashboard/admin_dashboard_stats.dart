import 'package:flutter/material.dart';
import 'package:proven/core/theme/colors.dart';
import 'admin_ui.dart';

/// Real numbers, calculated by the dashboard from Firestore.
class AdminDashboardStats extends StatelessWidget {
  const AdminDashboardStats({
    super.key,
    required this.totalSales,
    required this.platformEarnings,
    required this.pendingReview,
    required this.awaitingCompletion,
  });

  final num totalSales;
  final num platformEarnings;
  final int pendingReview;
  final int awaitingCompletion;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.payments_outlined,
                label: 'Total sales',
                value: adminMoney(totalSales),
                helper: 'Gross, all orders',
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.account_balance_outlined,
                label: 'Platform earnings',
                value: adminMoney(platformEarnings),
                helper: '10% of every order',
                color: adminGold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.pending_actions_outlined,
                label: 'Pending review',
                value: '$pendingReview',
                helper: 'Projects waiting',
                color: AppColors.inversePrimary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.local_shipping_outlined,
                label: 'To complete',
                value: '$awaitingCompletion',
                helper: 'Delivered orders',
                color: adminGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.helper,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String helper;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: adminCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            helper,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.onTertiaryContainer.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}