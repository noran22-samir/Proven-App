
import 'package:flutter/material.dart';
import 'package:proven/constants/bottom_nav.dart';
import 'package:proven/features/marketPlace/market_page.dart';
import 'package:proven/features/onBoarding/on_boarding.dart';
import 'package:proven/features/splash/splash_screen.dart';
import 'package:proven/features/auth/role_selection_screen.dart';
import 'package:proven/features/auth/signup.dart';

import 'features/Add Project/clinicflow_app.dart';

void main() {
  runApp(const MyApp());
}

enum _Stage {
  splash,
  onboarding,
  roleSelection,
  signUp,
  home,
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;
  _Stage _stage = _Stage.splash;

  UserRole? _selectedRole;

  final List<Widget> _items = [
    MarketPage(),
    const Center(child: Text('Ai Matchmaker')),
    const Center(child: Text('Orders')),
    const Center(child: Text('Profile')),
  ];

  Widget _buildStage() {
    switch (_stage) {
      case _Stage.splash:
        return SplashScreen(
          key: const ValueKey('splash'),
          onFinished: () {
            setState(() => _stage = _Stage.onboarding);
          },
        );

      case _Stage.onboarding:
        return OnboardingScreen(
          key: const ValueKey('onboarding'),
          onFinished: () {
            setState(() => _stage = _Stage.roleSelection);
          },
        );

      case _Stage.roleSelection:
        return RoleSelectionScreen(
          key: const ValueKey('roleSelection'),

          onCreateAccount: (role) {
            setState(() {
              _selectedRole = role;
              _stage = _Stage.signUp;
            });
          },

          onLogin: (role) {
            setState(() {
              _selectedRole = role;
              _stage = _Stage.home;
            });
          },
        );

      case _Stage.signUp:
        return SignUpScreen(
          key: const ValueKey('signUp'),

          role: _selectedRole!,

          onSubmit: (data) {
            // TODO: Send SignUpData to Firebase
            setState(() {
              _stage = _Stage.home;
            });
          },

          onLogin: () {
            setState(() {
              _stage = _Stage.home;
            });
          },

          onBack: () {
            setState(() {
              _stage = _Stage.roleSelection;
            });
          },
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
      ),
    );
  }
}
