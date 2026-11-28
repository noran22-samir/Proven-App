// المسار: lib/features/creator/purchase_requests/presentation/screens/purchase_requests_screen.dart   (بدّل الملف كله)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/colors.dart';
import '../../cubit/purchase_request_cubit.dart';
import '../../cubit/purchase_request_state.dart';
import '../widgets/contract_details_sheet.dart';
import '../widgets/request_card.dart';

class PurchaseRequestsScreen extends StatelessWidget {
  const PurchaseRequestsScreen({super.key});

  static const _green = Color(0xFF34D399);
  static const _amber = Color(0xFFF1C65D);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PurchaseRequestCubit(),
      child: BlocBuilder<PurchaseRequestCubit, PurchaseRequestState>(
        builder: (context, state) {
          final cubit = context.read<PurchaseRequestCubit>();
          return Scaffold(
            backgroundColor: AppColors.tertiary,
            body: SafeArea(child: _content(context, cubit, state)),
          );
        },
      ),
    );
  }

  Widget _content(BuildContext context, PurchaseRequestCubit cubit, PurchaseRequestState state) {
    if (state is PurchaseRequestLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is PurchaseRequestError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(state.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onTertiaryContainer)),
        ),
      );
    }

    final shown = cubit.visible;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Text('Purchase Requests',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.inversePrimary.withValues(alpha: 0.3)),
              ),
              child: const Text('CREATOR',
                  style: TextStyle(
                      color: AppColors.inversePrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
            ),
            const Spacer(),
            _IconBtn(
              icon: Icons.search,
              onTap: () => showSearch(
                context: context,
                delegate: _ContractSearch(context, cubit),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Escrow payouts & graduation IP sales',
            style: TextStyle(color: AppColors.onTertiaryContainer, fontSize: 13)),
        const SizedBox(height: 18),
        _balanceCard(cubit),
        const SizedBox(height: 20),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: PurchaseRequestCubit.filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = PurchaseRequestCubit.filters[i];
              final sel = cubit.selectedFilter == f;
              return GestureDetector(
                onTap: () => cubit.changeFilter(f),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primaryContainer
                        : AppColors.tertiaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel
                          ? AppColors.inversePrimary
                          : AppColors.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(f,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : AppColors.onTertiaryContainer)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (shown.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                const Icon(Icons.receipt_long_outlined,
                    size: 48, color: AppColors.onTertiaryContainer),
                const SizedBox(height: 10),
                Text(
                  cubit.contracts.isEmpty
                      ? 'No purchase requests yet.\nWhen a company buys your project it appears here.'
                      : 'No requests in this filter.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.onTertiaryContainer, height: 1.4),
                ),
              ],
            ),
          )
        else
          for (final item in shown) _card(context, cubit, item),
      ],
    );
  }

  Widget _card(BuildContext context, PurchaseRequestCubit cubit, Map<String, dynamic> item) {
    final raw = '${item['raw']}';
    final color = raw == 'completed'
        ? _green
        : raw == 'delivered'
            ? _amber
            : AppColors.inversePrimary;

    return RequestCard(
      initials: item['initials'],
      companyName: item['companyName'],
      companySubtitle: item['companySubtitle'],
      status: item['status'],
      statusColor: color,
      date: item['date'],
      projectTitle: item['projectTitle'],
      purchasePrice: item['purchasePrice'],
      netReceive: item['netReceive'],
      onDetailsTap: () => ContractDetailsSheet.show(context, cubit, item),
    );
  }

  Widget _balanceCard(PurchaseRequestCubit cubit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  color: AppColors.inversePrimary, size: 20),
              SizedBox(width: 8),
              Text('Creator Balance',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  title: 'Paid out',
                  value: cubit.totalEarnings,
                  unit: 'EGP',
                  note: 'Released by admin',
                  noteColor: _green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  title: 'In escrow',
                  value: cubit.inEscrow,
                  unit: 'EGP',
                  note: '${cubit.totalRequests} requests total',
                  noteColor: AppColors.inversePrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.lock_outline, color: Color(0xFF818CF8), size: 15),
              SizedBox(width: 6),
              Expanded(
                child: Text('Protected by Proven escrow · 10% platform fee',
                    style: TextStyle(color: AppColors.onTertiaryContainer, fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.title,
    required this.value,
    required this.unit,
    required this.note,
    required this.noteColor,
  });

  final String title, value, unit, note;
  final Color noteColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tertiary.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: AppColors.onTertiaryContainer, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              ),
              const SizedBox(width: 4),
              Text(unit,
                  style: const TextStyle(
                      color: AppColors.onTertiaryContainer,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: noteColor, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.tertiaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: AppColors.inversePrimary, size: 20),
      ),
    );
  }
}

class _ContractSearch extends SearchDelegate {
  _ContractSearch(this.parentContext, this.cubit);
  final BuildContext parentContext;
  final PurchaseRequestCubit cubit;

  @override
  ThemeData appBarTheme(BuildContext context) => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.tertiary,
        appBarTheme: const AppBarTheme(backgroundColor: AppColors.tertiaryContainer),
      );

  @override
  List<Widget>? buildActions(BuildContext context) =>
      [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildSuggestions(BuildContext context) {
    final q = query.toLowerCase();
    final results = cubit.contracts
        .where((c) =>
            '${c['companyName']}'.toLowerCase().contains(q) ||
            '${c['projectTitle']}'.toLowerCase().contains(q))
        .toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('No matching requests',
            style: TextStyle(color: AppColors.onTertiaryContainer)),
      );
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) => ListTile(
        title: Text('${results[i]['companyName']}'),
        subtitle: Text('${results[i]['projectTitle']}',
            style: const TextStyle(color: AppColors.onTertiaryContainer)),
        trailing: Text('${results[i]['purchasePrice']}',
            style: const TextStyle(color: AppColors.inversePrimary)),
        onTap: () {
          close(context, null);
          ContractDetailsSheet.show(parentContext, cubit, results[i]);
        },
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);
}