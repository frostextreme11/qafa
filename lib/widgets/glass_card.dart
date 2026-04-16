import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isAsymmetric;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 20,
    this.opacity = 0.08,
    this.padding,
    this.margin,
    this.isAsymmetric = true,
    this.borderRadius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final radius = isAsymmetric 
      ? BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
          bottomLeft: const Radius.circular(0),
        )
      : BorderRadius.circular(borderRadius);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          if (isDark) BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark 
                ? const Color(0xFF042A36).withOpacity(opacity)
                : Colors.white.withOpacity(opacity + 0.5),
              borderRadius: radius,
              border: Border.all(
                color: (isDark ? const Color(0xFF3CE36A) : Colors.green).withOpacity(0.15), // Ghost Border
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}