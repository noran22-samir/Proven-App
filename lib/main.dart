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
import 'package:proven/features/auth/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: kIsWeb ? webFirebaseOptions : null);
  runApp(const MyApp());
}

enum _Stage { splash, onboarding, roleSelection, signUp, login, home }

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

  // login state
  bool _isLoggingIn = false;
  String? _loginError;

  final List<Widget> _items = [
    MarketPage(),
    const Center(child: Text('Ai Matchmaker')),
    const Center(child: Text('Orders')),
    const Center(child: Text('Profile')),
  ];

  String _signUpMessage(String code) {
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

  String _loginMessage(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Wrong email or password.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      case 'wrong-role':
        return 'This account is not registered with the selected role.';
      case 'profile-not-found':
        return 'Account data was not found. Please sign up again.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  Widget _buildStage() {
    switch (_stage) {
      case _Stage.splash:
        return SplashScreen(
          key: const ValueKey('splash'),
          onFinished: () {
            final user = FirebaseAuth.instance.currentUser;
            setState(() {
              _stage = user != null ? _Stage.home : _Stage.onboarding;
            });
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
              _loginError = null;
              _stage = _Stage.login;
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
                _currentIndex = 0;
                _stage = _Stage.home;
              });

              _messengerKey.currentState?.showSnackBar(
                const SnackBar(
                  content: Text('Account created successfully 🎉'),
                ),
              );
            } on FirebaseAuthException catch (e) {
              if (!mounted) return;

              setState(() {
                _isSigningUp = false;
                _signUpError = _signUpMessage(e.code);
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
              _loginError = null;
              _stage = _Stage.login;
            });
          },

          onBack: () {
            setState(() {
              _stage = _Stage.roleSelection;
            });
          },
        );

      case _Stage.login:
        return LoginScreen(
          key: const ValueKey('login'),

          role: _selectedRole!,
          isLoading: _isLoggingIn,
          errorMessage: _loginError,

          onSubmit: (data) async {
            setState(() {
              _isLoggingIn = true;
              _loginError = null;
            });

            try {
              await _authService.login(data.email, data.password, data.role);

              if (!mounted) return;

              setState(() {
                _isLoggingIn = false;
                _currentIndex = 0;
                _stage = _Stage.home;
              });
            } on FirebaseAuthException catch (e) {
              if (!mounted) return;

              setState(() {
                _isLoggingIn = false;
                _loginError = _loginMessage(e.code);
              });
            } catch (e) {
              if (!mounted) return;

              setState(() {
                _isLoggingIn = false;
                _loginError = 'Something went wrong. Please try again.';
              });
            }
          },

          onForgotPassword: (email) async {
            if (email.isEmpty) {
              _messengerKey.currentState?.showSnackBar(
                const SnackBar(content: Text('Enter your email first')),
              );
              return;
            }

            try {
              await _authService.sendPasswordReset(email);
              _messengerKey.currentState?.showSnackBar(
                const SnackBar(
                  content: Text(
                    'If this email is registered, a reset link has been sent. Check your inbox and spam.',
                  ),
                ),
              );
            } on FirebaseAuthException catch (e) {
              _messengerKey.currentState?.showSnackBar(
                SnackBar(content: Text(_loginMessage(e.code))),
              );
            } catch (e) {
              _messengerKey.currentState?.showSnackBar(
                const SnackBar(
                  content: Text('Something went wrong. Please try again.'),
                ),
              );
            }
          },

          onSignUp: () {
            setState(() {
              _signUpError = null;
              _stage = _Stage.signUp;
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

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    setState(() {
      _currentIndex = 0;
      _stage = _Stage.roleSelection;
    });
  }
}
