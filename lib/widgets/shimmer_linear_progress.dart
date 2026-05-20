import 'package:flutter/material.dart';

class ShimmerLinearProgress extends StatefulWidget {
  final double value;
  final Color color;
  final Color backgroundColor;
  final double height;

  const ShimmerLinearProgress({
    super.key,
    required this.value,
    required this.color,
    required this.backgroundColor,
    this.height = 6.0,
  });

  @override
  State<ShimmerLinearProgress> createState() => _ShimmerLinearProgressState();
}

class _ShimmerLinearProgressState extends State<ShimmerLinearProgress> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _ShimmerLinearProgressPainter(
            progress: widget.value.clamp(0.0, 1.0),
            color: widget.color,
            backgroundColor: widget.backgroundColor,
            shimmerValue: _shimmerController.value,
          ),
        );
      },
    );
  }
}

class _ShimmerLinearProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double shimmerValue;

  _ShimmerLinearProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.shimmerValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    
    // 1. Draw Background Path
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    
    final bgRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      radius,
    );
    canvas.drawRRect(bgRRect, bgPaint);

    if (progress <= 0) return;

    // 2. Draw Filled Progress Path
    final filledWidth = size.width * progress;
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final progressRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, filledWidth, size.height),
      radius,
    );
    canvas.drawRRect(progressRRect, progressPaint);

    // 3. Draw Shimmer Highlight Overlay (clipped to filled path)
    canvas.save();
    canvas.clipRRect(progressRRect);

    // Calculate shimmer highlight coordinate: moves from left margin (with offset) to right margin
    final shimmerWidth = size.width * 0.4; // width of the glow effect
    final startX = -shimmerWidth;
    final endX = filledWidth + shimmerWidth;
    final currentX = startX + (endX - startX) * shimmerValue;

    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.15),
          Colors.white.withOpacity(0.6), // bright central highlight line
          Colors.white.withOpacity(0.15),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
      ).createShader(
        Rect.fromLTWH(currentX, 0, shimmerWidth, size.height),
      )
      ..style = PaintingStyle.fill;

    // We can draw a slanted rectangle to simulate a diagonal shimmer line
    final path = Path()
      ..moveTo(currentX - 10, 0)
      ..lineTo(currentX + shimmerWidth - 10, 0)
      ..lineTo(currentX + shimmerWidth + 10, size.height)
      ..lineTo(currentX + 10, size.height)
      ..close();

    canvas.drawPath(path, shimmerPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShimmerLinearProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.shimmerValue != shimmerValue;
  }
}
