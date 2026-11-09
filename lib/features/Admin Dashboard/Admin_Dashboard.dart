import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import 'admin_dashboard_header.dart';
import 'admin_dashboard_stats.dart';
import 'order_details_sheet.dart';
import 'project_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedFilter = 0;

  static const projects = [
    DashboardProject(
      name: 'ClinicFlow Pro',
      subtitle: 'Nile Health Group',
      category: 'Healthcare',
      amount: '8,500 EGP',
      date: 'Nov 12, 2024',
      status: 'Pending',
      icon: Icons.apartment_rounded,
      iconColor: AppColors.primaryContainer,
      iconBackground: AppColors.secondaryContainer,
    ),
    DashboardProject(
      name: 'ShopLite Mobile',
      subtitle: 'Top Market Logistics',
      category: 'E-commerce',
      amount: '6,000 EGP',
      date: 'Nov 12, 2024',
      status: 'Pending',
      icon: Icons.shopping_bag_outlined,
      iconColor: AppColors.onPrimaryContainer,
      iconBackground: AppColors.primaryFixed,
    ),
    DashboardProject(
      name: 'SupportBot AI',
      subtitle: 'Cairo FinTech Labs',
      category: 'AI & Automation',
      amount: '7,800 EGP',
      date: 'Oct 27, 2024',
      status: 'Paid',
      icon: Icons.chat_bubble_outline_rounded,
      iconColor: AppColors.secondary,
      iconBackground: AppColors.surfaceContainerLow,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth > 700 ? 32.0 : 18.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontal, 14, horizontal, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AdminDashboardHeader(),
                      const SizedBox(height: 18),
                      const AdminDashboardStats(),
                      const SizedBox(height: 18),
                      _buildFilters(),
                      const SizedBox(height: 14),
                      ...projects.map(
                        (project) => ProjectCard(
                          project: project,
                          onTap: () => _showOrderDetails(project),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const _FooterNote(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const labels = ['Pending Projects  2', 'Orders  12'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.borderOutline),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final active = selectedFilter == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedFilter = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? AppColors.secondaryContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      color: active ? AppColors.primaryContainer : AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showOrderDetails(DashboardProject project) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderDetailsSheet(project: project),
    );
  }
}

class _FooterNote extends StatelessWidget {
  const _FooterNote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.textSecondary),
        SizedBox(width: 5),
        Text(
          'Payouts are securely tracked and reviewed by admin',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 9),
        ),
      ],
    );
  }
}
