import 'package:flutter/material.dart';
import 'package:proven/features/auth/auth_widgets.dart';

// what the user typed (the role is read from Firestore after login)
class LoginData {
  final String email;
  final String password;

  const LoginData({required this.email, required this.password});
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onSubmit,
    required this.onGoogle,
    required this.onForgotPassword,
    required this.onSignUp,
    required this.onBack,
    this.isLoading = false,
    this.isGoogleLoading = false,
    this.errorMessage,
  });

  final ValueChanged<LoginData> onSubmit; // form is valid and "Login" tapped
  final VoidCallback onGoogle; // "Continue with Google" tapped
  final ValueChanged<String> onForgotPassword; // gets the typed email
  final VoidCallback onSignUp;
  final VoidCallback onBack;

  final bool isLoading; // shows a spinner on the button
  final bool isGoogleLoading; // the spinner goes on the Google button
  final String? errorMessage; // example: "Wrong email or password"

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
    return null;
  }

  void _submit() {
    if (widget.isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    widget.onSubmit(
      LoginData(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AuthColors.of(context);

    return AuthShell(
      onBack: widget.isLoading ? null : widget.onBack,
      heroFactor: 0.26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: c.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sign in to continue',
            style: TextStyle(fontSize: 15, color: c.secondaryText),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
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
                  hint: 'Enter your password',
                  icon: Icons.lock_outline_rounded,
                  controller: _passwordController,
                  validator: _validatePassword,
                  enabled: !widget.isLoading,
                  hideText: _hidePassword,
                  action: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  autofillHints: const [AutofillHints.password],
                  suffix: IconButton(
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: c.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.isLoading
                  ? null
                  : () => widget.onForgotPassword(_emailController.text.trim()),
              child: Text(
                'Forgot password?',
                style: TextStyle(fontWeight: FontWeight.w600, color: c.accent),
              ),
            ),
          ),
          if (widget.errorMessage != null) ...[
            AuthBanner(message: widget.errorMessage!),
            const SizedBox(height: 12),
          ],
          AuthPrimaryButton(
            label: 'Login',
            onPressed: widget.isLoading ? null : _submit,
            isLoading: widget.isLoading && !widget.isGoogleLoading,
          ),
          const SizedBox(height: 16),
          const AuthDivider(),
          const SizedBox(height: 16),
          AuthGoogleButton(
            label: 'Continue with Google',
            onPressed: widget.isLoading ? null : widget.onGoogle,
            isLoading: widget.isGoogleLoading,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                style: TextStyle(color: c.secondaryText),
              ),
              TextButton(
                onPressed: widget.isLoading ? null : widget.onSignUp,
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontWeight: FontWeight.bold, color: c.accent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}