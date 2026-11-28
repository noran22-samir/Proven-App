import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proven/features/auth/auth_service.dart';
import 'package:proven/features/auth/login.dart';
import 'package:proven/features/auth/profile_details.dart';
import 'package:proven/features/auth/role_selection_screen.dart';
import 'package:proven/features/auth/signup.dart';
import 'package:proven/features/auth/verify_email.dart';

enum _AuthStage {
  roleSelection,
  signUp, // step 1: email and password (or Google)
  verifyEmail, // step 2: open the link we emailed
  completeProfile, // step 3: name, phone...
  login,
}

class AuthFlow extends StatefulWidget {
  const AuthFlow({
    super.key,
    required this.authService,
    required this.onFinished,
    this.initialSession,
  });

  final AuthService authService;

  // It gives the role (creator / company / admin) so the app can show the
  final ValueChanged<UserRole> onFinished;

  // a signed in user who did not finish sign up: continue from where he stopped
  final SessionInfo? initialSession;

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  _AuthStage _stage = _AuthStage.roleSelection;
  UserRole? _role;
  String _pendingEmail = '';

  bool _isSigningUp = false;
  bool _signUpWithGoogleBusy = false;
  String? _signUpError;

  bool _isSavingProfile = false;
  String? _profileError;

  bool _isLoggingIn = false;
  bool _loginWithGoogleBusy = false;
  String? _loginError;

  AuthService get _auth => widget.authService;

