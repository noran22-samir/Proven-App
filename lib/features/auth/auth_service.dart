import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:proven/features/auth/signup.dart';
import 'package:proven/features/auth/role_selection_screen.dart';

enum LoginOutcome {
  ok, // everything is complete: go to the home screen
  verifyEmail, // sign up was not finished: the email is not verified yet
  completeProfile, // the email is verified but the details are missing
}

class LoginResult {
  final LoginOutcome outcome;
  final UserRole role;
  const LoginResult(this.outcome, this.role);
}

class SessionInfo {
  final UserRole role;
  final String email;
  final bool emailVerified;
  final bool profileComplete;

  const SessionInfo({
    required this.role,
    required this.email,
    required this.emailVerified,
    required this.profileComplete,
  });
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign-in method > Google > Web SDK configuration)
  static const String _webClientId =
      '751451138176-tpo4ocj4urmifne9k2k4d448pgeq855e.apps.googleusercontent.com';

  // Only for accounts that finished the sign up (old accounts, admin):
  // false = they can log in and see a "verify your email" banner
  // true  = they cannot log in until the email is verified (admin is exempt)
  // New sign ups always verify the email first, whatever this value is.
  static const bool requireVerifiedEmail = false;

  bool get isSignedIn => _auth.currentUser != null;

  String get currentEmail => _auth.currentUser?.email ?? '';

  // ---------------------------------------------------------------------
  // sign up with email: 3 steps
  // ---------------------------------------------------------------------

  // Step 1: create the account and send the verification email.
  Future<void> createAccount(AccountData data) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: data.email,
      password: data.password,
    );

    final user = credential.user!;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': data.email,
        'role': data.role.name,
        'profileComplete': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // don't leave a user in Auth without a document in Firestore
      await user.delete();
      rethrow;
    }

    try {
      await user.sendEmailVerification();
    } catch (_) {
      // not critical: the verify screen has a Resend button
    }
  }

  // Step 2 helpers (the verify email screen)
  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<bool> refreshEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    await user.reload();
    final verified = _auth.currentUser?.emailVerified ?? false;
    if (verified) {
      // refresh the token too, because the security rules check it
      await _auth.currentUser?.getIdToken(true);
    }
    return verified;
  }

  // The user typed a wrong email: remove the unfinished account
  Future<void> cancelUnfinishedSignup() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).delete();
    } catch (_) {}

    try {
      await user.delete();
    } catch (_) {
      await logout();
    }
  }

  // Step 3: save the details (only after the email is verified)
  Future<void> completeProfile(SignUpData data) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'no-current-user');
    }

    await user.reload();
    final current = _auth.currentUser;
    if (current == null || !current.emailVerified) {
      throw FirebaseAuthException(code: 'email-not-verified');
    }
    await current.getIdToken(true);

    await _firestore.collection('users').doc(current.uid).update({
      'phone': data.phone,
      'profileComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),

      if (data.role == UserRole.creator) ...{
        'firstName': data.firstName,
        'lastName': data.lastName,
        'gender': data.gender?.name,
        'university': data.university,
        'faculty': data.faculty,
        'graduationYear': data.graduationYear,
        'specialization': data.specialization,
      },

      if (data.role == UserRole.company) ...{
        'companyName': data.companyName,
        'industry': data.industry,
        'foundedYear': data.foundedYear,
        'location': data.location,
        'description': data.description,
      },
    });

    try {
      final displayName = data.role == UserRole.creator
          ? '${data.firstName ?? ''} ${data.lastName ?? ''}'.trim()
          : (data.companyName ?? '');
      if (displayName.isNotEmpty) {
        await current.updateDisplayName(displayName);
      }
    } catch (_) {}
  }

  // ---------------------------------------------------------------------
  // login (no role: it is read from Firestore)
  // ---------------------------------------------------------------------

  Future<LoginResult> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _resultForUser(credential.user!);
  }

  // reads the user document and decides where the app goes next
  Future<LoginResult> _resultForUser(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();

    if (data == null) {
      await logout();
      throw FirebaseAuthException(code: 'profile-not-found');
    }

    final matches = UserRole.values.where((r) => r.name == data['role']);
    if (matches.isEmpty) {
      await logout();
      throw FirebaseAuthException(code: 'profile-not-found');
    }
    final role = matches.first;

    // old documents have no "profileComplete" field: they are complete
    final profileComplete = data['profileComplete'] != false;
    if (!profileComplete) {
      return LoginResult(
        user.emailVerified
            ? LoginOutcome.completeProfile
            : LoginOutcome.verifyEmail,
        role,
      );
    }

    if (requireVerifiedEmail && role != UserRole.admin && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
      } catch (_) {}
      await logout();
      throw FirebaseAuthException(code: 'email-not-verified');
    }

    return LoginResult(LoginOutcome.ok, role);
  }

  // ---------------------------------------------------------------------
  // Google
  // ---------------------------------------------------------------------

  bool _googleReady = false;

  Future<User> _googleSignInToFirebase() async {
    if (_webClientId.startsWith('YOUR_')) {
      throw FirebaseAuthException(code: 'google-not-configured');
    }

    if (!_googleReady) {
      await GoogleSignIn.instance.initialize(serverClientId: _webClientId);
      _googleReady = true;
    }

    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate(); // account picker
    } on GoogleSignInException catch (e) {
      // On Android a wrong setup (missing SHA-1, wrong Web client ID, old
      // google-services.json) can also show up as "canceled".
      // Read this line in the debug console to know the real reason.
      debugPrint(
        'Google sign-in failed: code=${e.code} description=${e.description}',
      );
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw FirebaseAuthException(code: 'google-cancelled');
      }
      throw FirebaseAuthException(code: 'google-failed');
    }

    final idToken = account.authentication.idToken;
    if (idToken == null) throw FirebaseAuthException(code: 'google-no-token');

    final cred = await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
    return cred.user!;
  }

  // Login screen: only for people who already have an account
  Future<LoginResult> loginWithGoogle() async {
    final user = await _googleSignInToFirebase();
    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      // first time with this Google account: it never signed up, remove it
      try {
        await user.delete();
      } catch (_) {}
      await logout();
      throw FirebaseAuthException(code: 'google-not-registered');
    }
    return _resultForUser(user);
  }

  // Sign up screen: the role was chosen before
  Future<LoginResult> signUpWithGoogle(UserRole role) async {
    final user = await _googleSignInToFirebase();
    final ref = _firestore.collection('users').doc(user.uid);

    if ((await ref.get()).exists) {
      return _resultForUser(user); // already has an account: just log in
    }

    try {
      await ref.set({
        'uid': user.uid,
        'email': user.email,
        'role': role.name,
        'profileComplete': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      await user.delete();
      rethrow;
    }

    // Google emails are already verified, so skip step 2
    return LoginResult(LoginOutcome.completeProfile, role);
  }

  // ---------------------------------------------------------------------
  // session
  // ---------------------------------------------------------------------

  // Used when the app starts. Returns null when nobody is signed in.
  Future<SessionInfo?> currentSession() async {
    var user = _auth.currentUser;
    if (user == null) return null;

    try {
      await user.reload();
    } catch (_) {}
    user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();
    if (data == null) {
      await logout();
      return null;
    }

    final roleName = data['role'];
    final matches = UserRole.values.where((r) => r.name == roleName);
    if (matches.isEmpty) {
      await logout();
      return null;
    }

    return SessionInfo(
      role: matches.first,
      email: user.email ?? '',
      emailVerified: user.emailVerified,
      profileComplete: data['profileComplete'] != false,
    );
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  // true when there is no user, so the banner is never shown by mistake
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? true;

  Future<void> logout() async {
    try {
      if (_googleReady) await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}