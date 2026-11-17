import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proven/core/theme/colors.dart';
import 'package:proven/features/auth/role_selection_screen.dart';

enum Gender { male, female }

// everything the user typed, the backend team will send it to Firebase
class SignUpData {
  // common data
  final UserRole role;
  final String email;
  final String phone;
  final String password;
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
    required this.email,
    required this.phone,
    required this.password,
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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
    required this.role,
    required this.onSubmit,
    required this.onLogin,
    required this.onBack,
  });

  final UserRole role; // chosen in the role selection screen
  final ValueChanged<SignUpData>
  onSubmit; // form is valid and "Create Account" tapped
  final VoidCallback onLogin; // "Login" link at the bottom
  final VoidCallback onBack; // back arrow

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controls the current signup step
  int _currentStep = 0;

  // Controls the current step's form validation
  final _basicFormKey = GlobalKey<FormState>();

  // common controllers
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Creator controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  // Creator optional controllers
  final _universityController = TextEditingController();
  final _facultyController = TextEditingController();
  final _graduationYearController = TextEditingController();
  final _specializationController = TextEditingController();

  // Company controllers
  final _companyNameController = TextEditingController();
  final _industryController = TextEditingController();

  // Company optional controllers
  final _foundedYearController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

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
    _universityController.dispose();
    _facultyController.dispose();
    _graduationYearController.dispose();
    _specializationController.dispose();
    _companyNameController.dispose();
    _industryController.dispose();
    _foundedYearController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  // check which role the user chose, to show/hide fields about the Creator or the Company
  bool get _isCreator => widget.role == UserRole.creator;
  bool get _isCompany => widget.role == UserRole.company;

  // main color of icons, borders and links
  Color get _accent => _isDark ? const Color(0xFF7FB3DC) : AppColors.brandNavy;

  Color get _textColor =>
      _isDark ? AppColors.borderOutline : AppColors.textPrimary;

  Color get _secondaryTextColor => _isDark
      ? AppColors.borderOutline.withValues(alpha: 0.7)
      : AppColors.textSecondary;

  Color get _borderColor =>
      _isDark ? const Color(0xFF2A4A66) : AppColors.borderOutline;

  Color get _fieldColor =>
      _isDark ? const Color(0xFF0D1E2D) : AppColors.cardSurface;

  Color get _errorColor =>
      _isDark ? const Color(0xFFFF8080) : const Color(0xFFC93C3C);

  // ---------------------------------------------------------------------
  // validation
  // ---------------------------------------------------------------------
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? _validateCompanyName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Company name is required';
    }
    return null;
  }

  String? _validateIndustry(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Industry is required';
    }
    return null;
  }

  String? _validateOptional(String? value) {
    return null;
  }

  String? _validateYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (!RegExp(r'^\d{4}$').hasMatch(value.trim())) {
      return 'Enter a valid 4-digit year';
    }

    final year = int.parse(value.trim());

    if (year < 1950 || year > DateTime.now().year + 10) {
      return 'Enter a reasonable year';
    }

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

  // Egyptian landline Company number, example: 0234567890
  String? _validateCompanyPhone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) return 'Phone number is required';

    final mobile = RegExp(r'^01[0125][0-9]{8}$');
    final landline = RegExp(r'^0[2-9][0-9]{7,8}$');

    if (!mobile.hasMatch(phone) && !landline.hasMatch(phone)) {
      return 'Enter a valid Egyptian phone number';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password Is Required';
    if (value.length < 8) return 'Password Must Be At Least 8 Characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please Confirm Your Password';
    if (value != _passwordController.text) return 'Passwords Do Not Match';
    return null;
  }

  void _goToNextStep() {
    if (_basicFormKey.currentState!.validate()) {
      setState(() {
        _currentStep = 1;
      });
    }
  }

  void _goToPreviousStep() {
    setState(() {
      _currentStep = 0;
    });
  }

  void _submit() {
    final isFormValid = _formKey.currentState!.validate();
    setState(() {
      _showGenderError = widget.role == UserRole.creator && _gender == null;
    });

    if (!isFormValid || _showGenderError) return;

    widget.onSubmit(
      SignUpData(
        role: widget.role,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,

        // Creator data
        firstName: widget.role == UserRole.creator
            ? _firstNameController.text.trim()
            : null,
        lastName: widget.role == UserRole.creator
            ? _lastNameController.text.trim()
            : null,
        gender: widget.role == UserRole.creator ? _gender : null,

        // Creator optional data
        university: _universityController.text.trim().isEmpty
            ? null
            : _universityController.text.trim(),
        faculty: _facultyController.text.trim().isEmpty
            ? null
            : _facultyController.text.trim(),
        graduationYear: _graduationYearController.text.trim().isEmpty
            ? null
            : _graduationYearController.text.trim(),
        specialization: _specializationController.text.trim().isEmpty
            ? null
            : _specializationController.text.trim(),

        // Company data
        companyName: widget.role == UserRole.company
            ? _companyNameController.text.trim()
            : null,
        industry: widget.role == UserRole.company
            ? _industryController.text.trim()
            : null,

        // Company optional data
        foundedYear: _foundedYearController.text.trim().isEmpty
            ? null
            : _foundedYearController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
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
      backgroundColor: _isDark
          ? const Color(0xFF07121C)
          : AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: _isDark
            ? const Color(0xFF07121C)
            : AppColors.canvasBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: widget.onBack,
          icon: Icon(Icons.arrow_back_rounded, color: _accent),
        ),
        title: Text(
          'Create Account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // shows which role the user chose
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
                      'Signing Up As $roleName',
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

              if (_currentStep == 0) ...[
                Form(
                  key: _basicFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // common fields
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
                        label: 'Password',
                        hint: 'At Least 8 Characters',
                        icon: Icons.lock_outline_rounded,
                        controller: _passwordController,
                        validator: _validatePassword,
                        hideText: _hidePassword,
                        suffix: IconButton(
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
                      const SizedBox(height: 16),

                      _buildField(
                        label: 'Confirm Password',
                        hint: 'Re-enter Your Password',
                        icon: Icons.lock_outline_rounded,
                        controller: _confirmPasswordController,
                        validator: _validateConfirmPassword,
                        hideText: _hideConfirmPassword,
                        action: TextInputAction.done,
                        suffix: IconButton(
                          onPressed: () => setState(
                            () => _hideConfirmPassword = !_hideConfirmPassword,
                          ),
                          icon: Icon(
                            _hideConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: _accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _goToNextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandNavy,
                            foregroundColor: _isDark
                                ? AppColors.borderOutline
                                : Colors.white,
                            side: _isDark
                                ? const BorderSide(color: Color(0xFF3F7FB0))
                                : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Creator fields
                      if (_isCreator) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildField(
                                label: 'First Name',
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
                                label: 'Last Name',
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
                          label: 'Phone Number',
                          hint: '01012345678',
                          icon: Icons.phone_outlined,
                          controller: _phoneController,
                          validator: _isCompany
                              ? _validateCompanyPhone
                              : _validatePhone,
                          keyboardType: TextInputType.phone,
                          formatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(
                              _isCompany ? 11 : 11,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _buildField(
                          label: 'University',
                          hint: 'Cairo University',
                          icon: Icons.school_outlined,
                          controller: _universityController,
                          validator: _validateOptional,
                        ),
                        const SizedBox(height: 16),

                        _buildField(
                          label: 'Faculty',
                          hint: 'Computer Science',
                          icon: Icons.account_balance_outlined,
                          controller: _facultyController,
                          validator: _validateOptional,
                        ),
                        const SizedBox(height: 16),

                        _buildField(
                          label: 'Graduation Year',
                          hint: '2027',
                          icon: Icons.calendar_today_outlined,
                          controller: _graduationYearController,
                          validator: _validateYear,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),

                        _buildField(
                          label: 'Specialization',
                          hint: 'Mobile Development',
                          icon: Icons.code_rounded,
                          controller: _specializationController,
                          validator: _validateOptional,
                        ),
                        const SizedBox(height: 16),

                        _buildGender(),
                        const SizedBox(height: 28),
                      ],

                      // Company fields
                      if (_isCompany) ...[
                        const SizedBox(height: 16),

                        _buildField(
                          label: 'Company Name',
                          hint: 'Proven',
                          icon: Icons.apartment_rounded,
                          controller: _companyNameController,
                          validator: _validateCompanyName,
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 16),

                        _buildField(
                          label: 'Industry',
                          hint: 'Software Development',
                          icon: Icons.business_outlined,
                          controller: _industryController,
                          validator: _validateIndustry,
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 16),

                        _buildField(
                          label: 'Phone Number',
                          hint: '0234567890',
                          icon: Icons.phone_outlined,
                          controller: _phoneController,
                          validator: _isCompany
                              ? _validateCompanyPhone
                              : _validatePhone,
                          keyboardType: TextInputType.phone,
                          formatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(
                              _isCompany ? 11 : 11,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _buildField(
                          label: 'Founded Year',
                          hint: '2020',
                          icon: Icons.calendar_today_outlined,
                          controller: _foundedYearController,
                          validator: _validateYear,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),

                        _buildField(
                          label: 'Location',
                          hint: 'Cairo, Egypt',
                          icon: Icons.location_on_outlined,
                          controller: _locationController,
                          validator: _validateOptional,
                        ),
                        const SizedBox(height: 16),

                        _buildField(
                          label: 'Company Description',
                          hint: 'Tell us about your company',
                          icon: Icons.description_outlined,
                          controller: _descriptionController,
                          validator: _validateOptional,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // back button
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _goToPreviousStep,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _accent,
                            side: BorderSide(color: _accent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Back'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // create account button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandNavy,
                            foregroundColor: _isDark
                                ? AppColors.borderOutline
                                : Colors.white,
                            side: _isDark
                                ? const BorderSide(color: Color(0xFF3F7FB0))
                                : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],

              // link to login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already Have An Account?',
                    style: TextStyle(color: _secondaryTextColor),
                  ),
                  TextButton(
                    onPressed: widget.onLogin,
                    child: Text(
                      'Login',
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
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _textColor,
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
              'Please Select Your Gender',
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
