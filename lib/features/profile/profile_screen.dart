import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proven/core/theme/colors.dart';
import 'package:proven/features/profile/profile_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const _gold = Color(0xFFF2B84B);
const _green = Color(0xFF34D399);

String _fmt(num n) => n.round().toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (_) => ',',
);

/// One profile screen for both roles. The role is read from users/{uid}.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = ProfileService();
  late final Stream<Map<String, dynamic>?> _stream = _service.watch();

  Future<ProfileStats>? _stats;
  String? _statsRole;

  // visual only for now (no theme / locale controller yet)
  int _language = 0;
  int _appearance = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tertiary,
      body: SafeArea(
        child: StreamBuilder<Map<String, dynamic>?>(
          stream: _stream,
          builder: (context, snap) {
            if (snap.hasError) {
              return const _Notice(
                icon: Icons.cloud_off_rounded,
                text: 'Could not load your profile.\nCheck your internet.',
              );
            }
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snap.data;
            if (data == null) {
              return const _Notice(
                icon: Icons.person_off_outlined,
                text: 'Profile not found.',
              );
            }
            return _content(data);
          },
        ),
      ),
    );
  }

  Widget _content(Map<String, dynamic> data) {
    String s(String k) => (data[k] ?? '').toString().trim();

    final role = s('role');
    final isCreator = role == 'creator';
    if (_statsRole != role) {
      _statsRole = role;
      _stats = _service.stats(role);
    }

    final rawName = isCreator
        ? '${s('firstName')} ${s('lastName')}'.trim()
        : s('companyName');
    final name = rawName.isNotEmpty
        ? rawName
        : (s('email').isNotEmpty ? s('email').split('@').first : 'User');

    final subtitle = isCreator
        ? [s('university'), s('faculty')].where((e) => e.isNotEmpty).join(' • ')
        : s('industry');

    final about = isCreator ? s('bio') : s('description');

    final details = isCreator
        ? <_Detail>[
            _Detail(Icons.school_outlined, 'University', s('university')),
            _Detail(Icons.account_balance_outlined, 'Faculty', s('faculty')),
            _Detail(
              Icons.calendar_today_outlined,
              'Graduation year',
              s('graduationYear'),
            ),
            _Detail(Icons.code_rounded, 'Specialization', s('specialization')),
            _Detail(Icons.phone_outlined, 'Phone', s('phone')),
          ]
        : <_Detail>[
            _Detail(Icons.business_outlined, 'Industry', s('industry')),
            _Detail(Icons.location_on_outlined, 'Location', s('location')),
            _Detail(Icons.calendar_today_outlined, 'Founded', s('foundedYear')),
            _Detail(Icons.phone_outlined, 'Phone', s('phone')),
          ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Row(
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            _RoundIconButton(
              icon: Icons.edit_outlined,
              tooltip: 'Edit profile',
              onTap: () => _edit(data, isCreator),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _HeaderCard(
          name: name,
          email: s('email'),
          subtitle: subtitle,
          isCreator: isCreator,
          verified: _service.emailVerified,
        ),
        const SizedBox(height: 12),
        _statsCard(isCreator),
        const SizedBox(height: 18),
        _Card(
          title: isCreator ? 'About me' : 'About the company',
          child: Text(
            about.isEmpty
                ? (isCreator
                      ? 'Add a short bio so companies know who you are.'
                      : 'Add a short description of your company.')
                : about,
            style: TextStyle(
              fontSize: 14,
              height: 1.55,
              color: about.isEmpty
                  ? AppColors.onTertiaryContainer
                  : Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          title: 'Details',
          child: Column(
            children: [
              for (var i = 0; i < details.length; i++) ...[
                _InfoRow(detail: details[i]),
                if (i != details.length - 1)
                  Divider(
                    height: 18,
                    color: AppColors.outline.withValues(alpha: 0.2),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          title: 'Preferences',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PrefLabel('Appearance'),
              const SizedBox(height: 8),
              _Segmented(
                options: const ['Light', 'Dark', 'System'],
                index: _appearance,
                onChanged: (i) => setState(() => _appearance = i),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: const Text(
              'Log out',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statsCard(bool isCreator) {
    return FutureBuilder<ProfileStats>(
      future: _stats,
      builder: (context, snap) {
        final st = snap.data;
        final loading = snap.connectionState != ConnectionState.done;
        String v(num? n) => loading || n == null ? '–' : _fmt(n);

        final labels = isCreator
            ? const ['Projects', 'Approved', 'Earned (EGP)']
            : const ['Orders', 'Completed', 'Spent (EGP)'];

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              _Stat(value: v(st?.total), label: labels[0]),
              const _VLine(),
              _Stat(value: v(st?.highlight), label: labels[1]),
              const _VLine(),
              _Stat(value: v(st?.money), label: labels[2], accent: true),
            ],
          ),
        );
      },
    );
  }

  Future<void> _edit(Map<String, dynamic> data, bool isCreator) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.tertiaryContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          _EditSheet(data: data, isCreator: isCreator, service: _service),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    }
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.tertiaryContainer,
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to use Proven.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Log out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (ok == true) widget.onLogout();
  }
}

// ─────────────────────────── pieces ───────────────────────────

BoxDecoration _cardDecoration() => BoxDecoration(
  color: AppColors.tertiaryContainer.withValues(alpha: 0.55),
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: AppColors.outline.withValues(alpha: 0.25)),
);

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.name,
    required this.email,
    required this.subtitle,
    required this.isCreator,
    required this.verified,
  });

  final String name;
  final String email;
  final String subtitle;
  final bool isCreator;
  final bool verified;

  String get _initials {
    final p = name.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (p.isEmpty) return '?';
    if (p.length == 1) {
      return p.first.substring(0, p.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (p[0][0] + p[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryContainer, AppColors.tertiaryContainer],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.inversePrimary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tertiary,
              border: Border.all(color: _gold, width: 2),
              boxShadow: [
                BoxShadow(color: _gold.withValues(alpha: 0.18), blurRadius: 24),
              ],
            ),
            child: Text(
              _initials,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppColors.inversePrimary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (verified) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified_rounded, size: 20, color: _green),
              ],
            ],
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onPrimaryContainer,
              ),
            ),
          ],
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onTertiaryContainer,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.inversePrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.inversePrimary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCreator ? Icons.code_rounded : Icons.apartment_rounded,
                  size: 15,
                  color: AppColors.inversePrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  isCreator ? 'Creator' : 'Company',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inversePrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.accent = false});
  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: accent ? _gold : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _VLine extends StatelessWidget {
  const _VLine();
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 34,
    color: AppColors.outline.withValues(alpha: 0.25),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _Detail {
  const _Detail(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.detail});
  final _Detail detail;

  @override
  Widget build(BuildContext context) {
    final empty = detail.value.isEmpty;
    return Row(
      children: [
        Icon(detail.icon, size: 19, color: AppColors.inversePrimary),
        const SizedBox(width: 12),
        Text(
          detail.label,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.onTertiaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            empty ? 'Not set' : detail.value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: empty
                  ? AppColors.onTertiaryContainer.withValues(alpha: 0.7)
                  : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrefLabel extends StatelessWidget {
  const _PrefLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 13.5,
      color: AppColors.onTertiaryContainer,
    ),
  );
}

class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.options,
    required this.index,
    required this.onChanged,
  });

  final List<String> options;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == index
                        ? AppColors.brandNavy
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: i == index
                          ? AppColors.inversePrimary.withValues(alpha: 0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    options[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: i == index
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: i == index
                          ? Colors.white
                          : AppColors.onTertiaryContainer,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.tertiaryContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outline.withValues(alpha: 0.25),
            ),
          ),
          child: Icon(icon, size: 20, color: AppColors.inversePrimary),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.onTertiaryContainer),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onTertiaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── edit sheet ───────────────────────────

