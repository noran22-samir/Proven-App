import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:proven/core/theme/colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinished});

  // called when the user taps Skip or "Get Started Now"
  final VoidCallback onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // each page has a different color in light and dark mode
  final List<_OnboardingItem> _pages = const [
    _OnboardingItem(
      tag: 'VERIFIED IP · DIRECT EGP ESCROW',
      title: 'Turn Code into Equity',
      description:
          'Monetize your final-year graduation capstone directly with verified Egyptian enterprises.',
      lightColor: AppColors.brandNavy,
      darkColor: Color(0xFF7FB3DC),
    ),
    _OnboardingItem(
      tag: '256-BIT MILESTONE · ZERO DISPUTE RISK',
      title: 'Bank-Grade Escrow',
      description:
          'Funds are held in regulated custody until full technical and code inspection passes.',
      lightColor: Color(0xFF8F5B00),
      darkColor: Color(0xFFF2BE5C),
    ),
    _OnboardingItem(
      tag: 'INSTANT OFFERS · DIRECT ACQUISITION',
      title: 'Smart AI Matching',
      description:
          'Get paired directly with corporate technology leaders ready to acquire your software.',
      lightColor: Color(0xFF1F4FB2),
      darkColor: Color(0xFF6FB1E8),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == _pages.length - 1) {
      widget.onFinished();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF07121C) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // top bar: app name + skip
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Proven',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.borderOutline : AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onFinished,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: isDark ? AppColors.borderOutline : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // the 3 pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => _buildPage(index, isDark),
              ),
            ),

            _buildDots(isDark),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _buildButtons(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index, bool isDark) {
    final item = _pages[index];
    final color = isDark ? item.darkColor : item.lightColor;
    final lineColor = isDark ? const Color(0xFF2A4A66) : const Color(0xFFB9C3D3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // illustration card
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.10 : 0.07),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A4A66) : const Color(0xFFE3E8F2),
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // dotted circle behind the drawing
                  CustomPaint(painter: _RingPainter(lineColor)),
                  // the drawing is made on a 300x220 area,
                  // FittedBox scales it to fit the card
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: FittedBox(
                      child: SizedBox(
                        width: 300,
                        height: 220,
                        child: _buildIllustration(index, isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // small colored tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.tag,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            item.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.borderOutline : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDark
                  ? AppColors.borderOutline.withValues(alpha: 0.7)
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildIllustration(int index, bool isDark) {
    if (index == 0) return _laptopIllustration(isDark);
    if (index == 1) return _shieldIllustration(isDark);
    return _aiIllustration(isDark);
  }

  // ---------------------------------------------------------------------
  // Illustration 1: laptop with code + graduation cap
  // ---------------------------------------------------------------------
  Widget _laptopIllustration(bool isDark) {
    return Stack(
      children: [
        // laptop screen
        Positioned(
          left: 50,
          top: 38,
          width: 200,
          height: 124,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0E2237),
              borderRadius: BorderRadius.circular(12),
              boxShadow: _shadow(isDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // window buttons
                Row(
                  children: [
                    _dot(const Color(0xFFFF6B6B)),
                    const SizedBox(width: 4),
                    _dot(const Color(0xFFF2B84B)),
                    const SizedBox(width: 4),
                    _dot(const Color(0xFF4CC38A)),
                  ],
                ),
                const SizedBox(height: 12),
                // fake code lines
                _codeLine(110, const Color(0xFF7FB3DC)),
                const SizedBox(height: 7),
                _codeLine(150, const Color(0x66C4C3D0)),
                const SizedBox(height: 7),
                _codeLine(90, const Color(0x66C4C3D0)),
                const SizedBox(height: 7),
                _codeLine(130, const Color(0xFFF2B84B)),
                const Spacer(),
                // green "success" bar
                Container(
                  width: 76,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F9D6B),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
          ),
        ),

        // laptop base
        Positioned(
          left: 30,
          top: 162,
          width: 240,
          height: 12,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A4A66) : const Color(0xFFD9DFE9),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
          ),
        ),

        // graduation cap badge
        Positioned(
          right: 14,
          top: 12,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.brandNavy,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3F7FB0), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40003153),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Color(0xFFF2B84B),
              size: 30,
            ),
          ),
        ),

        // small card on the left (git branch)
        Positioned(
          left: 2,
          top: 96,
          child: _floatingCard(
            width: 58,
            height: 64,
            isDark: isDark,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_tree_rounded, size: 22, color: _iconColor(isDark)),
                const SizedBox(height: 6),
                Container(
                  width: 30,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F9D6B),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Illustration 2: shield with a lock + EGP card + document card
  // ---------------------------------------------------------------------
  Widget _shieldIllustration(bool isDark) {
    final iconColor = _iconColor(isDark);

    return Stack(
      children: [
        // shield (drawn by _ShieldPainter) with the lock on top
        Positioned(
          left: 95,
          top: 30,
          width: 110,
          height: 130,
          child: CustomPaint(
            painter: _ShieldPainter(),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(
                  Icons.lock_rounded,
                  size: 46,
                  color: Color(0xFFF2B84B),
                ),
              ),
            ),
          ),
        ),

        // EGP card on the left
        Positioned(
          left: 4,
          top: 84,
          child: _floatingCard(
            width: 62,
            height: 62,
            isDark: isDark,
            child: Text(
              'EGP',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: iconColor,
              ),
            ),
          ),
        ),

        // document with a check on the right
        Positioned(
          right: 4,
          top: 76,
          child: _floatingCard(
            width: 66,
            height: 78,
            isDark: isDark,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _docLine(iconColor.withValues(alpha: 0.35)),
                const SizedBox(height: 6),
                _docLine(iconColor.withValues(alpha: 0.20)),
                const SizedBox(height: 10),
                const Icon(
                  Icons.check_circle_rounded,
                  size: 24,
                  color: Color(0xFF1F9D6B),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Illustration 3: AI in the middle connected to two cards
  // ---------------------------------------------------------------------
  Widget _aiIllustration(bool isDark) {
    final iconColor = _iconColor(isDark);
    final lineColor = isDark ? const Color(0xFF2A4A66) : const Color(0xFFB9C3D3);

    return Stack(
      children: [
        // dotted lines between the cards
        Positioned.fill(
          child: CustomPaint(painter: _ConnectorsPainter(lineColor)),
        ),

        // AI box in the middle
        Positioned(
          left: 110,
          top: 78,
          width: 80,
          height: 80,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.brandNavy,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF3F7FB0), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x663F7FB0),
                  blurRadius: 28,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFF2B84B),
              size: 38,
            ),
          ),
        ),

        // person card on the left
        Positioned(
          left: 6,
          top: 80,
          child: _floatingCard(
            width: 66,
            height: 76,
            isDark: isDark,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_rounded, size: 26, color: iconColor),
                const SizedBox(height: 8),
                Container(
                  width: 34,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F9D6B),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ),

        // bot card on the right
        Positioned(
          right: 6,
          top: 80,
          child: _floatingCard(
            width: 66,
            height: 76,
            isDark: isDark,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.smart_toy_rounded, size: 26, color: iconColor),
                const SizedBox(height: 8),
                Container(
                  width: 34,
                  height: 6,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.30),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // small helpers used by the illustrations
  // ---------------------------------------------------------------------
  Color _iconColor(bool isDark) {
    return isDark ? const Color(0xFF7FB3DC) : AppColors.brandNavy;
  }

  List<BoxShadow> _shadow(bool isDark) {
    if (isDark) return [];
    return const [
      BoxShadow(color: Color(0x1A003153), blurRadius: 16, offset: Offset(0, 6)),
    ];
  }

  // small white (or dark) card that floats next to the main drawing
  Widget _floatingCard({
    required double width,
    required double height,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132B40) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A4A66) : const Color(0xFFE3E8F2),
        ),
        boxShadow: _shadow(isDark),
      ),
      child: child,
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _codeLine(double width, Color color) {
    return Container(
      width: width,
      height: 5,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _docLine(Color color) {
    return Container(
      width: 34,
      height: 5,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // dots + buttons
  // ---------------------------------------------------------------------
  Widget _buildDots(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? const Color(0xFF7FB3DC) : AppColors.brandNavy)
                : (isDark ? const Color(0xFF2A4A66) : AppColors.borderOutline),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildButtons(bool isDark) {
    final isLastPage = _currentPage == _pages.length - 1;
    final buttonTextColor = isDark ? AppColors.borderOutline : Colors.white;
    final borderColor = isDark ? const Color(0xFF3F7FB0) : AppColors.borderOutline;

    return Row(
      children: [
        // Back button only shows on the second page
        if (_currentPage == 1) ...[
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF7FB3DC) : AppColors.brandNavy,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _nextPage,
              iconAlignment: IconAlignment.end,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandNavy,
                foregroundColor: buttonTextColor,
                side: isDark ? const BorderSide(color: Color(0xFF3F7FB0)) : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(
                isLastPage ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                size: 20,
              ),
              label: Text(
                isLastPage ? 'Get Started Now' : 'Continue',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// the text and colors of one onboarding page
class _OnboardingItem {
  final String tag;
  final String title;
  final String description;
  final Color lightColor;
  final Color darkColor;

  const _OnboardingItem({
    required this.tag,
    required this.title,
    required this.description,
    required this.lightColor,
    required this.darkColor,
  });
}

// ---------------------------------------------------------------------------
// Custom drawings (shapes that Flutter has no ready widget for)
// ---------------------------------------------------------------------------

// draws a path as dashes instead of one solid line
void _drawDashed(Canvas canvas, Path path, Paint paint, double dash, double gap) {
  for (final metric in path.computeMetrics()) {
    double distance = 0;
    while (distance < metric.length) {
      final end = math.min(distance + dash, metric.length);
      canvas.drawPath(metric.extractPath(distance, end), paint);
      distance += dash + gap;
    }
  }
}

// the dotted circle behind each illustration
class _RingPainter extends CustomPainter {
  final Color color;
  const _RingPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width, size.height) * 0.42;
    final circle = Path()
      ..addOval(Rect.fromCircle(center: size.center(Offset.zero), radius: radius));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = color;

    _drawDashed(canvas, circle, paint, 1.5, 7);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.color != color;
}

// the shield shape on the second page
class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final shield = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w * 0.95, h * 0.14)
      ..lineTo(w * 0.95, h * 0.48)
      ..cubicTo(w * 0.95, h * 0.76, w * 0.75, h * 0.92, w * 0.5, h)
      ..cubicTo(w * 0.25, h * 0.92, w * 0.05, h * 0.76, w * 0.05, h * 0.48)
      ..lineTo(w * 0.05, h * 0.14)
      ..close();

    // shadow
    canvas.drawShadow(shield, const Color(0x66003153), 10, true);

    // navy fill
    canvas.drawPath(
      shield,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A4672), AppColors.brandNavy],
        ).createShader(Offset.zero & size),
    );

    // gold border
    canvas.drawPath(
      shield,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFFF2B84B),
    );
  }

  @override
  bool shouldRepaint(_ShieldPainter old) => false;
}

// the dotted lines + orange dot on the third page
class _ConnectorsPainter extends CustomPainter {
  final Color color;
  const _ConnectorsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = color;
    final left = Path()
      ..moveTo(72, 118)
      ..lineTo(110, 118);
    // AI box -> right card
    final right = Path()
      ..moveTo(190, 118)
      ..lineTo(228, 118);
    // curve over the top between the two cards
    final arc = Path()
      ..moveTo(39, 78)
      ..quadraticBezierTo(150, 6, 261, 78);

    _drawDashed(canvas, left, paint, 4, 5);
    _drawDashed(canvas, right, paint, 4, 5);
    _drawDashed(canvas, arc, paint, 4, 5);

    // orange dot on top of the curve
    canvas.drawCircle(
      const Offset(150, 42),
      4.5,
      Paint()..color = const Color(0xFFF59E0B),
    );
  }

  @override
  bool shouldRepaint(_ConnectorsPainter old) => old.color != color;
}