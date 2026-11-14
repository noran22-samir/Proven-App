import 'package:flutter/material.dart';
import 'package:proven/constants/bottom_nav.dart';
import 'package:proven/features/marketPlace/market_page.dart';
import 'package:proven/features/onBoarding/on_boarding.dart';
import 'package:proven/features/parchase_request/presentation/screens/purchase_requests_screen.dart';
import 'package:proven/features/splash/splash_screen.dart';
import 'package:proven/features/my_project/presentation/screens/my_project_screen.dart';


void main() {
  runApp(const MyApp());
}

enum _Stage { splash, onboarding, home }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;
  _Stage _stage = _Stage.splash;

  final List<Widget> _items = [
    // MyProjectsScreen(),
    PurchaseRequestsScreen(),
    const Center(child: Text('add')),
    const Center(child: Text('Requests')),
    const Center(child: Text('Profile')),
  ];

  Widget _buildStage() {
    switch (_stage) {
      case _Stage.splash:
        return SplashScreen(
          key: const ValueKey('splash'),
          onFinished: () => setState(() => _stage = _Stage.onboarding),
        );
      case _Stage.onboarding:
        return OnboardingScreen(
          key: const ValueKey('onboarding'),
          // Later: go to Login (or straight to the role's home if signed in).
          onFinished: () => setState(() => _stage = _Stage.home),
        );
      case _Stage.home:
        return Scaffold(
          key: const ValueKey('home'),
          body: _items[_currentIndex],
          bottomNavigationBar: FixedBottomNavBar(
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Proven',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: _buildStage(),
      )
    );
  }
}
