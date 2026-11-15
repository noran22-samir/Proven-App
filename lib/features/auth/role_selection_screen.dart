import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proven/core/theme/colors.dart';
import 'package:proven/core/widgets/proven_logo.dart';

enum UserRole { creator, company, admin }

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({
    super.key,
    required this.onCreateAccount,
    required this.onLogin,
  });

  final ValueChanged<UserRole> onCreateAccount;

  final ValueChanged<UserRole> onLogin;

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole _selectedRole = UserRole.creator;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAdmin = _selectedRole == UserRole.admin;
    final screenHeight = MediaQuery.sizeOf(context).height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF07121C) : AppColors.canvasBackground,
        body: Column(
          children: [
            _buildHeader(screenHeight * 0.22, isDark),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Who are you?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.borderOutline : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose how you will use Proven',
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark
                            ? AppColors.borderOutline.withValues(alpha: 0.7)
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _RoleCard(
                      icon: Icons.code_rounded,
                      title: 'Creator',
                      description: 'I sell my graduation projects',
                      isSelected: _selectedRole == UserRole.creator,
                      isDark: isDark,
                      onTap: () => setState(() => _selectedRole = UserRole.creator),
                    ),
                    _RoleCard(
                      icon: Icons.apartment_rounded,
                      title: 'Company',
                      description: "I'm looking to buy ready projects",
                      isSelected: _selectedRole == UserRole.company,
                      isDark: isDark,
                      onTap: () => setState(() => _selectedRole = UserRole.company),
                    ),
                    _RoleCard(
                      icon: Icons.shield_rounded,
                      title: 'Admin',
                      description: 'Review projects and manage the platform',
                      badge: 'Login only',
                      isSelected: isAdmin,
                      isDark: isDark,
                      onTap: () => setState(() => _selectedRole = UserRole.admin),
                    ),
                  ],
                ),
              ),
            ),

            // buttons at the bottom
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: _buildBottom(isDark, isAdmin),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double height, bool isDark) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.brandNavy,
        border: isDark
            ? Border(
                bottom: BorderSide(
                  color: const Color(0xFF3F7FB0).withValues(alpha: 0.4),
                ),
              )
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ProvenLogo(size: 56, showBorder: true),
                  const SizedBox(height: 10),
                  const Text(
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

          ],
        ),
      ),
    );
  }

  Widget _buildBottom(bool isDark, bool isAdmin) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (isAdmin) {
                widget.onLogin(_selectedRole);
              } else {
                widget.onCreateAccount(_selectedRole);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandNavy,
              foregroundColor: isDark ? AppColors.borderOutline : Colors.white,
              side: isDark ? const BorderSide(color: Color(0xFF3F7FB0)) : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              isAdmin ? 'Login' : 'Create Account',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 8),

        if (isAdmin)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Admin accounts are created by the platform owner.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: isDark
                    ? AppColors.borderOutline.withValues(alpha: 0.7)
                    : AppColors.textSecondary,
              ),
            ),
          )
        else
          TextButton(
            onPressed: () => widget.onLogin(_selectedRole),
            child: Text(
              'I already have an account',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF7FB3DC) : AppColors.brandNavy,
              ),
            ),
          ),
      ],
    );
  }
}
class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? const Color(0xFF7FB3DC) : AppColors.brandNavy;
    final gold = isDark ? const Color(0xFFF2BE5C) : const Color(0xFF8F5B00);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D1E2D) : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accent
                : (isDark ? const Color(0xFF2A4A66) : AppColors.borderOutline),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // icon in a circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.brandNavy
                    : AppColors.brandNavy.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.borderOutline : AppColors.textPrimary,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: gold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark
                          ? AppColors.borderOutline.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                child: Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: isDark ? const Color(0xFF07121C) : Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}