import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proven/core/theme/colors.dart';
import 'package:proven/core/widgets/proven_logo.dart';
import 'package:proven/features/auth/role_selection_screen.dart';

// what the user typed, the backend team will check it with Firebase
class LoginData {
  final UserRole role;
  final String email;
  final String password;

  const LoginData({
    required this.role,
    required this.email,
    required this.password,
  });
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.role,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onSignUp,
    required this.onBack,
    this.isLoading = false,
    this.errorMessage,
  });

  final UserRole role; // chosen in the role selection screen
  final ValueChanged<LoginData> onSubmit; // form is valid and "Login" tapped
  final VoidCallback onForgotPassword;
  final VoidCallback onSignUp; // not shown for the admin
  final VoidCallback onBack;

  // the backend team can use these two:
  final bool isLoading; // shows a spinner on the button
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

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // main color of icons, borders and links
  Color get _accent => _isDark ? const Color(0xFF7FB3DC) : AppColors.brandNavy;

  Color get _textColor => _isDark ? AppColors.borderOutline : AppColors.textPrimary;

  Color get _secondaryTextColor => _isDark
      ? AppColors.borderOutline.withValues(alpha: 0.7)
      : AppColors.textSecondary;

  Color get _borderColor => _isDark ? const Color(0xFF2A4A66) : AppColors.borderOutline;

  Color get _fieldColor => _isDark ? const Color(0xFF0D1E2D) : AppColors.cardSurface;

  Color get _errorColor => _isDark ? const Color(0xFFFF8080) : const Color(0xFFC93C3C);

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
    if (!_formKey.currentState!.validate()) return;

    widget.onSubmit(
      LoginData(
        role: widget.role,
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final heroHeight = MediaQuery.sizeOf(context).height * 0.28;
    final isAdmin = widget.role == UserRole.admin;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // the top of the screen is navy, so the status bar icons are light
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.brandNavy,
        // SizedBox.expand makes the Stack fill the whole screen
        body: SizedBox.expand(
          child: Stack(
          children: [
            // navy band with the logo
            Container(
              width: double.infinity,
              height: heroHeight,
              color: AppColors.brandNavy,
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            ProvenLogo(size: 56, showBorder: true),
                            SizedBox(height: 10),
                            Text(
                              'Proven',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.borderOutline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      left: 8,
                      child: IconButton(
                        onPressed: widget.onBack,
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.borderOutline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // white (or dark) part with the form, its top corners are rounded
            Positioned(
              top: heroHeight - 28,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: _isDark ? const Color(0xFF07121C) : AppColors.canvasBackground,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: _textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to continue',
                            style: TextStyle(fontSize: 15, color: _secondaryTextColor),
                          ),
                          const SizedBox(height: 14),
                          _buildRoleChip(),
                          const SizedBox(height: 20),

                          _buildLabel('Email'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            validator: _validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            style: TextStyle(color: _textColor),
                            cursorColor: _accent,
                            decoration: _fieldDecoration(
                              'name@example.com',
                              Icons.mail_outline_rounded,
                              null,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Password'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            validator: _validatePassword,
                            obscureText: _hidePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            style: TextStyle(color: _textColor),
                            cursorColor: _accent,
                            decoration: _fieldDecoration(
                              'Enter your password',
                              Icons.lock_outline_rounded,
                              IconButton(
                                onPressed: () =>
                                    setState(() => _hidePassword = !_hidePassword),
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: _accent,
                                ),
                              ),
                            ),
                          ),

                          // forgot password link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: widget.onForgotPassword,
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _accent,
                                ),
                              ),
                            ),
                          ),

                          // error from the backend (wrong email or password)
                          if (widget.errorMessage != null) ...[
                            _buildErrorBanner(widget.errorMessage!),
                            const SizedBox(height: 12),
                          ],

                          // login button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: widget.isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandNavy,
                                disabledBackgroundColor:
                                    AppColors.brandNavy.withValues(alpha: 0.6),
                                foregroundColor:
                                    _isDark ? AppColors.borderOutline : Colors.white,
                                side: _isDark
                                    ? const BorderSide(color: Color(0xFF3F7FB0))
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: widget.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: AppColors.borderOutline,
                                      ),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // the admin cannot sign up, everyone else can
                          if (isAdmin)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'Admin accounts are created by the platform owner.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12.5, color: _secondaryTextColor),
                                ),
                              ),
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account?",
                                  style: TextStyle(color: _secondaryTextColor),
                                ),
                                TextButton(
                                  onPressed: widget.onSignUp,
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // small builders
  // ---------------------------------------------------------------------

  // shows which role the user chose
  Widget _buildRoleChip() {
    late final IconData icon;
    late final String name;

    switch (widget.role) {
      case UserRole.creator:
        icon = Icons.code_rounded;
        name = 'Creator';
        break;
      case UserRole.company:
        icon = Icons.apartment_rounded;
        name = 'Company';
        break;
      case UserRole.admin:
        icon = Icons.shield_rounded;
        name = 'Admin';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _accent),
          const SizedBox(width: 6),
          Text(
            'Logging in as $name',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _accent),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textColor),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _errorColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _errorColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: _errorColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: _errorColor, fontSize: 13.5)),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint, IconData icon, Widget? suffix) {
    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _secondaryTextColor.withValues(alpha: 0.6)),
      prefixIcon: Icon(icon, color: _accent),
      suffixIcon: suffix,
      filled: true,
      fillColor: _fieldColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      errorStyle: TextStyle(color: _errorColor, fontSize: 12),
      border: border(_borderColor, 1),
      enabledBorder: border(_borderColor, 1),
      focusedBorder: border(_accent, 2),
      errorBorder: border(_errorColor, 1),
      focusedErrorBorder: border(_errorColor, 2),
    );
  }
}