import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proven/core/theme/colors.dart';
import 'package:proven/core/widgets/proven_logo.dart';
import 'package:proven/features/auth/role_selection_screen.dart';

// Colors and small widgets shared by the auth screens.
// They follow the light/dark theme.
class AuthColors {
  const AuthColors._(this.isDark);

  factory AuthColors.of(BuildContext context) {
    return AuthColors._(Theme.of(context).brightness == Brightness.dark);
  }

  final bool isDark;

  // main color of icons, borders and links
  Color get accent => isDark ? const Color(0xFF7FB3DC) : AppColors.brandNavy;

  Color get text => isDark ? AppColors.borderOutline : AppColors.textPrimary;

  Color get secondaryText => isDark
      ? AppColors.borderOutline.withValues(alpha: 0.7)
      : AppColors.textSecondary;

  Color get border => isDark ? const Color(0xFF2A4A66) : AppColors.borderOutline;

  Color get field => isDark ? const Color(0xFF0D1E2D) : AppColors.cardSurface;

  Color get error => isDark ? const Color(0xFFFF8080) : const Color(0xFFC93C3C);

  Color get sheet => isDark ? const Color(0xFF07121C) : AppColors.canvasBackground;
}

// small fade + slide-up animation, plays once when the widget first appears
class AuthEntrance extends StatefulWidget {
  const AuthEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 24,
  });

  final Widget child;
  final Duration delay;
  final double offset; // how far (in pixels) it slides up from

  @override
  State<AuthEntrance> createState() => _AuthEntranceState();
}

class _AuthEntranceState extends State<AuthEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: _curve.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _curve.value) * widget.offset),
            child: child,
          ),
        );
      },
    );
  }
}

// navy band: floating soft circles + the logo that pops in
class AuthHero extends StatefulWidget {
  const AuthHero({
    super.key,
    required this.height,
    this.overlap = 28, // the sheet covers this much of the bottom
    this.showBack = false,
    this.onBack,
  });

  final double height;
  final double overlap;
  final bool showBack;
  final VoidCallback? onBack; // null = the back arrow is disabled

  @override
  State<AuthHero> createState() => _AuthHeroState();
}

class _AuthHeroState extends State<AuthHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  Widget _circle(double size, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.borderOutline.withValues(alpha: alpha),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height,
      color: AppColors.brandNavy,
      child: ClipRect(
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _float,
              builder: (context, _) {
                final t = Curves.easeInOut.transform(_float.value);
                return Stack(
                  children: [
                    Positioned(
                      top: -50 + 16 * t,
                      right: -40 - 12 * t,
                      child: _circle(170, 0.07),
                    ),
                    Positioned(
                      bottom: 16 - 14 * t,
                      left: -60 + 18 * t,
                      child: _circle(130, 0.05),
                    ),
                    Positioned(
                      top: 40 + 12 * t,
                      left: 70 - 10 * t,
                      child: _circle(34, 0.07),
                    ),
                    Positioned(
                      bottom: 40 + 8 * t,
                      right: 60,
                      child: _circle(22, 0.06),
                    ),
                  ],
                );
              },
            ),
            SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: widget.overlap),
                    child: Center(
                      // shrinks on small screens instead of overflowing
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.6, end: 1),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                          builder: (context, v, child) {
                            return Opacity(
                              opacity: ((v - 0.6) / 0.4).clamp(0.0, 1.0),
                              child: Transform.scale(scale: v, child: child),
                            );
                          },
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
                    ),
                  ),
                  if (widget.showBack)
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
          ],
        ),
      ),
    );
  }
}