  @override
  void initState() {
    super.initState();
    final s = widget.initialSession;
    if (s != null) {
      _role = s.role;
      _pendingEmail = s.email;
      _stage = s.emailVerified
          ? _AuthStage.completeProfile
          : _AuthStage.verifyEmail;
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ---------------------------------------------------------------------
  // error messages
  // ---------------------------------------------------------------------

  // Google errors are the same on the login and the sign up screens
  String? _googleMessage(String code) {
    switch (code) {
      case 'google-not-configured':
        return 'Google sign-in is not set up yet.';
      case 'google-failed':
      case 'google-no-token':
        return 'Google sign-in failed. Please try again.';
      case 'account-exists-with-different-credential':
        return 'This email is registered with a password. '
            'Log in with email and password.';
      default:
        return null;
    }
  }

  String _signUpMessage(String code) {
    final google = _googleMessage(code);
    if (google != null) return google;

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

  String _profileMessage(String code) {
    switch (code) {
      case 'email-not-verified':
        return 'Please verify your email first.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      default:
        return 'Could not save your details. Please try again.';
    }
  }

  String _loginMessage(String code) {
    final google = _googleMessage(code);
    if (google != null) return google;

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
      case 'profile-not-found':
        return 'Account data not found. Please contact support.';
      case 'email-not-verified':
        return 'Please verify your email first. We just sent you a new link.';
      case 'google-not-registered':
        return 'No account found for this Google email. Please sign up first.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  // ---------------------------------------------------------------------
  // actions
  // ---------------------------------------------------------------------

  // same for email login, Google login and Google sign up
  void _applyResult(LoginResult r) {
    if (!mounted) return;

    if (r.outcome == LoginOutcome.ok) {
      widget.onFinished(r.role);
      return;
    }

    setState(() {
      _role = r.role;
      _pendingEmail = _auth.currentEmail;
      _profileError = null;
      _stage = r.outcome == LoginOutcome.verifyEmail
          ? _AuthStage.verifyEmail
          : _AuthStage.completeProfile;
    });
  }

  Future<void> _signUpWithEmail(AccountData data) async {
    setState(() {
      _isSigningUp = true;
      _signUpError = null;
    });

    try {
      await _auth.createAccount(data);
      if (!mounted) return;
      setState(() {
        _isSigningUp = false;
        _pendingEmail = data.email;
        _stage = _AuthStage.verifyEmail;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSigningUp = false;
        _signUpError = _signUpMessage(e.code);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSigningUp = false;
        _signUpError = 'Something went wrong. Please try again.';
      });
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isSigningUp = true;
      _signUpWithGoogleBusy = true;
      _signUpError = null;
    });

    try {
      final result = await _auth.signUpWithGoogle(_role!);
      if (!mounted) return;
      setState(() {
        _isSigningUp = false;
        _signUpWithGoogleBusy = false;
      });
      _applyResult(result);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSigningUp = false;
        _signUpWithGoogleBusy = false;
        if (e.code != 'google-cancelled') {
          _signUpError = _signUpMessage(e.code);
        }
      });
      if (e.code == 'google-cancelled') {
        _showSnack('Google sign-in was cancelled.');
      }
    } catch (e) {
      debugPrint('Google sign up error: $e');
      if (!mounted) return;
      setState(() {
        _isSigningUp = false;
        _signUpWithGoogleBusy = false;
        _signUpError = 'Something went wrong. Please try again.';
      });
    }
  }

  Future<void> _loginWithEmail(LoginData data) async {
    setState(() {
      _isLoggingIn = true;
      _loginError = null;
    });

    try {
      final result = await _auth.login(data.email, data.password);
      if (!mounted) return;
      setState(() => _isLoggingIn = false);
      _applyResult(result);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoggingIn = false;
        _loginError = _loginMessage(e.code);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoggingIn = false;
        _loginError = 'Something went wrong. Please try again.';
      });
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoggingIn = true;
      _loginWithGoogleBusy = true;
      _loginError = null;
    });

    try {
      final result = await _auth.loginWithGoogle();
      if (!mounted) return;
      setState(() {
        _isLoggingIn = false;
        _loginWithGoogleBusy = false;
      });
      _applyResult(result);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoggingIn = false;
        _loginWithGoogleBusy = false;
        if (e.code != 'google-cancelled') {
          _loginError = _loginMessage(e.code);
        }
      });
      if (e.code == 'google-cancelled') {
        _showSnack('Google sign-in was cancelled.');
      }
    } catch (e) {
      debugPrint('Google login error: $e');
      if (!mounted) return;
      setState(() {
        _isLoggingIn = false;
        _loginWithGoogleBusy = false;
        _loginError = 'Something went wrong. Please try again.';
      });
    }
  }

  Future<void> _forgotPassword(String email) async {
    if (email.isEmpty) {
      _showSnack('Enter your email first');
      return;
    }

    try {
      await _auth.sendPasswordReset(email);
      _showSnack(
        'If this email is registered, a reset link has been sent. '
        'Check your inbox and spam.',
      );
    } on FirebaseAuthException catch (e) {
      _showSnack(_loginMessage(e.code));
    } catch (_) {
      _showSnack('Something went wrong. Please try again.');
    }
  }

  Future<void> _saveProfile(SignUpData data) async {
    setState(() {
      _isSavingProfile = true;
      _profileError = null;
    });

    try {
      await _auth.completeProfile(data);
      if (!mounted) return;
      setState(() => _isSavingProfile = false);
      _showSnack('Welcome to Proven 🎉');
      widget.onFinished(data.role);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSavingProfile = false;
        _profileError = _profileMessage(e.code);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSavingProfile = false;
        _profileError = _profileMessage('unknown');
      });
    }
  }

  // phone back button: go back one screen (not on verify / details)
  void _goBack() {
    if (_stage == _AuthStage.signUp || _stage == _AuthStage.login) {
      setState(() => _stage = _AuthStage.roleSelection);
    }
  }

  // ---------------------------------------------------------------------
  // screens
  // ---------------------------------------------------------------------

  Widget _buildStage() {
    switch (_stage) {
      case _AuthStage.roleSelection:
        return RoleSelectionScreen(
          key: const ValueKey('roleSelection'),
          onCreateAccount: (role) {
            setState(() {
              _role = role;
              _signUpError = null;
              _stage = _AuthStage.signUp;
            });
          },
          onLogin: () {
            setState(() {
              _loginError = null;
              _stage = _AuthStage.login;
            });
          },
        );

      case _AuthStage.signUp:
        return SignUpScreen(
          key: const ValueKey('signUp'),
          role: _role!,
          isLoading: _isSigningUp,
          isGoogleLoading: _signUpWithGoogleBusy,
          errorMessage: _signUpError,
          onSubmit: _signUpWithEmail,
          onGoogle: _signUpWithGoogle,
          onLogin: () {
            setState(() {
              _loginError = null;
              _stage = _AuthStage.login;
            });
          },
          onBack: () {
            setState(() => _stage = _AuthStage.roleSelection);
          },
        );

      case _AuthStage.verifyEmail:
        return VerifyEmailScreen(
          key: const ValueKey('verifyEmail'),
          email: _pendingEmail,
          onCheck: _auth.refreshEmailVerified,
          onResend: _auth.resendVerificationEmail,
          onVerified: () {
            if (!mounted) return;
            setState(() {
              _profileError = null;
              _stage = _AuthStage.completeProfile;
            });
            _showSnack('Email verified. One last step!');
          },
          onChangeEmail: () async {
            await _auth.cancelUnfinishedSignup();
            if (!mounted) return;
            setState(() {
              _signUpError = null;
              _stage = _AuthStage.signUp;
            });
          },
        );

      case _AuthStage.completeProfile:
        return ProfileDetailsScreen(
          key: const ValueKey('completeProfile'),
          role: _role!,
          isLoading: _isSavingProfile,
          errorMessage: _profileError,
          onSubmit: _saveProfile,
          // log out: the user can finish the details later by logging in
          onBack: () async {
            await _auth.logout();
            if (!mounted) return;
            setState(() => _stage = _AuthStage.roleSelection);
            _showSnack('You can finish your details later by logging in.');
          },
        );

      case _AuthStage.login:
        return LoginScreen(
          key: const ValueKey('login'),
          isLoading: _isLoggingIn,
          isGoogleLoading: _loginWithGoogleBusy,
          errorMessage: _loginError,
          onSubmit: _loginWithEmail,
          onGoogle: _loginWithGoogle,
          onForgotPassword: _forgotPassword,
          onSignUp: () {
            setState(() => _stage = _AuthStage.roleSelection);
          },
          onBack: () {
            setState(() => _stage = _AuthStage.roleSelection);
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // on the first screen the phone back button closes the app as usual
      canPop: _stage == _AuthStage.roleSelection,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _buildStage(),
      ),
    );
  }
}