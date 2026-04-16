import 'package:flutter/material.dart';
import '../providers/fasting_provider.dart';

class BlinkingMarkers extends StatefulWidget {
  final List<FastingDay> fastingDays;

  const BlinkingMarkers({super.key, required this.fastingDays});

  @override
  State<BlinkingMarkers> createState() => _BlinkingMarkersState();
}

class _BlinkingMarkersState extends State<BlinkingMarkers>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.fastingDays.map((fastingDay) {
            return Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: fastingDay.type.color.withOpacity(_animation.value),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: fastingDay.type.color.withOpacity(_animation.value * 0.5),
                    blurRadius: 3,
                    spreadRadius: 1,
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}