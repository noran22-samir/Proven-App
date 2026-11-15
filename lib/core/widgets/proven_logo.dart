import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:proven/core/theme/colors.dart';

// The Proven logo: navy badge, lavender "P" and a small gold check.
class ProvenLogo extends StatelessWidget {
  const ProvenLogo({super.key, this.size = 56, this.showBorder = false});

  final double size;

  // light blue border, use it when the logo sits on a dark or navy background
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ProvenLogoPainter(showBorder)),
    );
  }
}

class _ProvenLogoPainter extends CustomPainter {
  final bool showBorder;
  const _ProvenLogoPainter(this.showBorder);

  @override
  void paint(Canvas canvas, Size size) {
    // everything below is drawn on a 200 x 200 grid
    canvas.scale(size.width / 200, size.height / 200);

    // navy badge
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 200, 200),
        const Radius.circular(48),
      ),
      Paint()..color = AppColors.brandNavy,
    );

    // optional light blue border
    if (showBorder) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(1, 1, 198, 198),
          const Radius.circular(47),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF3F7FB0),
      );
    }

    canvas.translate(-8, 0);

    // the letter P
    final letterP = Path()
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
    canvas.drawPath(
      letterP,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.borderOutline,
    );

    // the gold check inside the P
    final check = Path()
      ..moveTo(95, 91)
      ..lineTo(104, 100)
      ..lineTo(120, 80);
    canvas.drawPath(
      check,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFFF2B84B),
    );
  }

  @override
  bool shouldRepaint(_ProvenLogoPainter old) => old.showBorder != showBorder;
}
