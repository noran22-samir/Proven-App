// PATH: lib/features/company/orders/company_orders_screen.dart
// ACTION: NEW file. Create a NEW folder: lib/features/company/orders/
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proven/core/theme/colors.dart';
import 'package:proven/features/orders/orders_repository.dart';
import 'package:proven/features/projects/projects_repository.dart';

const _gold = Color(0xFFF2B84B);
const _green = Color(0xFF34D399);

class CompanyOrdersScreen extends StatefulWidget {
  const CompanyOrdersScreen({super.key});

  @override
  State<CompanyOrdersScreen> createState() => _CompanyOrdersScreenState();
}

class _CompanyOrdersScreenState extends State<CompanyOrdersScreen> {
  late final Stream<List<Map<String, dynamic>>> _stream =
      OrdersRepository().companyOrders();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tertiary,
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _stream,
          builder: (context, snap) {
            if (snap.hasError) {
              return const _Notice(
                icon: Icons.cloud_off_rounded,
                text: 'Could not load your orders.\nCheck your internet.',
              );
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final orders = snap.data!;
            final spent = orders.fold<num>(
                0, (t, o) => t + (o['price'] is num ? o['price'] as num : 0));

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Row(
                  children: [
                    const Text('My Orders',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${orders.length}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onTertiaryContainer)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Track your purchases and deliveries',
                    style: TextStyle(color: AppColors.onTertiaryContainer)),
                const SizedBox(height: 16),
                if (orders.isNotEmpty) ...[
                  _summary(orders.length, spent),
                  const SizedBox(height: 16),
                ],
                if (orders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: _Notice(
                      icon: Icons.receipt_long_outlined,
                      text: 'No orders yet.\nBuy a project from the Market.',
                    ),
                  )
                else
                  for (final o in orders) _OrderCard(order: o),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _summary(int count, num spent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text('$count',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('Orders',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.onTertiaryContainer)),
              ],
            ),
          ),
          Container(
              width: 1, height: 34, color: AppColors.outline.withValues(alpha: 0.25)),
          Expanded(
            child: Column(
              children: [
                Text(ProjectsRepository.egp(spent),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700, color: _gold)),
                const SizedBox(height: 4),
                const Text('Total spent',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.onTertiaryContainer)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final Map<String, dynamic> order;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _date(dynamic ts) {
    if (ts is! Timestamp) return 'Just now';
    final d = ts.toDate();
    return '${_months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    String s(String k) => (order[k] ?? '').toString().trim();
    final status = s('status');
    final price = order['price'] is num ? order['price'] as num : 0;

    final (Color color, String label, String hint) = switch (status) {
      'delivered' => (
        AppColors.inversePrimary,
        'Delivered',
        'The creator delivered your project. Waiting for admin confirmation.'
      ),
      'completed' => (_green, 'Completed', 'Order completed. Enjoy your project!'),
      _ => (
        _gold,
        'Paid',
        'Payment is held in escrow until the creator delivers.'
      ),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
              Expanded(
                child: Text(s('projectTitle'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Text(label,
                    style: TextStyle(
                        fontSize: 11.5, fontWeight: FontWeight.w600, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'By ${s('creatorName').isEmpty ? 'Creator' : s('creatorName')} · ${_date(order['createdAt'])}',
            style: const TextStyle(
                fontSize: 12.5, color: AppColors.onTertiaryContainer),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Paid',
                  style: TextStyle(color: AppColors.onTertiaryContainer)),
              const Spacer(),
              Text(ProjectsRepository.egp(price),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800, color: _gold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(hint,
              style: const TextStyle(
                  fontSize: 12.5, height: 1.4, color: AppColors.onTertiaryContainer)),
          if (s('deliveryLink').isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded,
                      size: 18, color: AppColors.inversePrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(s('deliveryLink'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13)),
                  ),
                  IconButton(
                    tooltip: 'Copy delivery link',
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    color: AppColors.inversePrimary,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: s('deliveryLink')));
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Delivery link copied')));
                    },
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined,
                  size: 14, color: AppColors.onTertiaryContainer),
              const SizedBox(width: 6),
              Expanded(
                child: Text(s('transactionId'),
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.onTertiaryContainer)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.onTertiaryContainer),
            const SizedBox(height: 12),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.onTertiaryContainer)),
          ],
        ),
      ),
    );
  }
}