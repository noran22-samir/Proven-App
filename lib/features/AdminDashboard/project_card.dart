import 'package:flutter/material.dart';
import 'package:proven/core/theme/colors.dart';
import 'admin_ui.dart';

class AdminProjectCard extends StatelessWidget {
  const AdminProjectCard({super.key, required this.project, required this.onTap});

  final Map<String, dynamic> project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String s(String k) => (project[k] ?? '').toString().trim();
    final status = s('status');
    final color = adminStatusColor(status);
    final isPending = status == 'pending';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: adminCard(
            border: isPending ? adminGold.withValues(alpha: 0.35) : null,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(adminIcon(s('category')),
                        color: AppColors.inversePrimary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s('title'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'By ${s('ownerName').isEmpty ? 'Creator' : s('ownerName')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.onTertiaryContainer),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AdminChip(
                    status.isEmpty
                        ? 'Pending'
                        : status[0].toUpperCase() + status.substring(1),
                    color,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: AppColors.outline.withValues(alpha: 0.2)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '${s('category')} · ${adminDate(project['createdAt'])}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.onTertiaryContainer),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    adminMoney(project['price']),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: adminGold),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded,
                      size: 20, color: AppColors.onTertiaryContainer),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}