class _Field {
  const _Field(
    this.key,
    this.label, {
    this.required = false,
    this.keyboard,
    this.maxLines = 1,
    this.digits,
  });
  final String key;
  final String label;
  final bool required;
  final TextInputType? keyboard;
  final int maxLines;
  final int? digits; // digits only, with this max length
}

class _EditSheet extends StatefulWidget {
  const _EditSheet({
    required this.data,
    required this.isCreator,
    required this.service,
  });

  final Map<String, dynamic> data;
  final bool isCreator;
  final ProfileService service;

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _c = {};
  bool _saving = false;
  String? _error;

  static const _creator = [
    _Field('firstName', 'First name', required: true),
    _Field('lastName', 'Last name', required: true),
    _Field('phone', 'Phone', keyboard: TextInputType.phone, digits: 11),
    _Field('university', 'University'),
    _Field('faculty', 'Faculty'),
    _Field(
      'graduationYear',
      'Graduation year',
      keyboard: TextInputType.number,
      digits: 4,
    ),
    _Field('specialization', 'Specialization'),
    _Field('bio', 'Bio', maxLines: 4),
  ];

  static const _company = [
    _Field('companyName', 'Company name', required: true),
    _Field('industry', 'Industry', required: true),
    _Field('phone', 'Phone', keyboard: TextInputType.phone, digits: 11),
    _Field('location', 'Location'),
    _Field(
      'foundedYear',
      'Founded year',
      keyboard: TextInputType.number,
      digits: 4,
    ),
    _Field('description', 'Description', maxLines: 4),
  ];

  List<_Field> get _fields => widget.isCreator ? _creator : _company;

  @override
  void initState() {
    super.initState();
    for (final f in _fields) {
      _c[f.key] = TextEditingController(
        text: (widget.data[f.key] ?? '').toString(),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validate(_Field f, String? v) {
    final t = v?.trim() ?? '';
    if (f.required && t.isEmpty) return '${f.label} is required';
    if (t.isNotEmpty &&
        f.key == 'phone' &&
        !RegExp(r'^0\d{8,10}$').hasMatch(t)) {
      return 'Enter a valid phone number';
    }
    if (t.isNotEmpty && f.digits == 4) {
      final y = int.tryParse(t);
      if (y == null || y < 1950 || y > DateTime.now().year + 10) {
        return 'Enter a valid year';
      }
    }
    return null;
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final changes = <String, dynamic>{};
      for (final f in _fields) {
        final t = _c[f.key]!.text.trim();
        changes[f.key] = (t.isEmpty && !f.required) ? null : t;
      }
      await widget.service.update(changes);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Profile update failed: $e');
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = (e is FirebaseException && e.code == 'permission-denied')
            ? 'Verify your email first, then log out and log in again.'
            : 'Could not save. Check your internet and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Edit profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              for (final f in _fields) ...[
                Text(
                  f.label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _c[f.key],
                  enabled: !_saving,
                  maxLines: f.maxLines,
                  keyboardType: f.keyboard,
                  inputFormatters: f.digits == null
                      ? null
                      : [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(f.digits),
                        ],
                  validator: (v) => _validate(f, v),
                ),
                const SizedBox(height: 14),
              ],
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: AppColors.error)),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text(
                          'Save changes',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
