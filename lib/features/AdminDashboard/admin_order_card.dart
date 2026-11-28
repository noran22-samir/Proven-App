import 'package:flutter/material.dart';
import 'package:proven/core/theme/colors.dart';
import 'admin_ui.dart';

class AdminOrderCard extends StatelessWidget {
  const AdminOrderCard({super.key, required this.order, required this.onTap});

  final Map<String, dynamic> order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String s(String k) => (order[k] ?? '').toString().trim();
    final status = s('status');
    final color = adminStatusColor(status);
    final ready = status == 'delivered'; // the admin can complete it

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: adminCard(
            border: ready ? adminGreen.withValues(alpha: 0.4) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      s('projectTitle'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AdminChip(
                    status.isEmpty
                        ? 'Paid'
                        : status[0].toUpperCase() + status.substring(1),
                    color,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${s('companyName')}  →  ${s('creatorName').isEmpty ? 'Creator' : s('creatorName')}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.onTertiaryContainer),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 14, color: AppColors.onTertiaryContainer),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${s('transactionId')} · ${adminDate(order['createdAt'])}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11.5, color: AppColors.onTertiaryContainer),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    adminMoney(order['price']),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: adminGold),
                  ),
                ],
              ),
              if (ready) ...[
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 15, color: adminGreen),
                    SizedBox(width: 6),
                    Text('Delivered · ready to complete',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: adminGreen)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}