import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

class DashboardProject {
  const DashboardProject({
    required this.name,
    required this.subtitle,
    required this.category,
    required this.amount,
    required this.date,
    required this.status,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  final String name;
  final String subtitle;
  final String category;
  final String amount;
  final String date;
  final String status;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({required this.project, required this.onTap, super.key});

  final DashboardProject project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.borderOutline),
          boxShadow: const [
            BoxShadow(
              color: Color(0x050C3447),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: project.iconBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(project.icon, color: project.iconColor, size: 22),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              project.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _StatusChip(status: project.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.subtitle,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${project.category}  •  ${project.date}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      project.amount,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      '+850 EGP fee',
                      style: TextStyle(
                        color: AppColors.brandNavy,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 11),
            const Divider(height: 1, color: AppColors.borderOutline),
            const SizedBox(height: 9),
            Row(
              children: [
                const Icon(Icons.receipt_long_outlined, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                const Expanded(
                  child: Text(
                    'TXN-173630532000/000',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 8.5),
                  ),
                ),
                TextButton(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'View Details  ›',
                    style: TextStyle(
                      color: AppColors.primaryContainer,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isPaid = status == 'Paid';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isPaid ? const Color(0xFFE4F5EC) : AppColors.primaryFixed,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isPaid ? AppColors.primaryContainer : const Color(0xFFB07700),
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
