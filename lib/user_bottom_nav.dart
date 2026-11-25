import 'package:flutter/material.dart';


class BottomNavModel {
  final String title;
  final IconData icon;

  const BottomNavModel({
    required this.title,
    required this.icon,
  });

  static const List<BottomNavModel> companyBottomNavItems = [
    BottomNavModel(
      title: 'Market',
      icon: Icons.storefront_outlined,
    ),
    BottomNavModel(
      title: 'Matchmaker',
      icon: Icons.auto_awesome,
    ),
    BottomNavModel(
      title: 'Orders',
      icon: Icons.receipt_long_outlined,
    ),
    BottomNavModel(
      title: 'Profile',
      icon: Icons.person_outline,
    ),
  ];

  static const List<BottomNavModel> creatorBottomNavItems = [
    BottomNavModel(
      title: 'Projects',
      icon: Icons.folder_outlined,
    ),
    BottomNavModel(
      title: 'Add Project',
      icon: Icons.add_box_outlined,
    ),
    BottomNavModel(
      title: 'Requests',
      icon: Icons.inbox_outlined,
    ),
    BottomNavModel(
      title: 'Profile',
      icon: Icons.person_outline,
    ),
  ];

  static const List<BottomNavModel> adminBottomNavItems = [
    BottomNavModel(
      title: 'Dashboard',
      icon: Icons.dashboard_outlined,
    ),
    BottomNavModel(
      title: 'Projects',
      icon: Icons.folder_outlined,
    ),
    BottomNavModel(
      title: 'Orders',
      icon: Icons.receipt_long_outlined,
    ),
    BottomNavModel(
      title: 'Profile',
      icon: Icons.person_outline,
    ),
  ];

  static List<BottomNavModel>? get userBottomNavItems => null;
}