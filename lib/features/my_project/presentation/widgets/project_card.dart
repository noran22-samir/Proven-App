import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class ProjectCard extends StatelessWidget {
  final String title;
  final String category;
  final String price;
  final String status;
  final Color statusColor;
  final Color statusBgColor;
  final String subText;
  final Color? subTextColor;
  final IconData coverIcon;
  final String? rejectionReason;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onResubmit;

  const ProjectCard({
    super.key,
    required this.title,
    required this.category,
    required this.price,
    required this.status,
    required this.statusColor,
    required this.statusBgColor,
    required this.subText,
    this.subTextColor,
    required this.coverIcon,
    this.rejectionReason,
    this.onEdit,
    this.onDelete,
    this.onResubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Box on the left side
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outline.withOpacity(0.15)),
                ),
                child: Stack(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(6),
                      child: Text(
                        'Cover',
                        style: TextStyle(
                          color: AppColors.onTertiaryContainer,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        coverIcon,
                        color: AppColors.inversePrimary,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Right side details (Title, Status, Category, Price)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Category and Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.inversePrimary.withOpacity(0.3)),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              color: AppColors.inversePrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          price,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Subtext and Action Buttons Row (Edit & Delete)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subText,
                style: TextStyle(
                  color: subTextColor ?? AppColors.onTertiaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    icon: const Icon(Icons.edit_outlined, color: AppColors.inversePrimary, size: 18),
                    onPressed: onEdit,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
          // Rejection Reason Box (Appears only for rejected projects as in the image)
          if (rejectionReason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.tertiary.withOpacity(0.9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Reason: $rejectionReason',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tertiaryContainer,
                        foregroundColor: AppColors.inversePrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: AppColors.inversePrimary.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: onResubmit,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text(
                        'Edit & Resubmit',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}