import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

class AdminDashboardHeader extends StatelessWidget {
    const AdminDashboardHeader({
    super.key,
    required this.onLogout,
  });

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'ADMINISTRATIVE',
                style: TextStyle(
                  color: AppColors.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                  fontSize: 9,
                  letterSpacing: 1.3,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Track project requests and payouts',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),

_CircleButton(
  Icons.logout_rounded,
  AppColors.canvasBackground,
  onTap: onLogout,
),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton(
    this.icon,
    this.background, {
    this.onTap,
  });

  final IconData icon;
  final Color background;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderOutline),
        ),
        child: Icon(
          icon,
          size: 18,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
