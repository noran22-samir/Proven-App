// المسار: lib/features/creator/purchase_requests/presentation/widgets/request_card.dart   (ملف جديد)
//
// كارت الطلب بتاع الكريتور. اسمه RequestCard علشان ميتعارضش مع ContractRequestCard
// اللي اتغيّر عندكم (بقى بياخد order و onTap).

import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.initials,
    required this.companyName,
    required this.companySubtitle,
    required this.status,
    required this.statusColor,
    required this.date,
    required this.projectTitle,
    required this.purchasePrice,
    required this.netReceive,
    required this.onDetailsTap,
  });

  final String initials;
  final String companyName;
  final String companySubtitle;
  final String status;
  final Color statusColor;
  final String date;
  final String projectTitle;
  final String purchasePrice;
  final String netReceive;
  final VoidCallback onDetailsTap;

  static const _green = Color(0xFF34D399);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inversePrimary.withValues(alpha: 0.3)),
                ),
                child: Text(initials,
                    style: const TextStyle(
                        color: AppColors.inversePrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(companyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(companySubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.onTertiaryContainer, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(status,
                        style: TextStyle(
                            color: statusColor, fontWeight: FontWeight.w600, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Project License',
                        style: TextStyle(color: AppColors.onTertiaryContainer, fontSize: 12)),
                    Text(date,
                        style: const TextStyle(
                            color: AppColors.onTertiaryContainer, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(projectTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Purchase Price',
                        style: TextStyle(color: AppColors.onTertiaryContainer, fontSize: 12)),
                    Text(purchasePrice,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments_outlined, color: _green, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'You receive: ',
                            style: const TextStyle(
                                color: AppColors.onTertiaryContainer, fontSize: 12),
                            children: [
                              TextSpan(
                                text: netReceive,
                                style: const TextStyle(
                                    color: _green, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: onDetailsTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.inversePrimary.withValues(alpha: 0.35)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Details',
                          style: TextStyle(
                              color: AppColors.inversePrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, color: AppColors.inversePrimary, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}