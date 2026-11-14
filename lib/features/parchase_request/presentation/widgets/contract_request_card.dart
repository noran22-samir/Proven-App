import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class ContractRequestCard extends StatelessWidget {
  // Properties / Fields required to configure the contract card dynamically
  final String initials;
  final String companyName;
  final String companySubtitle;
  final String status;
  final Color statusColor;
  final Color statusBgColor;
  final String date;
  final String projectTitle;
  final String purchasePrice;
  final String netReceive;
  final VoidCallback onDetailsTap;

  const ContractRequestCard({
    super.key,
    required this.initials,
    required this.companyName,
    required this.companySubtitle,
    required this.status,
    required this.statusColor,
    required this.statusBgColor,
    required this.date,
    required this.projectTitle,
    required this.purchasePrice,
    required this.netReceive,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Outer card margin and container box with dark theme styling
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
          // 1. Top Section: Company Initials Avatar, Name, Subtitle, and Status Badge
          Row(
            children: [
              // Company initials box (e.g., NH, DR)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inversePrimary.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: AppColors.inversePrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Company name and category subtitle info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      companySubtitle,
                      style: const TextStyle(
                        color: AppColors.onTertiaryContainer,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Dynamic status indicator badge (e.g., Paid, Completed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Middle Section: Inner Box for Project License, Date, Title, and Purchase Price
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.tertiary.withOpacity(0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outline.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Project License',
                      style: TextStyle(
                        color: AppColors.onTertiaryContainer,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        color: AppColors.onTertiaryContainer,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  projectTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Purchase Price',
                      style: TextStyle(
                        color: AppColors.onTertiaryContainer,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      purchasePrice,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Bottom Section: Net Earning/Receive amount and Details Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Net amount received highlight badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.payments_outlined, color: Color(0xFF34D399), size: 16),
                    const SizedBox(width: 6),
                    RichText(
                      text: TextSpan(
                        text: 'You receive: ',
                        style: const TextStyle(
                          color: AppColors.onTertiaryContainer,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: netReceive,
                            style: const TextStyle(
                              color: Color(0xFF34D399),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Details action button with tap callback
              InkWell(
                onTap: onDetailsTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.inversePrimary.withOpacity(0.35)),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Details',
                        style: TextStyle(
                          color: AppColors.inversePrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
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