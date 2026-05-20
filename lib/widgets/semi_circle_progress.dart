import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedSemiCircleProgress extends StatefulWidget {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool glow;

  const AnimatedSemiCircleProgress({
    super.key,
    required this.progress,
    required this.color,
    this.strokeWidth = 16,
    this.glow = true,
  });

  @override
  State<AnimatedSemiCircleProgress> createState() => _AnimatedSemiCircleProgressState();
}

class _AnimatedSemiCircleProgressState extends State<AnimatedSemiCircleProgress> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<double> _beadAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Breathe-in, breathe-out opacity sequence
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.3).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Continuous sweep of the bead from 0 to current progress
    _beadAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SemiCircleProgressPainter(
            progress: widget.progress.clamp(0.0, 1.0),
            color: widget.color,
            strokeWidth: widget.strokeWidth,
            glow: widget.glow,
            glowValue: _glowAnimation.value,
            beadValue: _beadAnimation.value,
          ),
        );
      },
    );
  }
}

class SemiCircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool glow;
  final double glowValue;  // Breathing glow coefficient [0.3 - 1.0]
  final double beadValue;  // Continuous bead sweeping position [0.0 - 1.0]

  SemiCircleProgressPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 8,
    this.glow = false,
    this.glowValue = 1.0,
    this.beadValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85);
    final radius = min(size.width / 2, size.height * 0.65) - strokeWidth / 2;

    // 1. Draw static background tracking arc
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi, // Left point
      pi, // 180 degrees sweep
      false,
      backgroundPaint,
    );

    if (progress <= 0) return;

    // 2. Draw breathing glow backdrops behind progress line
    if (glow) {
      final glowPaint1 = Paint()
        ..color = color.withOpacity(0.15 * glowValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      final glowPaint2 = Paint()
        ..color = color.withOpacity(0.35 * glowValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

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

    // 3. Draw high-fidelity solid progress line
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * progress,
      false,
      progressPaint,
    );

    // 4. Draw continuous glowing solar bead sweeping along progress path
    final double activeAngle = pi + (pi * progress * beadValue);
    final Offset beadCenter = Offset(
      center.dx + radius * cos(activeAngle),
      center.dy + radius * sin(activeAngle),
    );

    // Bead outer neon aura glow
    final beadGlowPaint = Paint()
      ..color = color.withOpacity(0.85)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(beadCenter, strokeWidth * 0.9, beadGlowPaint);

    // Bead medium glow ring
    final beadMidPaint = Paint()
      ..color = color.withOpacity(0.95)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(beadCenter, strokeWidth * 0.6, beadMidPaint);

    // Bead bright white core
    final beadCorePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(beadCenter, strokeWidth * 0.35, beadCorePaint);
  }

  @override
  bool shouldRepaint(SemiCircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.glow != glow ||
        oldDelegate.glowValue != glowValue ||
        oldDelegate.beadValue != beadValue;
  }
}