import 'package:flutter/material.dart';
import 'package:proven/features/auth/auth_widgets.dart';
import 'package:proven/features/auth/role_selection_screen.dart';

enum Gender { male, female }

// Step 1: what the user typed on the first screen
class AccountData {
  final UserRole role;
  final String email;
  final String password;

  const AccountData({
    required this.role,
    required this.email,
    required this.password,
  });
}

// Step 3: the details the user fills after verifying the email
class SignUpData {
  // common data
  final UserRole role;
  final String? phone; // optional
  // Creator data
  final String? firstName;
  final String? lastName;
  final Gender? gender;
  // Creator optional data
  final String? university;
  final String? faculty;
  final String? graduationYear;
  final String? specialization;

  // Company data
  final String? companyName;
  final String? industry;
  // Company optional data
  final String? foundedYear;
  final String? location;
  final String? description;

  const SignUpData({
    required this.role,
    this.phone,
    this.firstName,
    this.lastName,
    this.gender,
    this.companyName,
    this.industry,
    this.university,
    this.faculty,
    this.graduationYear,
    this.specialization,
    this.foundedYear,
    this.location,
    this.description,
  });
}

// Step 1 of 3: email and password
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
    required this.role,
    required this.onSubmit,
    required this.onGoogle,
    required this.onLogin,
    required this.onBack,
    this.isLoading = false,
    this.isGoogleLoading = false,
    this.errorMessage,
  });

  final UserRole role; // chosen in the role selection screen
  final ValueChanged<AccountData> onSubmit; // form is valid and "Continue" tapped
  final VoidCallback onGoogle; // "Sign up with Google" tapped
  final VoidCallback onLogin; // "Login" link at the bottom
  final VoidCallback onBack; // back arrow

  final bool isLoading; // shows a spinner on the button
  final bool isGoogleLoading; // the spinner goes on the Google button
  final String? errorMessage; // example: "This email is already registered"

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // errors show only after the first tap on Continue, then they follow typing
  AutovalidateMode _autoMode = AutovalidateMode.disabled;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  void _submit() {
    if (widget.isLoading) return;

    if (!_formKey.currentState!.validate()) {
      setState(() => _autoMode = AutovalidateMode.onUserInteraction);
      return;
    }

    FocusScope.of(context).unfocus();
    widget.onSubmit(
      AccountData(
        role: widget.role,
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
      ),
    );
  }

  Widget _eyeButton(bool hidden, VoidCallback onTap, Color color) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AuthColors.of(context);

    return AuthShell(
      onBack: widget.isLoading ? null : widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create account',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: c.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Step 1 of 3 · Your account',
            style: TextStyle(fontSize: 15, color: c.secondaryText),
          ),
          const SizedBox(height: 14),
          AuthRoleChip(role: widget.role, prefix: 'Signing up as'),
          const SizedBox(height: 20),

          Form(
            key: _formKey,
            autovalidateMode: _autoMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthTextField(
                  label: 'Email',
                  hint: 'name@example.com',
                  icon: Icons.mail_outline_rounded,
                  controller: _emailController,
                  validator: _validateEmail,
                  enabled: !widget.isLoading,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Password',
                  hint: 'At least 8 characters',
                  icon: Icons.lock_outline_rounded,
                  controller: _passwordController,
                  validator: _validatePassword,
                  enabled: !widget.isLoading,
                  hideText: _hidePassword,
                  autofillHints: const [AutofillHints.newPassword],
                  suffix: _eyeButton(
                    _hidePassword,
                    () => setState(() => _hidePassword = !_hidePassword),
                    c.accent,
                  ),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  icon: Icons.lock_outline_rounded,
                  controller: _confirmPasswordController,
                  validator: _validateConfirmPassword,
                  enabled: !widget.isLoading,
                  hideText: _hideConfirmPassword,
                  action: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  suffix: _eyeButton(
                    _hideConfirmPassword,
                    () => setState(
                      () => _hideConfirmPassword = !_hideConfirmPassword,
                    ),
                    c.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "We'll send a verification link to your email in the next step.",
            style: TextStyle(fontSize: 12.5, color: c.secondaryText),
          ),
          const SizedBox(height: 20),

          // error from the backend (email already used, no internet...)
          if (widget.errorMessage != null) ...[
            AuthBanner(message: widget.errorMessage!),
            const SizedBox(height: 12),
          ],

          AuthPrimaryButton(
            label: 'Continue',
            onPressed: widget.isLoading ? null : _submit,
            isLoading: widget.isLoading && !widget.isGoogleLoading,
          ),
          const SizedBox(height: 16),
          const AuthDivider(),
          const SizedBox(height: 16),
          AuthGoogleButton(
            label: 'Sign up with Google',
            onPressed: widget.isLoading ? null : widget.onGoogle,
            isLoading: widget.isGoogleLoading,
          ),
          const SizedBox(height: 8),

          // link to login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: TextStyle(color: c.secondaryText),
              ),
              TextButton(
                onPressed: widget.isLoading ? null : widget.onLogin,
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: c.accent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}