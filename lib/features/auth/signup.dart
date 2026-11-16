import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proven/core/theme/colors.dart';
import 'package:proven/features/auth/role_selection_screen.dart';

enum Gender { male, female }

// everything the user typed, the backend team will send it to Firebase
class SignUpData {
  final UserRole role;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final Gender gender;

  const SignUpData({
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.gender,
  });
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
    required this.role,
    required this.onSubmit,
    required this.onLogin,
    required this.onBack,
  });

  final UserRole role; // chosen in the role selection screen
  final ValueChanged<SignUpData> onSubmit; // form is valid and "Create Account" tapped
  final VoidCallback onLogin; // "Login" link at the bottom
  final VoidCallback onBack; // back arrow

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Gender? _gender;
  bool _showGenderError = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  // ---------------------------------------------------------------------
  // validation
  // ---------------------------------------------------------------------
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  // Egyptian mobile number, example: 01012345678
  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(phone)) {
      return 'Enter a valid number, like 01012345678';
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
    final isFormValid = _formKey.currentState!.validate();
    setState(() => _showGenderError = _gender == null);

    if (!isFormValid || _gender == null) return;

    widget.onSubmit(
      SignUpData(
        role: widget.role,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        gender: _gender!,
      ),
    );
  }

  // ---------------------------------------------------------------------
  // screen
  // ---------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final roleName = widget.role == UserRole.company ? 'Company' : 'Creator';

    return Scaffold(
      backgroundColor: _isDark ? const Color(0xFF07121C) : AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: _isDark ? const Color(0xFF07121C) : AppColors.canvasBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: widget.onBack,
          icon: Icon(Icons.arrow_back_rounded, color: _accent),
        ),
        title: Text(
          'Create account',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // shows which role the user chose
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.role == UserRole.company
                            ? Icons.apartment_rounded
                            : Icons.code_rounded,
                        size: 16,
                        color: _accent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Signing up as $roleName',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _accent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // first name + last name
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildField(
                        label: 'First name',
                        hint: 'Omar',
                        icon: Icons.person_outline_rounded,
                        controller: _firstNameController,
                        validator: _validateName,
                        keyboardType: TextInputType.name,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        label: 'Last name',
                        hint: 'Hassan',
                        icon: Icons.person_outline_rounded,
                        controller: _lastNameController,
                        validator: _validateName,
                        keyboardType: TextInputType.name,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildField(
                  label: 'Email',
                  hint: 'name@example.com',
                  icon: Icons.mail_outline_rounded,
                  controller: _emailController,
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                _buildField(
                  label: 'Phone number',
                  hint: '01012345678',
                  icon: Icons.phone_outlined,
                  controller: _phoneController,
                  validator: _validatePhone,
                  keyboardType: TextInputType.phone,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                ),
                const SizedBox(height: 16),

                _buildField(
                  label: 'Password',
                  hint: 'At least 8 characters',
                  icon: Icons.lock_outline_rounded,
                  controller: _passwordController,
                  validator: _validatePassword,
                  hideText: _hidePassword,
                  suffix: IconButton(
                    onPressed: () => setState(() => _hidePassword = !_hidePassword),
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: _accent,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildField(
                  label: 'Confirm password',
                  hint: 'Re-enter your password',
                  icon: Icons.lock_outline_rounded,
                  controller: _confirmPasswordController,
                  validator: _validateConfirmPassword,
                  hideText: _hideConfirmPassword,
                  action: TextInputAction.done,
                  suffix: IconButton(
                    onPressed: () =>
                        setState(() => _hideConfirmPassword = !_hideConfirmPassword),
                    icon: Icon(
                      _hideConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: _accent,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildGender(),
                const SizedBox(height: 28),

                // create account button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandNavy,
                      foregroundColor: _isDark ? AppColors.borderOutline : Colors.white,
                      side: _isDark ? const BorderSide(color: Color(0xFF3F7FB0)) : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // link to login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: _secondaryTextColor),
                    ),
                    TextButton(
                      onPressed: widget.onLogin,
                      child: Text(
                        'Login',
                        style: TextStyle(fontWeight: FontWeight.bold, color: _accent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // small builders
  // ---------------------------------------------------------------------

  // label on top + text field under it
  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool hideText = false,
    Widget? suffix,
    List<TextInputFormatter>? formatters,
    TextInputAction action = TextInputAction.next,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: hideText,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          textInputAction: action,
          style: TextStyle(color: _textColor),
          cursorColor: _accent,
          decoration: _fieldDecoration(hint, icon, suffix),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textColor),
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

  Widget _buildGender() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Gender'),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildGenderOption(Gender.male, 'Male', Icons.male_rounded),
            const SizedBox(width: 12),
            _buildGenderOption(Gender.female, 'Female', Icons.female_rounded),
          ],
        ),
        if (_showGenderError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'Please select your gender',
              style: TextStyle(color: _errorColor, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildGenderOption(Gender value, String text, IconData icon) {
    final isSelected = _gender == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _gender = value;
          _showGenderError = false;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            color: _fieldColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? _accent
                  : (_showGenderError ? _errorColor : _borderColor),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _accent),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? _accent : _textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}