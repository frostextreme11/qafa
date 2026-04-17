import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../widgets/glass_card.dart';
import 'map_kabba_screen.dart';


class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  CompassEvent? _compassEvent;
  double? _qiblahDirection;
  bool _hasPermission = false;
  bool _isLoading = true;
  bool _isRefreshing = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
    _refreshLocation();
    _initCompass();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refreshLocation() async {
    setState(() {
      _isRefreshing = true;
      if (_currentPosition == null) _isLoading = true;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() { _hasPermission = false; _isLoading = false; _isRefreshing = false; });
          return;
        }
      }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _hasPermission = true;
        _isLoading = false;
        _isRefreshing = false;
      });
      _calculateQiblahDirection();
    } catch (e) {
      setState(() { _hasPermission = false; _isLoading = false; _isRefreshing = false; });
    }
  }

  void _initCompass() {
    FlutterCompass.events?.listen((CompassEvent event) {
      if (mounted) setState(() => _compassEvent = event);
    });
  }

  void _calculateQiblahDirection() {
    if (_currentPosition == null) return;
    const double kaabaLat = 21.4225;
    const double kaabaLng = 39.8262;
    final double lat = _currentPosition!.latitude * math.pi / 180;
    final double lng = _currentPosition!.longitude * math.pi / 180;
    final double kaabaLatRad = kaabaLat * math.pi / 180;
    final double kaabaLngRad = kaabaLng * math.pi / 180;
    final double deltaLng = kaabaLngRad - lng;
    final double y = math.sin(deltaLng);
    final double x = math.cos(lat) * math.tan(kaabaLatRad) - math.sin(lat) * math.cos(deltaLng);
    double qiblah = math.atan2(y, x) * 180 / math.pi;
    if (qiblah < 0) qiblah += 360;
    setState(() => _qiblahDirection = qiblah);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned(
          top: 100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor.withOpacity(0.03),
            ),
          ),
        ),
        _hasPermission ? _buildMainUI(isDark) : _buildNoPermissionUI(),
      ],
    );
  }

  Widget _buildMainUI(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildArrowView(isDark),
          const SizedBox(height: 40),
          _buildInfoCard(isDark),
        ],
      ),
    );
  }

  Widget _buildArrowView(bool isDark) {
    final heading = _compassEvent?.heading ?? 0;
    final qiblah = _qiblahDirection ?? 0;
    final double relativeRotation = (qiblah - heading) * (math.pi / 180);
    final isPointing = (qiblah - heading).abs() < 3;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? Colors.white10 : Colors.black12, width: 1),
            ),
            child: CustomPaint(painter: CardinalPainter(color: isDark ? Colors.white24 : Colors.black12)),
          ),
          Transform.rotate(
            angle: relativeRotation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (rect) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor, 
                      Theme.of(context).primaryColor.withOpacity(isDark ? 0.1 : 0.8)
                    ],
                  ).createShader(rect),
                  child: Icon(Icons.navigation_rounded, size: 180, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 12),
                Text(
                  'KIBLAT',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    fontSize: 10,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          if (isPointing)
            Positioned(
              top: 50,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, color: Colors.greenAccent, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'ALIGNED',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            fontSize: 10,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRECISION DIRECTION',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_qiblahDirection?.toStringAsFixed(1) ?? '--'}° North-East',
                      style: GoogleFonts.manrope(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _isRefreshing ? null : _refreshLocation,
                  icon: Icon(_isRefreshing ? Icons.sync : Icons.refresh_rounded),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.location_on_rounded, size: 12, color: isDark ? Colors.white30 : Colors.black26),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentPosition != null
                      ? '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}'
                      : 'Detecting Location...',
                    style: GoogleFonts.inter(fontSize: 11, color: isDark ? Colors.white24 : Colors.black26),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _currentPosition == null ? null : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MapKabbaScreen(
                        userLat: _currentPosition!.latitude,
                        userLng: _currentPosition!.longitude,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map_rounded),
                label: const Text('MAPS TO KABBAH'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  textStyle: GoogleFonts.manrope(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPermissionUI() => const Center(child: Text('Location permission required'));
}

class CardinalPainter extends CustomPainter {
  final Color color;
  CardinalPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      canvas.drawLine(
        Offset(center.dx + math.cos(angle) * (radius - 10), center.dy + math.sin(angle) * (radius - 10)),
        Offset(center.dx + math.cos(angle) * radius, center.dy + math.sin(angle) * radius),
        paint,
      );
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}