// navy band with the logo on top + rounded sheet that holds the content
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.child,
    this.onBack,
    this.showBack = true,
    this.heroFactor = 0.24,
  });

  final Widget child;
  final VoidCallback? onBack; // null = the back arrow is disabled
  final bool showBack;
  final double heroFactor; // height of the navy band (part of the screen)

  @override
  Widget build(BuildContext context) {
    final colors = AuthColors.of(context);
    final heroHeight = MediaQuery.sizeOf(context).height * heroFactor;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.brandNavy,
        // the layout does not shrink when the keyboard opens (no overflow)
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SizedBox.expand(
            child: Stack(
              children: [
                AuthHero(
                  height: heroHeight,
                  showBack: showBack,
                  onBack: onBack,
                ),
                Positioned(
                  top: heroHeight - 28,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.sheet,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(24, 28, 24, 24 + keyboard),
                        child: AuthEntrance(
                          delay: const Duration(milliseconds: 120),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// label on top + text field under it
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.hideText = false,
    this.suffix,
    this.formatters,
    this.action = TextInputAction.next,
    this.enabled = true,
    this.autofillHints,
    this.capitalization = TextCapitalization.none,
    this.onSubmitted,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool hideText;
  final Widget? suffix;
  final List<TextInputFormatter>? formatters;
  final TextInputAction action;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final TextCapitalization capitalization;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final c = AuthColors.of(context);

    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: c.text,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          enabled: enabled,
          obscureText: hideText,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          textInputAction: action,
          autofillHints: autofillHints,
          textCapitalization: capitalization,
          maxLines: maxLines,
          onFieldSubmitted: onSubmitted,
          style: TextStyle(color: c.text),
          cursorColor: c.accent,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: c.secondaryText.withValues(alpha: 0.6)),
            prefixIcon: Icon(icon, color: c.accent),
            suffixIcon: suffix,
            filled: true,
            fillColor: c.field,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 14,
            ),
            errorStyle: TextStyle(color: c.error, fontSize: 12),
            border: border(c.border, 1),
            enabledBorder: border(c.border, 1),
            focusedBorder: border(c.accent, 2),
            errorBorder: border(c.error, 1),
            focusedErrorBorder: border(c.error, 2),
          ),
        ),
      ],
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading; // shows a spinner instead of the label

  @override
  Widget build(BuildContext context) {
    final c = AuthColors.of(context);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandNavy,
          disabledBackgroundColor: AppColors.brandNavy.withValues(alpha: 0.6),
          foregroundColor: c.isDark ? AppColors.borderOutline : Colors.white,
          side: c.isDark ? const BorderSide(color: Color(0xFF3F7FB0)) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.borderOutline,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

// "or" line between the form and the Google button
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AuthColors.of(context);
    return Row(
      children: [
        Expanded(child: Divider(color: c.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or', style: TextStyle(color: c.secondaryText)),
        ),
        Expanded(child: Divider(color: c.border)),
      ],
    );
  }
}

class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading; // shows a spinner instead of the label

  @override
  Widget build(BuildContext context) {
    final c = AuthColors.of(context);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: c.field,
          side: BorderSide(color: c.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: c.accent,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // put Google's official "G" logo in assets/images/google_logo.png
                  Image.asset(
                    'assets/images/google_logo.png',
                    width: 22,
                    height: 22,
                    errorBuilder: (_, __, ___) => Text(
                      'G',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: c.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// red banner for errors, accent banner for good news
class AuthBanner extends StatelessWidget {
  const AuthBanner({super.key, required this.message, this.isError = true});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final c = AuthColors.of(context);
    final color = isError ? c.error : c.accent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }
}

// shows which role the user chose
class AuthRoleChip extends StatelessWidget {
  const AuthRoleChip({super.key, required this.role, required this.prefix});

  final UserRole role;
  final String prefix; // example: "Signing up as"

  @override
  Widget build(BuildContext context) {
    final c = AuthColors.of(context);

    final icon = switch (role) {
      UserRole.creator => Icons.code_rounded,
      UserRole.company => Icons.apartment_rounded,
      UserRole.admin => Icons.shield_rounded,
    };
    final name = switch (role) {
      UserRole.creator => 'Creator',
      UserRole.company => 'Company',
      UserRole.admin => 'Admin',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: c.accent),
          const SizedBox(width: 6),
          Text(
            '$prefix $name',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.accent,
            ),
          ),
        ],
      ),
    );
  }
}