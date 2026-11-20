import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:proven/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proven/constants/bottom_nav.dart';
import 'package:proven/features/marketPlace/market_page.dart';
import 'package:proven/features/onBoarding/on_boarding.dart';
import 'package:proven/features/splash/splash_screen.dart';
import 'package:proven/features/auth/role_selection_screen.dart';
import 'package:proven/features/auth/signup.dart';
import 'package:proven/features/auth/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: kIsWeb ? webFirebaseOptions : null,
  );
  runApp(const MyApp());
}

enum _Stage { splash, onboarding, roleSelection, signUp, home }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;
  _Stage _stage = _Stage.splash;

  UserRole? _selectedRole;

  final AuthService _authService = AuthService();

  // used to show the SnackBar from outside the MaterialApp
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  // sign up state
  bool _isSigningUp = false;
  String? _signUpError;

  final List<Widget> _items = [
    MarketPage(),
    const Center(child: Text('Ai Matchmaker')),
    const Center(child: Text('Orders')),
    const Center(child: Text('Profile')),
  ];

  String _authMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      default:
        return 'Registration failed. Please try again.';
    }
  }

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
              _signUpError = null;
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
          isLoading: _isSigningUp,
          errorMessage: _signUpError,

          onSubmit: (data) async {
            setState(() {
              _isSigningUp = true;
              _signUpError = null;
            });

            try {
              await _authService.createAccount(data);

              if (!mounted) return;

              setState(() {
                _isSigningUp = false;
                _stage = _Stage.home;
              });

              _messengerKey.currentState?.showSnackBar(
                const SnackBar(content: Text('Account created successfully 🎉')),
              );
            } on FirebaseAuthException catch (e) {
              if (!mounted) return;

              setState(() {
                _isSigningUp = false;
                _signUpError = _authMessage(e.code);
              });
            } catch (e) {
              if (!mounted) return;

              setState(() {
                _isSigningUp = false;
                _signUpError = 'Something went wrong. Please try again.';
              });
            }
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
      scaffoldMessengerKey: _messengerKey,
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