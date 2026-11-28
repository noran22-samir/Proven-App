import 'package:flutter/material.dart';
import 'package:proven/core/theme/colors.dart';

class AdminDashboardHeader extends StatelessWidget {
  const AdminDashboardHeader({super.key, required this.onLogout});

  final VoidCallback onLogout;

  Future<void> _confirm(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.tertiaryContainer,
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out',
                style: TextStyle(color: Color(0xFFFF8A80))),
          ),
        ],
      ),
    );
    if (ok == true) onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_rounded,
                      size: 14, color: AppColors.inversePrimary),
                  const SizedBox(width: 6),
                  Text(
                    'ADMINISTRATIVE',
                    style: TextStyle(
                      color: AppColors.inversePrimary.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w800,
                      fontSize: 10.5,
                      letterSpacing: 1.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Admin Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Review projects and track orders',
                style: TextStyle(
                  color: AppColors.onTertiaryContainer,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Tooltip(
          message: 'Log out',
          child: InkWell(
            onTap: () => _confirm(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.tertiaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.outline.withValues(alpha: 0.25)),
              ),
              child: const Icon(Icons.logout_rounded,
                  size: 20, color: AppColors.inversePrimary),
            ),
          ),
        ),
      ],
    );
  }
}