import 'dart:math';
import 'package:flutter/material.dart';

class SemiCircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool glow;

  SemiCircleProgressPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 8,
    this.glow = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.8);
    final radius = min(size.width / 2, size.height * 0.6) - strokeWidth / 2;

    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (glow) {
      // Draw glow effect with multiple layers
      final glowPaint1 = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      final glowPaint2 = Paint()
        ..color = color.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 2
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      // Draw glow layers
      if (progress > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          pi,
          pi * progress,
          false,
          glowPaint1,
        );
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          pi,
          pi * progress,
          false,
          glowPaint2,
        );
      }

      progressPaint.color = color;
    }

    // Draw background arc (180 degrees, from left to right at bottom)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi, // Start from left (180 degrees)
      pi, // 180 degrees sweep
      false,
      backgroundPaint,
    );

    // Draw progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        pi, // Start from left (180 degrees)
        pi * progress, // Progress angle sweep
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(SemiCircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth ||
           oldDelegate.glow != glow;
  }
}