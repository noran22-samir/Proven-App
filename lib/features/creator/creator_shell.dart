// المسار: lib/features/creator/creator_shell.dart   (بدّل الملف كله)
import 'package:flutter/material.dart';
import 'package:proven/constants/bottom_nav.dart';
import 'package:proven/user_bottom_nav.dart';
import 'package:proven/features/creator/Add Project/add_project_page.dart';
import 'package:proven/features/creator/my_project/presentation/screens/my_project_screen.dart';
import 'package:proven/features/creator/purchase_requests/presentation/screens/purchase_requests_screen.dart';
import 'package:proven/features/profile/profile_screen.dart';

class CreatorShell extends StatefulWidget {
  const CreatorShell({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<CreatorShell> createState() => _CreatorShellState();
}

class _CreatorShellState extends State<CreatorShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    MyProjectsScreen(onAddProject: () => setState(() => _currentIndex = 1)),
    const AddProjectPage(),
    const PurchaseRequestsScreen(),
    ProfileScreen(onLogout: widget.onLogout),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: FixedBottomNavBar(
        items: BottomNavModel.creatorBottomNavItems,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}