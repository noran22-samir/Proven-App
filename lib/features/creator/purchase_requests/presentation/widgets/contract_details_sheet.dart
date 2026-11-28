// المسار: lib/features/creator/purchase_requests/presentation/widgets/contract_details_sheet.dart   (بدّل الملف كله)
//
// تفاصيل الطلب (Bottom Sheet). لو الطلب Paid بيظهر فورم تسليم المشروع (لينك)،
// ولو Delivered/Completed بيظهر لينك التسليم. الاستخدام:
//   ContractDetailsSheet.show(context, cubit, item);

import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../cubit/purchase_request_cubit.dart';

class ContractDetailsSheet extends StatefulWidget {
  const ContractDetailsSheet({super.key, required this.cubit, required this.item});

  final PurchaseRequestCubit cubit;
  final Map item;

  static Future<void> show(BuildContext context, PurchaseRequestCubit cubit, Map item) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ContractDetailsSheet(cubit: cubit, item: item),
    );
  }

  @override
  State<ContractDetailsSheet> createState() => _ContractDetailsSheetState();
}

class _ContractDetailsSheetState extends State<ContractDetailsSheet> {
  static const _green = Color(0xFF34D399);
  static const _amber = Color(0xFFF1C65D);

  final _link = TextEditingController();
  bool _busy = false;
  String? _error;

  Map get item => widget.item;
  String get _raw => '${item['raw']}';

  @override
  void dispose() {
    _link.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (_raw) {
      case 'completed':
        return _green;
      case 'delivered':
        return _amber;
      default:
        return AppColors.inversePrimary;
    }
  }

  String _egp(num n) =>
      '${n.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')} EGP';

  Future<void> _deliver() async {
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await widget.cubit.deliver('${item['id']}', _link.text);
    if (!mounted) return;
    if (err == null) {
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(
        content: Text('Delivered. The admin will review it and release your payout.'),
      ));
    } else {
      setState(() {
        _busy = false;
        _error = err;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final fee = item['feeValue'] is num ? item['feeValue'] as num : null;

    return DraggableScrollableSheet(
      initialChildSize: _raw == 'paid' ? 0.8 : 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.tertiaryContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: AppColors.inversePrimary.withValues(alpha: 0.25)),
            ),
          ),
          child: ListView(
            controller: controller,
            padding: EdgeInsets.fromLTRB(20, 10, 20, 24 + (insets > 0 ? insets : safeBottom)),
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
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.inversePrimary.withValues(alpha: 0.3)),
                    ),
                    child: Text('${item['initials']}',
                        style: const TextStyle(
                            color: AppColors.inversePrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item['companyName']}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('${item['companySubtitle']}',
                            style: const TextStyle(
                                fontSize: 12.5, color: AppColors.onTertiaryContainer)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _statusColor.withValues(alpha: 0.4)),
                    ),
                    child: Text('${item['status']}',
                        style: TextStyle(
                            color: _statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _Steps(raw: _raw),
              const SizedBox(height: 18),
              _box([
                _row('Project', '${item['projectTitle']}'),
                _row('Date', '${item['date']}'),
                _row('Purchase price', '${item['purchasePrice']}'),
                _row('Platform fee (10%)', fee == null ? '—' : '- ${_egp(fee)}'),
              ]),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _green.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.payments_outlined, color: _green),
                    const SizedBox(width: 10),
                    Text(_raw == 'completed' ? 'Paid out to you' : 'You will receive',
                        style: const TextStyle(color: AppColors.onTertiaryContainer)),
                    const Spacer(),
                    Text('${item['netReceive']}',
                        style: const TextStyle(
                            color: _green, fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (_raw == 'paid') ..._deliverForm() else _deliveredInfo(),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _deliverForm() => [
        const Text('Deliver the project',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text(
          'Upload your source code and docs (GitHub, Google Drive...) and paste the share link. The admin checks it, then releases your payout.',
          style: TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.onTertiaryContainer),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _link,
          enabled: !_busy,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: 'https://github.com/you/project  or a Drive link',
            prefixIcon: Icon(Icons.link_rounded),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Color(0xFFFF8A80), fontSize: 12.5)),
        ],
        const SizedBox(height: 14),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: _busy ? null : _deliver,
            icon: _busy
                ? const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send_rounded, size: 18),
            label: const Text('Mark as delivered',
                style: TextStyle(fontWeight: FontWeight.w700)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ];

  Widget _deliveredInfo() {
    final link = '${item['deliveryLink']}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (link.isNotEmpty)
          _box([_row('Delivery link', link)]),
        const SizedBox(height: 12),
        Text(
          _raw == 'completed'
              ? 'The admin approved the delivery and your payout was released.'
              : 'Waiting for the admin to review your delivery.',
          style: const TextStyle(fontSize: 12.5, color: AppColors.onTertiaryContainer),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 50,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.inversePrimary,
              side: BorderSide(color: AppColors.inversePrimary.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Close'),
          ),
        ),
      ],
    );
  }

  Widget _box(List<Widget> children) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.tertiary.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
        ),
        child: Column(children: children),
      );

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(fontSize: 13.5, color: AppColors.onTertiaryContainer)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}

class _Steps extends StatelessWidget {
  const _Steps({required this.raw});
  final String raw;

  @override
  Widget build(BuildContext context) {
    const labels = ['Paid', 'Delivered', 'Completed'];
    final current = raw == 'completed' ? 2 : raw == 'delivered' ? 1 : 0;

    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i <= current
                        ? const Color(0xFF34D399)
                        : AppColors.tertiary,
                    border: Border.all(
                      color: i <= current
                          ? const Color(0xFF34D399)
                          : AppColors.outline.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Icon(Icons.check_rounded,
                      size: 16,
                      color: i <= current ? AppColors.tertiary : Colors.transparent),
                ),
                const SizedBox(height: 6),
                Text(labels[i],
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: i == current ? FontWeight.w700 : FontWeight.w500,
                        color: i <= current ? Colors.white : AppColors.onTertiaryContainer)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}