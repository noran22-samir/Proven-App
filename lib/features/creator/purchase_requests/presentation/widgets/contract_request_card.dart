// PATH: lib/features/creator/purchase_requests/presentation/widgets/contract_request_card.dart
// ACTION: REPLACE the existing file (same place). The card now reads the real order map.
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart';
import 'package:proven/core/theme/colors.dart';
import 'package:proven/features/projects/projects_repository.dart';

const orderGold = Color(0xFFF2B84B);
const orderGreen = Color(0xFF34D399);

String orderDate(dynamic ts) {
  if (ts is! Timestamp) return 'Just now';
  const m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final d = ts.toDate();
  return '${m[d.month - 1]} ${d.day}, ${d.year}';
}

String orderMoney(dynamic v) => ProjectsRepository.egp(v is num ? v : 0);

Color orderStatusColor(String status) {
  switch (status) {
    case 'completed':
      return orderGreen;
    case 'delivered':
      return AppColors.inversePrimary;
    default:
      return orderGold; // paid = waiting for the creator
  }
}

String orderStatusLabel(String status) {
  switch (status) {
    case 'completed':
      return 'Completed';
    case 'delivered':
      return 'Delivered';
    default:
      return 'To deliver';
  }
}

class ContractRequestCard extends StatelessWidget {
  const ContractRequestCard({super.key, required this.order, required this.onTap});

  final Map<String, dynamic> order;
  final VoidCallback onTap;

  String _initials(String name) {
    final p = name.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (p.isEmpty) return '?';
    if (p.length == 1) return p.first[0].toUpperCase();
    return (p[0][0] + p[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    String s(String k) => (order[k] ?? '').toString().trim();
    final status = s('status');
    final color = orderStatusColor(status);
    final needsAction = status == 'paid';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.tertiaryContainer.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: needsAction
                  ? orderGold.withValues(alpha: 0.4)
                  : AppColors.outline.withValues(alpha: 0.25),
            ),
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
                      border: Border.all(
                          color: AppColors.inversePrimary.withValues(alpha: 0.3)),
                    ),
                    child: Text(_initials(s('companyName')),
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
                        Text(s('companyName').isEmpty ? 'Company' : s('companyName'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(orderDate(order['createdAt']),
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.onTertiaryContainer)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Text(orderStatusLabel(status),
                        style: TextStyle(
                            color: color, fontSize: 12, fontWeight: FontWeight.w600)),
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
                    const Text('Project',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.onTertiaryContainer)),
                    const SizedBox(height: 4),
                    Text(s('projectTitle'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Purchase price',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.onTertiaryContainer)),
                        const Spacer(),
                        Text(orderMoney(order['price']),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: orderGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.payments_outlined,
                              color: orderGreen, size: 16),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'You receive: ${orderMoney(order['creatorAmount'])}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: orderGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: needsAction
                          ? AppColors.brandNavy
                          : AppColors.primaryContainer.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.inversePrimary.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      children: [
                        Text(needsAction ? 'Deliver' : 'Details',
                            style: const TextStyle(
                                color: AppColors.inversePrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward,
                            color: AppColors.inversePrimary, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}