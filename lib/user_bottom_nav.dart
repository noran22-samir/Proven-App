import 'package:flutter/material.dart';
import 'package:proven/constants/bottom_nav.dart';

class UserBottomNav extends StatefulWidget {
  const UserBottomNav({super.key});

  @override
  State<UserBottomNav> createState() => _UserBottomNavState();
}

class _UserBottomNavState extends State<UserBottomNav> {

  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body:_getPages()[_currentIndex],
      bottomNavigationBar: FixedBottomNavBar(
        items: BottomNavModel.userBottomNavItems,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
              _currentIndex = index;
          });
        },
      ),
    );
  }


  List<Widget> _getPages() {
    return [
      const Center(child: Text('Home Page')),
      const Center(child: Text('Search Page')),
      const Center(child: Text('Profile Page')),
    ];
  }
}

class BottomNavModel {
  final String title;
  final IconData icon;

  BottomNavModel({required this.title, required this.icon});

  static List<BottomNavModel> get userBottomNavItems => [
    BottomNavModel(title: 'Home', icon: Icons.home),
    BottomNavModel(title: 'Search', icon: Icons.search),
    BottomNavModel(title: 'Profile', icon: Icons.person),
  ];
  static List<BottomNavModel> get adminBottomNavItems => [
    BottomNavModel(title: 'Home', icon: Icons.home),
    BottomNavModel(title: 'Search', icon: Icons.search),
    BottomNavModel(title: 'Profile', icon: Icons.person),
  ];
}
