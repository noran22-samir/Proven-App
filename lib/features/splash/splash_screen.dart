//update splash
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proven/core/theme/colors.dart';

/// Animated splash screen for Proven.
///
/// Supports Light/Dark (follows Theme.of(context).brightness) and
/// English/Arabic (follows the app locale). Calls [onFinished] when the
/// progress bar reaches 100%.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onFinished,
    this.version = '1.0.0',
  });

  final VoidCallback onFinished;
  final String version;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // One timeline drives every intro animation (3.6s in total).
  late final AnimationController _timeline = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  );

  // Slow loop for the background rings.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );

  @override
  void initState() {
    super.initState();
    _pulse.repeat(reverse: true);
    _timeline.forward().whenComplete(() {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _timeline.dispose();
    _pulse.dispose();
    super.dispose();
  }

  /// Progress (0..1) of the timeline between [begin] and [end].
  double _t(double begin, double end, [Curve curve = Curves.easeOutCubic]) =>
      Interval(begin, end, curve: curve).transform(_timeline.value);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final p = isDark ? _Palette.dark : _Palette.light;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: p.background,
      ),
      child: Scaffold(
        backgroundColor: p.background,
        body: AnimatedBuilder(
          animation: Listenable.merge([_timeline, _pulse]),
          builder: (context, _) => _buildBody(context, p, isDark, isArabic),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    _Palette p,
    bool isDark,
    bool isArabic,
  ) {
    final size = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final badge = math.min(size.width * 0.34, 140.0);
    final centerY = size.height * 0.42;

    // Timeline: 0.00 - 1.00 = 0s - 3.6s
    final badgeT = _t(0.00, 0.14); // badge fades in + scales up
    final pT = _t(0.11, 0.25, Curves.easeInOut); // "P" draws itself
    final checkT = _t(0.25, 0.33, Curves.easeOut); // gold check draws
    final wordT = _t(0.25, 0.36); // wordmark
    final line1T = _t(0.33, 0.40); // slogan line 1
    final line2T = _t(0.42, 0.50); // slogan line 2
    final versionT = _t(0.05, 0.15);
    final barT = _t(0.12, 0.85, Curves.easeInOut); // progress bar
    final pulse = 1 + 0.04 * Curves.easeInOut.transform(_pulse.value);

    final line1 = isArabic ? 'لا تخبرهم.' : "Don't tell them.";
    final line2 = isArabic ? 'أرِهم.' : 'Show them.';
    final versionText =
        isArabic ? 'الإصدار ${widget.version}' : 'Version ${widget.version}';

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.16),
          radius: 0.95,
          colors: p.gradient,
          stops: p.stops,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _RingsPainter(
                center: Offset(size.width / 2, centerY),
                color: p.ring,
                alphas: p.ringAlphas,
                scale: pulse,
                fade: badgeT,
              ),
            ),
          ),
          Positioned(
            top: centerY - badge / 2,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  opacity: badgeT,
                  child: Transform.scale(
                    scale: 0.85 + 0.15 * badgeT,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(badge * 0.24),
                        boxShadow: [
                          BoxShadow(
                            color: p.glow,
                            blurRadius: isDark ? 64 : 32,
                            offset: Offset(0, isDark ? 0 : 12),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: badge,
                        height: badge,
                        child: CustomPaint(
                          painter: _LogoPainter(
                            pProgress: pT,
                            checkProgress: checkT,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                _reveal(
                  wordT,
                  10,
                  Text(
                    'Proven',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      height: 1.1,
                      color: p.wordmark,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _reveal(
                  line1T,
                  8,
                  Text(
                    line1,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: p.sloganMain),
                  ),
                ),
                const SizedBox(height: 2),
                _reveal(
                  line2T,
                  8,
                  Text(
                    line2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: p.sloganAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 56 + bottomInset,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ProgressBar(value: barT, track: p.track, fill: p.fill),
                const SizedBox(height: 14),
                Opacity(
                  opacity: versionT,
                  child: Text(
                    versionText,
                    style: TextStyle(
                      fontSize: 12,
                      // letterSpacing breaks Arabic letter joining, so skip it.
                      letterSpacing: isArabic ? 0 : 0.7,
                      color: p.version,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reveal(double t, double dy, Widget child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, dy * (1 - t)), child: child),
      );
}

// ---------------------------------------------------------------------------
// Colors (Light / Dark). Reuses AppColors where a token already exists.
// Consider moving the dark values into AppColors later.
// ---------------------------------------------------------------------------
class _Palette {
  const _Palette({
    required this.background,
    required this.gradient,
    required this.stops,
    required this.wordmark,
    required this.sloganMain,
    required this.sloganAccent,
    required this.track,
    required this.fill,
    required this.version,
    required this.ring,
    required this.ringAlphas,
    required this.glow,
  });

  final Color background;
  final List<Color> gradient;
  final List<double> stops;
  final Color wordmark;
  final Color sloganMain;
  final Color sloganAccent;
  final Color track;
  final Color fill;
  final Color version;
  final Color ring;
  final List<double> ringAlphas;
  final Color glow;

  static const light = _Palette(
    background: AppColors.canvasBackground,
    gradient: [Color(0xFFFFFFFF), AppColors.canvasBackground],
    stops: [0.0, 0.9],
    wordmark: AppColors.brandNavy,
    sloganMain: AppColors.textSecondary,
    sloganAccent: Color(0xFF8F5B00),
    track: AppColors.borderOutline,
    fill: AppColors.brandNavy,
    version: AppColors.textSecondary,
    ring: AppColors.borderOutline,
    ringAlphas: [0.50, 0.30, 0.15],
    glow: Color(0x2E003153),
  );

  static const dark = _Palette(
    background: Color(0xFF00111F),
    gradient: [Color(0xFF01304F), Color(0xFF00182B), Color(0xFF00111F)],
    stops: [0.0, 0.55, 1.0],
    wordmark: AppColors.borderOutline,
    sloganMain: Color(0xD9C4C3D0),
    sloganAccent: Color(0xFFF2BE5C),
    track: Color(0x2EC4C3D0),
    fill: Color(0xFFF2BE5C),
    version: Color(0xBFC4C3D0),
    ring: AppColors.borderOutline,
    ringAlphas: [0.10, 0.07, 0.04],
    glow: Color(0x663F7FB0),
  );
}

// ---------------------------------------------------------------------------
// Logo: navy badge + "P" stroke + gold check (drawn on a 200x200 grid)
// ---------------------------------------------------------------------------
class _LogoPainter extends CustomPainter {
  const _LogoPainter({
    required this.pProgress,
    required this.checkProgress,
    required this.isDark,
  });

  final double pProgress;
  final double checkProgress;
  final bool isDark;

  static const _gold = Color(0xFFF2B84B);
  static const _rim = Color(0xFF3F7FB0);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 200, size.height / 200);

    // Badge
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 200, 200),
        const Radius.circular(48),
      ),
      Paint()..color = AppColors.brandNavy,
    );
    if (isDark) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(1, 1, 198, 198),
          const Radius.circular(47),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = _rim,
      );
    }

    canvas.translate(-8, 0);

    // The "P"
    final pPath = Path()
      ..moveTo(75, 150)
      ..lineTo(75, 57)
      ..lineTo(108, 57)
      ..arcTo(
        Rect.fromCircle(center: const Offset(108, 90), radius: 33),
        -math.pi / 2,
        math.pi,
        false,
      )
      ..lineTo(75, 123);
    _strokeTrimmed(
      canvas,
      pPath,
      pProgress,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.borderOutline,
    );

    // The check (with a tiny pop while it draws)
    final checkPath = Path()
      ..moveTo(95, 91)
      ..lineTo(104, 100)
      ..lineTo(120, 80);
    canvas.save();
    final pop = 1 + 0.15 * math.sin(math.pi * checkProgress);
    canvas.translate(107.5, 90);
    canvas.scale(pop);
    canvas.translate(-107.5, -90);
    _strokeTrimmed(
      canvas,
      checkPath,
      checkProgress,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = _gold,
    );
    canvas.restore();

    canvas.restore();
  }

  /// Draws only the first [t] (0..1) of [path]'s length.
  void _strokeTrimmed(Canvas canvas, Path path, double t, Paint paint) {
    if (t <= 0) return;
    if (t >= 1) {
      canvas.drawPath(path, paint);
      return;
    }
    final metrics = path.computeMetrics().toList();
    final total = metrics.fold<double>(0, (sum, m) => sum + m.length);
    var remaining = total * t;
    for (final m in metrics) {
      if (remaining <= 0) break;
      final len = math.min(m.length, remaining);
      canvas.drawPath(m.extractPath(0, len), paint);
      remaining -= len;
    }
  }

  @override
  bool shouldRepaint(_LogoPainter old) =>
      old.pProgress != pProgress ||
      old.checkProgress != checkProgress ||
      old.isDark != isDark;
}

// ---------------------------------------------------------------------------
// Background rings (slow pulse)
// ---------------------------------------------------------------------------
class _RingsPainter extends CustomPainter {
  const _RingsPainter({
    required this.center,
    required this.color,
    required this.alphas,
    required this.scale,
    required this.fade,
  });

  final Offset center;
  final Color color;
  final List<double> alphas;
  final double scale;
  final double fade;

  static const _diameters = [260.0, 380.0, 520.0];

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < _diameters.length; i++) {
      canvas.drawCircle(
        center,
        _diameters[i] / 2 * scale,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = color.withValues(alpha: alphas[i] * fade),
      );
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) =>
      old.scale != scale ||
      old.fade != fade ||
      old.color != color ||
      old.center != center;
}

// ---------------------------------------------------------------------------
// Progress bar (160 x 4)
// ---------------------------------------------------------------------------
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.value,
    required this.track,
    required this.fill,
  });

  final double value;
  final Color track;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: track)),
            Positioned.fill(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0).toDouble(),
                  heightFactor: 1,
                  child: ColoredBox(color: fill),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}