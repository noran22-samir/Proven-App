import 'package:flutter/material.dart';

class BottomNavModel {
  const BottomNavModel({
    required this.title,
    required this.icon,
    IconData? activeIcon,
  }) : activeIcon = activeIcon ?? icon;

  final String title;
  final IconData icon; // not selected (outlined)
  final IconData activeIcon; // selected (filled)

  static const List<BottomNavModel> companyBottomNavItems = [
    BottomNavModel(
      title: 'Market',
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront_rounded,
    ),
    BottomNavModel(
      title: 'Matchmaker',
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome_rounded,
    ),
    BottomNavModel(
      title: 'Orders',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
    ),
    BottomNavModel(
      title: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  static const List<BottomNavModel> creatorBottomNavItems = [
    BottomNavModel(
      title: 'Projects',
      icon: Icons.space_dashboard_outlined,
      activeIcon: Icons.space_dashboard_rounded,
    ),
    BottomNavModel(
      title: 'Add',
      icon: Icons.add_circle_outline_rounded,
      activeIcon: Icons.add_circle_rounded,
    ),
    BottomNavModel(
      title: 'Requests',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
    ),
    BottomNavModel(
      title: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  // main.dart still references this getter
  static List<BottomNavModel>? get userBottomNavItems => null;
}
