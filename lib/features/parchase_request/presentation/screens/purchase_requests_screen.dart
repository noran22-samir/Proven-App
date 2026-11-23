import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/colors.dart';
import '../../cubit/purchase_request_cubit.dart';
import '../../cubit/purchase_request_state.dart';
import '../widgets/contract_request_card.dart';

class PurchaseRequestsScreen extends StatelessWidget {
  const PurchaseRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PurchaseRequestCubit(),
      child: BlocBuilder<PurchaseRequestCubit, PurchaseRequestState>(
        builder: (context, state) {
          final cubit = context.read<PurchaseRequestCubit>();

          //Preparing the list of offered contracts
          List displayedContracts = cubit.contracts;
          if (cubit.selectedFilter == 'Paid Only') {
            displayedContracts = cubit.contracts
                .where((c) => c['status'] == 'Paid')
                .toList();
          } else if (cubit.selectedFilter == 'Completed Only') {
            displayedContracts = cubit.contracts
                .where((c) => c['status'] == 'Completed')
                .toList();
          }

          return Scaffold(
            backgroundColor: AppColors.tertiary,
            body: state is PurchaseRequestLoading
                ? const Center(child: CircularProgressIndicator())
                : state is PurchaseRequestError
                ? Center(
                    child: Text(
                      state.errorMessage,
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Top Header
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Purchase Requests',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryContainer
                                                .withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: AppColors.inversePrimary
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: const Text(
                                            'CREATOR',
                                            style: TextStyle(
                                              color: AppColors.inversePrimary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Escrow payouts & graduation IP sales',
                                      style: TextStyle(
                                        color: AppColors.onTertiaryContainer,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Filter button
                              _buildHeaderIconButton(Icons.tune, () {
                                final options = [
                                  'All Contracts',
                                  'Paid Only',
                                  'Completed Only',
                                ];
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: AppColors.tertiaryContainer,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (sheetContext) => Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: options.map((option) {
                                        bool isSelected =
                                            cubit.selectedFilter == option;
                                        return ListTile(
                                          title: Text(
                                            option,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          trailing: Icon(
                                            isSelected
                                                ? Icons.check_circle
                                                : Icons.arrow_forward_ios,
                                            size: 16,
                                            color: AppColors.inversePrimary,
                                          ),
                                          onTap: () {
                                            //change the filter
                                            cubit.changeFilter(option);
                                            Navigator.pop(sheetContext);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Filter: $option',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                backgroundColor:
                                                    AppColors.tertiaryContainer,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              }),

                              const SizedBox(width: 8),

                              //Search button
                              _buildHeaderIconButton(Icons.search, () {
                                showSearch(
                                  context: context,
                                  delegate: ContractSearchDelegate(
                                    cubit.contracts,
                                  ),
                                );
                              }),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Creator Balance
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.tertiaryContainer.withOpacity(
                                0.45,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.outline.withOpacity(0.25),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet_outlined,
                                          color: AppColors.inversePrimary,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Creator Balance',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF10B981,
                                        ).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(
                                            0xFF34D399,
                                          ).withOpacity(0.4),
                                        ),
                                      ),
                                      child: const Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 3,
                                            backgroundColor: Color(0xFF34D399),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Escrow Active',
                                            style: TextStyle(
                                              color: Color(0xFF34D399),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                //Statistics cards
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatBox(
                                        title: 'Total Earnings',
                                        mainValue: cubit.totalEarnings,
                                        unit: 'EGP',
                                        subIcon: Icons.trending_up,
                                        subText: '+33% this cycle',
                                        subColor: const Color(0xFF34D399),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatBox(
                                        title: 'Total Requests',
                                        mainValue: cubit.totalRequests,
                                        unit: 'Acquisitions',
                                        subIcon: Icons.check_circle_outline,
                                        subText: '100% Fulfilled',
                                        subColor: AppColors.inversePrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.lock_outline,
                                          color: Color(0xFF818CF8),
                                          size: 15,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Protected by Proven Institutional Vault',
                                          style: TextStyle(
                                            color:
                                                AppColors.onTertiaryContainer,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '10% Platform Fee',
                                      style: TextStyle(
                                        color: AppColors.inversePrimary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Second part (Recent inbound + history button)
                          Row(
                            children: [
                              const Text(
                                'Recent Inbound Contracts',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer.withOpacity(
                                    0.6,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.inversePrimary.withOpacity(
                                      0.3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  // Displays the number of contracts currently visible
                                  '${displayedContracts.length}',
                                  style: const TextStyle(
                                    color: AppColors.inversePrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),

                              // History button
                              TextButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor:
                                        AppColors.tertiaryContainer,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder: (sheetContext) => Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Purchase Request History',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () => Navigator.of(
                                                  sheetContext,
                                                ).pop(),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          ...cubit.historyItems.map(
                                            (history) => ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    AppColors.primaryContainer,
                                                child: Text(
                                                  history['initials'],
                                                  style: const TextStyle(
                                                    color: AppColors
                                                        .inversePrimary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                history['title'],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              subtitle: Text(
                                                history['subtitle'],
                                                style: const TextStyle(
                                                  color: AppColors
                                                      .onTertiaryContainer,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              trailing: Text(
                                                history['amount'],
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.inversePrimary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                ),
                                child: const Text(
                                  'History',
                                  style: TextStyle(
                                    color: AppColors.inversePrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 13),

                          // Contract cards displayed after filtering
                          if (displayedContracts.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'No contracts in this filter',
                                  style: TextStyle(
                                    color: AppColors.onTertiaryContainer,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...List.generate(displayedContracts.length, (
                              index,
                            ) {
                              var item = displayedContracts[index];
                              bool isPaid = item['status'] == 'Paid';

                              return ContractRequestCard(
                                initials: item['initials'],
                                companyName: item['companyName'],
                                companySubtitle: item['companySubtitle'],
                                status: item['status'],
                                statusColor: isPaid
                                    ? AppColors.inversePrimary
                                    : const Color(0xFF34D399),
                                statusBgColor: isPaid
                                    ? AppColors.surfaceTint.withOpacity(0.15)
                                    : const Color(0xFF10B981).withOpacity(0.15),
                                date: item['date'],
                                projectTitle: item['projectTitle'],
                                purchasePrice: item['purchasePrice'],
                                netReceive: item['netReceive'],
                                // Details Button
                                onDetailsTap: () {
                                  cubit.selectContract(index);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Details: ${item['projectTitle']} | ${item['purchasePrice']}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor:
                                          AppColors.tertiaryContainer,
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.tertiaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline.withOpacity(0.25)),
        ),
        child: Icon(icon, color: AppColors.inversePrimary, size: 20),
      ),
    );
  }

  Widget _buildStatBox({
    required String title,
    required String mainValue,
    required String unit,
    required IconData subIcon,
    required String subText,
    required Color subColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tertiary.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.onTertiaryContainer,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                mainValue,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  color: AppColors.onTertiaryContainer,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(subIcon, color: subColor, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  subText,
                  style: TextStyle(
                    color: subColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ContractSearchDelegate extends SearchDelegate {
  final List items;

  ContractSearchDelegate(this.items);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.tertiary,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.tertiaryContainer,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = items
        .where(
          (item) =>
              item['companyName'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              item['projectTitle'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(
          results[index]['companyName'],
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          results[index]['projectTitle'],
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Text(
          results[index]['purchasePrice'],
          style: const TextStyle(color: AppColors.inversePrimary),
        ),
        onTap: () => close(context, null),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);
}
