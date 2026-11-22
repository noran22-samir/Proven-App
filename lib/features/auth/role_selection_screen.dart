import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proven/core/theme/colors.dart';
import 'package:proven/features/auth/auth_widgets.dart';

// admin stays in the enum because the role is read from Firestore,
// but it is not shown here (admins use the normal login)
enum UserRole { creator, company, admin }

// this screen is for sign up only
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({
    super.key,
    required this.onCreateAccount,
    required this.onLogin,
  });

  final ValueChanged<UserRole> onCreateAccount;
  final VoidCallback onLogin;

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole _selectedRole = UserRole.creator;

  void _select(UserRole role) {
    if (role == _selectedRole) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedRole = role);
  }

  @override
  Widget build(BuildContext context) {
    final c = AuthColors.of(context);
    final heroHeight = MediaQuery.sizeOf(context).height * 0.22;
    final roleName =
        _selectedRole == UserRole.creator ? 'Creator' : 'Company';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.brandNavy,
        body: SizedBox.expand(
          child: Stack(
            children: [
              AuthHero(height: heroHeight),
              Positioned(
                top: heroHeight - 28,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: c.sheet,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AuthEntrance(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Who are you?',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: c.text,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Choose how you will use Proven',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: c.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // the two cards share the free space equally
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: AuthEntrance(
                                    delay: const Duration(milliseconds: 150),
                                    offset: 40,
                                    child: _RoleCard(
                                      icon: Icons.code_rounded,
                                      title: 'Creator',
                                      description:
                                          'I sell my graduation projects',
                                      features: const [
                                        'Showcase your project',
                                        'Get matched by AI',
                                      ],
                                      isSelected:
                                          _selectedRole == UserRole.creator,
                                      onTap: () => _select(UserRole.creator),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: AuthEntrance(
                                    delay: const Duration(milliseconds: 280),
                                    offset: 40,
                                    child: _RoleCard(
                                      icon: Icons.apartment_rounded,
                                      title: 'Company',
                                      description:
                                          "I'm looking to buy ready projects",
                                      features: const [
                                        'Browse ready projects',
                                        'Find talent that is proven',
                                      ],
                                      isSelected:
                                          _selectedRole == UserRole.company,
                                      onTap: () => _select(UserRole.company),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          AuthEntrance(
                            delay: const Duration(milliseconds: 400),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AuthPrimaryButton(
                                  label: 'Continue as $roleName',
                                  onPressed: () =>
                                      widget.onCreateAccount(_selectedRole),
                                ),
                                const SizedBox(height: 4),
                                TextButton(
                                  onPressed: widget.onLogin,
                                  child: Text(
                                    'I already have an account',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: c.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.features,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AuthColors.of(context);

    final fg = isSelected
        ? (c.isDark ? AppColors.borderOutline : Colors.white)
        : c.text;
    final fgSecondary = isSelected ? fg.withValues(alpha: 0.8) : c.secondaryText;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.brandNavy, Color(0xFF2A6396)],
                )
              : null,
          color: isSelected ? null : c.field,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? c.accent : c.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.brandNavy.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 110;
            final showFeatures = constraints.maxHeight > 190;

            final iconBox = AnimatedScale(
              scale: isSelected ? 1.1 : 1,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.18)
                      : c.accent.withValues(alpha: 0.12),
                ),
                child: Icon(icon, size: 28, color: isSelected ? fg : c.accent),
              ),
            );

            final badge = AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.elasticOut,
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: isSelected
                  ? Container(
                      key: const ValueKey('on'),
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: AppColors.brandNavy,
                      ),
                    )
                  : Container(
                      key: const ValueKey('off'),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: c.border, width: 1.5),
                      ),
                    ),
            );

            final titleText = Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: fg,
              ),
            );
            final descText = Text(
              description,
              style: TextStyle(fontSize: 13.5, color: fgSecondary),
            );

            if (compact) {
              return Row(
                children: [
                  iconBox,
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [titleText, const SizedBox(height: 2), descText],
                    ),
                  ),
                  badge,
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [iconBox, const Spacer(), badge]),
                const Spacer(),
                titleText,
                const SizedBox(height: 4),
                descText,
                if (showFeatures) ...[
                  const SizedBox(height: 10),
                  for (final f in features)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 16,
                            color: isSelected ? fg : c.accent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              f,
                              style: TextStyle(
                                fontSize: 13,
                                color: fgSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}