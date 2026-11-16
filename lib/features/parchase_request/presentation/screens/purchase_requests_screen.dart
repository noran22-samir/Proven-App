import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../widgets/contract_request_card.dart';

class PurchaseRequestsScreen extends StatelessWidget {
  const PurchaseRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tertiary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            // Creator role badge indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
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

                        // Subtitle describing the screen context
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
                  // Filter and search action buttons using a helper method
  //                 _buildHeaderIconButton(Icons.tune, () {
  //                   final options = ['All Contracts', 'Paid Only', 'Completed Only'];
  // showModalBottomSheet(
  //   context: context,
  //   backgroundColor: AppColors.tertiaryContainer,
  //   shape: const RoundedRectangleBorder(
  //     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //   ),
  //   builder: (context) => Padding(
  //     padding: const EdgeInsets.all(16),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: options.map((option) => ListTile(
  //         title: Text(option, style: const TextStyle(color: Colors.white)),
  //         trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.inversePrimary),
  //         onTap: () {
  //           Navigator.pop(context);
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text('Filter: $option', style: const TextStyle(color: Colors.white)),
  //               backgroundColor: AppColors.tertiaryContainer,
  //               behavior: SnackBarBehavior.floating,
  //               duration: const Duration(seconds: 2),
  //             ),
  //           );
  //         },
  //       )).toList(),
  //     ),
  //   ),
  // );

  //                 }),

                  const SizedBox(width: 8),
                  _buildHeaderIconButton(Icons.search, () {
                    showSearch(
                      context: context,
                      delegate: ContractSearchDelegate(),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),

              // Creator Balance Dashboard Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryContainer.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.outline.withOpacity(0.25),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        // Escrow active status indicator tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF34D399).withOpacity(0.4),
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

                    // statistics boxes for Total Earnings & Total Requests
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatBox(
                            title: 'Total Earnings',
                            mainValue: '21,450',
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
                            mainValue: '6',
                            unit: 'Acquisitions',
                            subIcon: Icons.check_circle_outline,
                            subText: '100% Fulfilled',
                            subColor: AppColors.inversePrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Bottom security and platform fee disclaimer strip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
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
                                color: AppColors.onTertiaryContainer,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const Text(
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
              //Recent Inbound Contracts Header
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Inbound Contractss',
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
                      color: AppColors.primaryContainer.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.inversePrimary.withOpacity(0.3),
                      ),
                    ),
                    child: const Text(
                      '2',
                      style: TextStyle(
                        color: AppColors.inversePrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: AppColors.tertiaryContainer,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) => Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),
                              // History list items
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  backgroundColor: AppColors.primaryContainer,
                                  child: const Text(
                                    'EG',
                                    style: TextStyle(
                                      color: AppColors.inversePrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: const Text(
                                  'Eagle Games - Game Development Studio',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Mar 25, 2025 • Completed',
                                  style: TextStyle(
                                    color: AppColors.onTertiaryContainer,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: const Text(
                                  '5,400 EGP',
                                  style: TextStyle(
                                    color: AppColors.inversePrimary,
                                    fontWeight: FontWeight.bold,
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
              //Contract Card 1: Nile Health Group//
              ContractRequestCard(
                initials: 'NH',
                companyName: 'Nile Health Group',
                companySubtitle: 'Enterprise Healthcare',
                status: 'Paid',
                statusColor: AppColors.inversePrimary,
                statusBgColor: AppColors.surfaceTint.withOpacity(0.15),
                date: 'Oct 24, 2024',
                projectTitle: 'ClinicFlow - Healthcare Suite',
                purchasePrice: '8,500 EGP',
                netReceive: '7,650 EGP',
                onDetailsTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Details: ClinicFlow - Healthcare Suite | 8,500 EGP',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppColors.tertiaryContainer,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),

              // --- Contract Card 2: Delta Retail Tech ---
              ContractRequestCard(
                initials: 'DR',
                companyName: 'Delta Retail Tech',
                companySubtitle: 'Commercial POS Solutions',
                status: 'Completed',
                statusColor: const Color(0xFF34D399),
                statusBgColor: const Color(0xFF10B981).withOpacity(0.15),
                date: 'Oct 19, 2024',
                projectTitle: 'RetailFlow - POS Terminal',
                purchasePrice: '6,200 EGP',
                netReceive: '5,580 EGP',
                onDetailsTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Details: RetailFlow - POS Terminal | 6,200 EGP',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppColors.tertiaryContainer,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build consistent round icon buttons in the header
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

  // Helper widget to build statistical metric cards inside the balance section
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

// Custom SearchDelegate for searching through contracts
class ContractSearchDelegate extends SearchDelegate {
  // A list of the contracts we will search through
 final List items = [
    {'company': 'Nile Health Group', 'project': 'ClinicFlow - Healthcare Suite', 'price': '8,500 EGP'},
    {'company': 'Delta Retail Tech', 'project': 'RetailFlow - POS Terminal', 'price': '6,200 EGP'},
  ];

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.tertiary,
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.tertiaryContainer),
    );
  }

  // Clear button (X) on the right
  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  // Back button (arrow) on the left
  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  // Results that appear while typing
  @override
  Widget buildSuggestions(BuildContext context) {
    final results = items.where((item) =>
        item['company']!.toLowerCase().contains(query.toLowerCase()) ||
        item['project']!.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(results[index]['company']!, style: const TextStyle(color: Colors.white)),
        subtitle: Text(results[index]['project']!, style: const TextStyle(color: Colors.grey)),
        trailing: Text(results[index]['price']!, style: const TextStyle(color: AppColors.inversePrimary)),
        onTap: () => close(context, null),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);
}