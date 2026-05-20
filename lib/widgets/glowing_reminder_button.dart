import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlowingReminderButton extends StatefulWidget {
  final bool isReminderEnabled;
  final VoidCallback onPressed;
  final String activeLabel;
  final String inactiveLabel;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final Color activeColor;
  final Color inactiveColor;
  final bool isDark;

  const GlowingReminderButton({
    super.key,
    required this.isReminderEnabled,
    required this.onPressed,
    required this.activeLabel,
    required this.inactiveLabel,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.activeColor,
    required this.inactiveColor,
    required this.isDark,
  });

  @override
  State<GlowingReminderButton> createState() => _GlowingReminderButtonState();
}

class _GlowingReminderButtonState extends State<GlowingReminderButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.025).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.025, end: 1.0).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 50,
      ),
    ]).animate(_pulseController);

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 0.85).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.85, end: 0.3).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_pulseController);

    if (widget.isReminderEnabled) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant GlowingReminderButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isReminderEnabled != oldWidget.isReminderEnabled) {
      if (widget.isReminderEnabled) {
        _pulseController.repeat();
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isReminderEnabled) {
      return TextButton.icon(
        style: TextButton.styleFrom(
          backgroundColor: widget.isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
          foregroundColor: widget.inactiveColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onPressed: widget.onPressed,
        icon: Icon(widget.inactiveIcon, size: 16),
        label: Text(
          widget.inactiveLabel,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: widget.activeColor.withOpacity(0.25 * _glowAnimation.value),
                  blurRadius: 12.0 * _glowAnimation.value,
                  spreadRadius: 1.0 * _glowAnimation.value,
                ),
              ],
            ),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: widget.activeColor.withOpacity(0.12),
                foregroundColor: widget.activeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: widget.activeColor.withOpacity(0.2 + 0.5 * _glowAnimation.value),
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: widget.onPressed,
              icon: Icon(widget.activeIcon, size: 16),
              label: Text(
                widget.activeLabel,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: widget.activeColor.withOpacity(0.6 * _glowAnimation.value),
                      blurRadius: 4.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
