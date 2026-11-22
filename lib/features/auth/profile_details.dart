import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proven/features/auth/auth_widgets.dart';
import 'package:proven/features/auth/role_selection_screen.dart';
import 'package:proven/features/auth/signup.dart';

// Step 3 of 3: the user's details (shown after the email is verified)
class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({
    super.key,
    required this.role,
    required this.onSubmit,
    required this.onBack,
    this.isLoading = false,
    this.errorMessage,
  });

  final UserRole role;
  final ValueChanged<SignUpData> onSubmit; // form is valid and "Finish" tapped
  final VoidCallback onBack; // log out, the user can finish later by logging in

  final bool isLoading; // shows a spinner on the button
  final String? errorMessage;

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // errors show only after the first tap on Finish, then they follow typing
  AutovalidateMode _autoMode = AutovalidateMode.disabled;

  // common
  final _phoneController = TextEditingController();

  // Creator controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _universityController = TextEditingController();
  final _facultyController = TextEditingController();
  final _graduationYearController = TextEditingController();
  final _specializationController = TextEditingController();

  // Company controllers
  final _companyNameController = TextEditingController();
  final _industryController = TextEditingController();
  final _foundedYearController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  Gender? _gender;
  bool _showGenderError = false;

  bool get _isCreator => widget.role == UserRole.creator;
  bool get _isCompany => widget.role == UserRole.company;

  @override
  void dispose() {
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
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

  // ---------------------------------------------------------------------
  // validation
  // ---------------------------------------------------------------------
  String? _required(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  String? _validateOptional(String? value) => null;

  String? _validateYear(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    if (!RegExp(r'^\d{4}$').hasMatch(value.trim())) {
      return 'Enter a valid 4-digit year';
    }

    final year = int.parse(value.trim());
    if (year < 1950 || year > DateTime.now().year + 10) {
      return 'Enter a reasonable year';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return null;

    final mobile = RegExp(r'^01[0125][0-9]{8}$');
    final landline = RegExp(r'^0[2-9][0-9]{7,8}$');

    if (_isCompany) {
      if (!mobile.hasMatch(phone) && !landline.hasMatch(phone)) {
        return 'Enter a valid Egyptian phone number';
      }
    } else if (!mobile.hasMatch(phone)) {
      return 'Enter a valid number, like 01012345678';
    }
    return null;
  }

  String? _orNull(TextEditingController c) {
    final text = c.text.trim();
    return text.isEmpty ? null : text;
  }

  void _submit() {
    if (widget.isLoading) return;

    final isFormValid = _formKey.currentState!.validate();
    final genderMissing = _isCreator && _gender == null;

    if (!isFormValid || genderMissing) {
      setState(() {
        _autoMode = AutovalidateMode.onUserInteraction;
        _showGenderError = genderMissing;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    widget.onSubmit(
      SignUpData(
        role: widget.role,
        phone: _orNull(_phoneController),

        // Creator data
        firstName: _isCreator ? _firstNameController.text.trim() : null,
        lastName: _isCreator ? _lastNameController.text.trim() : null,
        gender: _isCreator ? _gender : null,
        university: _orNull(_universityController),
        faculty: _orNull(_facultyController),
        graduationYear: _orNull(_graduationYearController),
        specialization: _orNull(_specializationController),

        // Company data
        companyName: _isCompany ? _companyNameController.text.trim() : null,
        industry: _isCompany ? _industryController.text.trim() : null,
        foundedYear: _orNull(_foundedYearController),
        location: _orNull(_locationController),
        description: _orNull(_descriptionController),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // screen
  // ---------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final c = AuthColors.of(context);
    final enabled = !widget.isLoading;

    return AuthShell(
      onBack: widget.isLoading ? null : widget.onBack,
      heroFactor: 0.22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your details',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: c.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Step 3 of 3 · Almost done',
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
                if (_isCreator) ..._creatorFields(enabled, c),
                if (_isCompany) ..._companyFields(enabled),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // error from the backend
          if (widget.errorMessage != null) ...[
            AuthBanner(message: widget.errorMessage!),
            const SizedBox(height: 12),
          ],

          AuthPrimaryButton(
            label: 'Finish',
            onPressed: widget.isLoading ? null : _submit,
            isLoading: widget.isLoading,
          ),
        ],
      ),
    );
  }

  List<Widget> _creatorFields(bool enabled, AuthColors c) {
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AuthTextField(
              label: 'First Name',
              hint: 'Omar',
              icon: Icons.person_outline_rounded,
              controller: _firstNameController,
              validator: (v) => _required(v, 'First name is required'),
              enabled: enabled,
              keyboardType: TextInputType.name,
              capitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.givenName],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AuthTextField(
              label: 'Last Name',
              hint: 'Hassan',
              icon: Icons.person_outline_rounded,
              controller: _lastNameController,
              validator: (v) => _required(v, 'Last name is required'),
              enabled: enabled,
              keyboardType: TextInputType.name,
              capitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.familyName],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _phoneField(enabled, '01012345678'),
      const SizedBox(height: 16),
      AuthTextField(
        label: 'University (optional)',
        hint: 'Cairo University',
        icon: Icons.school_outlined,
        controller: _universityController,
        validator: _validateOptional,
        enabled: enabled,
        capitalization: TextCapitalization.words,
      ),
      const SizedBox(height: 16),
      AuthTextField(
        label: 'Faculty (optional)',
        hint: 'Computer Science',
        icon: Icons.account_balance_outlined,
        controller: _facultyController,
        validator: _validateOptional,
        enabled: enabled,
        capitalization: TextCapitalization.words,
      ),
      const SizedBox(height: 16),
      AuthTextField(
        label: 'Graduation Year (optional)',
        hint: '2027',
        icon: Icons.calendar_today_outlined,
        controller: _graduationYearController,
        validator: _validateYear,
        enabled: enabled,
        keyboardType: TextInputType.number,
        formatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
      ),
      const SizedBox(height: 16),
      AuthTextField(
        label: 'Specialization (optional)',
        hint: 'Mobile Development',
        icon: Icons.code_rounded,
        controller: _specializationController,
        validator: _validateOptional,
        enabled: enabled,
        capitalization: TextCapitalization.words,
        action: TextInputAction.done,
      ),
      const SizedBox(height: 16),
      _buildGender(c),
    ];
  }

  List<Widget> _companyFields(bool enabled) {
    return [
      AuthTextField(
        label: 'Company Name',
        hint: 'Proven',
        icon: Icons.apartment_rounded,
        controller: _companyNameController,
        validator: (v) => _required(v, 'Company name is required'),
        enabled: enabled,
        keyboardType: TextInputType.name,
        capitalization: TextCapitalization.words,
        autofillHints: const [AutofillHints.organizationName],
      ),
      const SizedBox(height: 16),
      AuthTextField(
        label: 'Industry',
        hint: 'Software Development',
        icon: Icons.business_outlined,
        controller: _industryController,
        validator: (v) => _required(v, 'Industry is required'),
        enabled: enabled,
        capitalization: TextCapitalization.words,
      ),
      const SizedBox(height: 16),
      _phoneField(enabled, '0234567890'),
      const SizedBox(height: 16),
      AuthTextField(
        label: 'Founded Year (optional)',
        hint: '2020',
        icon: Icons.calendar_today_outlined,
        controller: _foundedYearController,
        validator: _validateYear,
        enabled: enabled,
        keyboardType: TextInputType.number,
        formatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
      ),
      const SizedBox(height: 16),
      AuthTextField(
        label: 'Location (optional)',
        hint: 'Cairo, Egypt',
        icon: Icons.location_on_outlined,
        controller: _locationController,
        validator: _validateOptional,
        enabled: enabled,
        capitalization: TextCapitalization.words,
      ),
      const SizedBox(height: 16),
      AuthTextField(
        label: 'Company Description (optional)',
        hint: 'Tell us about your company',
        icon: Icons.description_outlined,
        controller: _descriptionController,
        validator: _validateOptional,
        enabled: enabled,
        keyboardType: TextInputType.multiline,
        capitalization: TextCapitalization.sentences,
        action: TextInputAction.newline,
        maxLines: 3,
      ),
    ];
  }

  Widget _phoneField(bool enabled, String hint) {
    return AuthTextField(
      label: 'Phone Number (optional)',
      hint: hint,
      icon: Icons.phone_outlined,
      controller: _phoneController,
      validator: _validatePhone,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      autofillHints: const [AutofillHints.telephoneNumber],
      formatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // gender
  // ---------------------------------------------------------------------
  Widget _buildGender(AuthColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: c.text,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _genderOption(c, Gender.male, 'Male', Icons.male_rounded),
            const SizedBox(width: 12),
            _genderOption(c, Gender.female, 'Female', Icons.female_rounded),
          ],
        ),
        if (_showGenderError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'Please select your gender',
              style: TextStyle(color: c.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _genderOption(
    AuthColors c,
    Gender value,
    String text,
    IconData icon,
  ) {
    final isSelected = _gender == value;

    return Expanded(
      child: GestureDetector(
        onTap: widget.isLoading
            ? null
            : () => setState(() {
                  _gender = value;
                  _showGenderError = false;
                }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            color: c.field,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? c.accent
                  : (_showGenderError ? c.error : c.border),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: c.accent),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? c.accent : c.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}