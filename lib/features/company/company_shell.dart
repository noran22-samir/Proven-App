// PATH: lib/features/company/company_shell.dart
// ACTION: REPLACE the existing file (same place).
import 'package:flutter/material.dart';
import 'package:proven/constants/bottom_nav.dart';
import 'package:proven/user_bottom_nav.dart';
import 'package:proven/features/company/ai_matchMaker/ai_matchmaker_screen.dart';
import 'package:proven/features/company/ai_matchMaker/matchmaker_service.dart';
import 'package:proven/features/company/marketPlace/market_page.dart';
import 'package:proven/features/orders/company_orders_screen.dart';
import 'package:proven/features/company/project_details/company_project_details_page.dart';
import 'package:proven/features/profile/profile_screen.dart';

class CompanyShell extends StatefulWidget {
  const CompanyShell({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<CompanyShell> createState() => _CompanyShellState();
}

class _CompanyShellState extends State<CompanyShell> {
  int _currentIndex = 0;

  final _matchmaker = MatchmakerService();

  static const _ordersTab = 2;

  void _goTo(int index) {
    if (mounted) setState(() => _currentIndex = index);
  }

  // used by the Market cards and by the Matchmaker results
  void _openProject(String id) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CompanyProjectDetailsPage(
          projectId: id,
          onViewOrders: () => _goTo(_ordersTab),
        ),
      ),
    );
  }

  late final List<Widget> _pages = [
    MarketPage(
      onOpenMatchmaker: () => _goTo(1),
      onOpenProject: _openProject,
    ),
    AiMatchmakerScreen(service: _matchmaker, onOpenProject: _openProject),
    const CompanyOrdersScreen(),
    ProfileScreen(onLogout: widget.onLogout),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: FixedBottomNavBar(
        items: BottomNavModel.companyBottomNavItems,
        currentIndex: _currentIndex,
        onTap: _goTo,
      ),
    );
  }
}