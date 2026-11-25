import 'package:flutter/material.dart';
import 'package:proven/constants/bottom_nav.dart';
import 'package:proven/user_bottom_nav.dart';
import 'package:proven/features/company/marketPlace/market_page.dart';
import 'package:proven/features/company/profile/company_profile.dart';
class CompanyShell extends StatefulWidget {
  const CompanyShell({
    super.key,
    required this.onLogout,
  });

  final VoidCallback onLogout;

  @override
  State<CompanyShell> createState() => _CompanyShellState();
}

class _CompanyShellState extends State<CompanyShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
  const MarketPage(),
  const Center(child: Text('AI Matchmaker')),
  const Center(child: Text('Orders')),
CompanyProfile(
  onLogout: widget.onLogout,
),];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: FixedBottomNavBar(
        items: BottomNavModel.companyBottomNavItems,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}