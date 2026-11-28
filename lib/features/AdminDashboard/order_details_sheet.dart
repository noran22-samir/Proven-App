import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proven/core/theme/colors.dart';
import 'package:proven/features/orders/orders_repository.dart';
import 'admin_ui.dart';

class OrderDetailsSheet extends StatefulWidget {
  const OrderDetailsSheet({super.key, required this.order});

  final Map<String, dynamic> order;

  @override
  State<OrderDetailsSheet> createState() => _OrderDetailsSheetState();
}

class _OrderDetailsSheetState extends State<OrderDetailsSheet> {
  final _repo = OrdersRepository();
  bool _busy = false;
  String? _error;

  String s(String k) => (widget.order[k] ?? '').toString().trim();

  Future<void> _complete() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _repo.complete(s('id'));
      if (mounted) Navigator.pop(context, true);
    } on FirebaseException catch (e) {
      _fail(e.code == 'permission-denied'
          ? 'Only an admin can complete a delivered order.'
          : 'Could not complete. Check your internet.');
    } catch (_) {
      _fail('Something went wrong. Please try again.');
    }
  }

  void _fail(String m) {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = m;
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = s('status');
    final price = adminNum(widget.order['price']);
    final fee = widget.order['platformFee'] is num
        ? widget.order['platformFee'] as num
        : price * 0.1;
    final creatorAmount = widget.order['creatorAmount'] is num
        ? widget.order['creatorAmount'] as num
        : price * 0.9;
    final color = adminStatusColor(status);

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.tertiaryContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                  color: AppColors.inversePrimary.withValues(alpha: 0.25)),
            ),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text('Order details',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  AdminChip(
                    status.isEmpty
                        ? 'Paid'
                        : status[0].toUpperCase() + status.substring(1),
                    color,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _box([
                _row('Transaction ID', s('transactionId')),
                _row('Project', s('projectTitle')),
                _row('Company / Buyer', s('companyName')),
                _row('Creator',
                    s('creatorName').isEmpty ? 'Creator' : s('creatorName')),
                _row('Created', adminDate(widget.order['createdAt'])),
              ]),
              const SizedBox(height: 12),
              _box([
                _row('Total price', adminMoney(price), strong: true),
                _row('Platform fee (10%)', '+ ${adminMoney(fee)}',
                    valueColor: adminGold),
                _row('Creator amount (90%)', adminMoney(creatorAmount)),
              ]),
              if (s('deliveryLink').isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.outline.withValues(alpha: 0.2)),
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
                          Clipboard.setData(
                              ClipboardData(text: s('deliveryLink')));
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Link copied')));
                        },
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _statusNote(status),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: adminRed)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: (status == 'delivered' && !_busy) ? _complete : null,
                  icon: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2))
                      : const Icon(Icons.check_rounded, size: 20),
                  label: const Text('Mark as completed',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusNote(String status) {
    final (IconData icon, String text, Color c) = switch (status) {
      'delivered' => (
        Icons.check_circle_outline_rounded,
        'The creator delivered this project. Check the link, then complete the order to release the payout.',
        adminGreen
      ),
      'completed' => (
        Icons.verified_rounded,
        'Completed on ${adminDate(widget.order['completedAt'])}.',
        adminGreen
      ),
      _ => (
        Icons.hourglass_top_rounded,
        'Waiting for the creator to deliver. The payment stays in escrow.',
        adminGold
      ),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: c),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 12.5, height: 1.4, color: c)),
          ),
        ],
      ),
    );
  }

  Widget _box(List<Widget> rows) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.tertiary.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
        ),
        child: Column(children: rows),
      );

  Widget _row(String label, String value,
      {bool strong = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13.5, color: AppColors.onTertiaryContainer)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: strong ? 15 : 13.5,
                fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
                color: valueColor ?? Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}