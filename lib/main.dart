import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:proven/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:proven/constants/bottom_nav.dart';
import 'package:proven/features/company/marketPlace/market_page.dart';
import 'package:proven/features/onBoarding/on_boarding.dart';
import 'package:proven/features/splash/splash_screen.dart';
import 'package:proven/features/auth/auth_flow.dart';
import 'package:proven/features/auth/auth_service.dart';
import 'package:proven/features/auth/email_verification_banner.dart';
import 'package:proven/features/auth/role_selection_screen.dart';
import 'package:proven/user_bottom_nav.dart' show BottomNavModel;
import 'package:proven/features/company/company_shell.dart';
import 'package:proven/features/creator/creator_shell.dart';
import 'package:proven/features/Admin Dashboard/Admin_Dashboard.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: kIsWeb ? webFirebaseOptions : null,
  );
  runApp(const MyApp());
}

enum _Stage {
  splash,
  retry, // could not read the account (no internet): try again
  onboarding,
  auth,
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

  // the role of the signed in user (read from Firestore): decides the home
  UserRole? _role;

  // a user who started sign up but did not finish (null = start from the top)
  SessionInfo? _unfinishedSession;

  final AuthService _authService = AuthService();

  late final List<Widget> _items = [
    MarketPage(),
    const Center(child: Text('Ai Matchmaker')),
    const Center(child: Text('Orders')),
    // temporary: the real Profile screen will have the Logout button
    Center(
      child: ElevatedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
      ),
    ),
  ];

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    setState(() {
      _currentIndex = 0;
      _role = null;
      _unfinishedSession = null;
      _stage = _Stage.auth;
    });
  }

  // Splash finished: is someone already signed in, and where did they stop?
  Future<void> _routeAfterSplash() async {
    try {
      final session = await _authService.currentSession();
      if (!mounted) return;

      setState(() {
        if (session == null) {
          _stage = _Stage.onboarding;
        } else if (!session.profileComplete) {
          _unfinishedSession = session;
          _stage = _Stage.auth;
        } else {
          _role = session.role;
          _currentIndex = 0;
          _stage = _Stage.home;
        }
      });
    } catch (_) {
      if (!mounted) return;
      // signed in but the role could not be read (no internet): retry screen
      setState(() {
        _stage = _authService.isSignedIn ? _Stage.retry : _Stage.onboarding;
      });
    }
  }

  // ---------------------------------------------------------------------
  // homes: one per role
  // ---------------------------------------------------------------------

Widget _buildHome() {
  switch (_role) {
    case UserRole.admin:
return AdminDashboard(
  key: const ValueKey('adminHome'),
  onLogout: _logout,
);

    case UserRole.creator:
      return CreatorShell(
        key: const ValueKey('creatorHome'),
        onLogout: _logout,
      );

    case UserRole.company:
      return CompanyShell(
        key: const ValueKey('companyHome'),
        onLogout: _logout,
      );

    case null:
      return const Scaffold(
        body: Center(
          child: Text('Invalid user role'),
        ),
      );
  }
}
  Widget _userHome() {
    return Scaffold(
      key: const ValueKey('home'),
      body: Column(
        children: [
          if (!_authService.isEmailVerified)
            SafeArea(
              bottom: false,
              child: EmailVerificationBanner(
                authService: _authService,
                onVerified: () => setState(() {}),
              ),
            ),
          Expanded(child: _items[_currentIndex]),
        ],
      ),
      bottomNavigationBar: FixedBottomNavBar(
        items: BottomNavModel.userBottomNavItems ??
            const <BottomNavModel>[],
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildStage() {
    switch (_stage) {
      case _Stage.splash:
        return SplashScreen(
          key: const ValueKey('splash'),
          onFinished: _routeAfterSplash,
        );

      case _Stage.retry:
        return Scaffold(
          key: const ValueKey('retry'),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 56),
                  const SizedBox(height: 16),
                  const Text(
                    'Could not load your account.\nCheck your internet and try again.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _stage = _Stage.splash);
                    },
                    child: const Text('Try again'),
                  ),
                  TextButton(
                    onPressed: _logout,
                    child: const Text('Log out'),
                  ),
                ],
              ),
            ),
          ),
        );

      case _Stage.onboarding:
        return OnboardingScreen(
          key: const ValueKey('onboarding'),
          onFinished: () => setState(() => _stage = _Stage.auth),
        );

      case _Stage.auth:
        return AuthFlow(
          key: const ValueKey('auth'),
          authService: _authService,
          initialSession: _unfinishedSession,
          onFinished: (role) {
            setState(() {
              _role = role;
              _currentIndex = 0;
              _unfinishedSession = null;
              _stage = _Stage.home;
            });
          },
        );

      case _Stage.home:
        return _buildHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Proven',
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: _buildStage(),
      ),
    );
  }
}

// temporary screen for the admin until the real admin screens exist
class _AdminHomePlaceholder extends StatelessWidget {
  const _AdminHomePlaceholder({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        actions: [
          IconButton(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: const Center(child: Text('Admin dashboard (coming soon)')),
    );
  }
}