import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_card.dart';
import '../providers/water_provider.dart';
import '../providers/settings_provider.dart';

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _waveController;
  late AnimationController _fillController;
  late Animation<double> _fillAnimation;

  DateTime _selectedDate = DateTime.now();
  bool _showSuccessAnimation = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    
    _waveController = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat();
    _fillController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _fillAnimation = Tween<double>(begin: 0, end: 0).animate(CurvedAnimation(parent: _fillController, curve: Curves.easeInOutCubic));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _waveController.dispose();
    _fillController.dispose();
    super.dispose();
  }

  void _updateFillAnimation(double targetProgress) {
    _fillAnimation = Tween<double>(begin: _fillAnimation.value, end: targetProgress).animate(
      CurvedAnimation(parent: _fillController, curve: Curves.easeInOutCubic),
    );
    _fillController.reset();
    _fillController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final waterProvider = Provider.of<WaterProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sahur = waterProvider.getWaterAmount(_selectedDate, 'sahur');
    final berbuka = waterProvider.getWaterAmount(_selectedDate, 'berbuka');
    final malam = waterProvider.getWaterAmount(_selectedDate, 'malam');
    
    final total = sahur + berbuka + malam;
    final progress = (total / WaterProvider.totalTarget).clamp(0.0, 1.0);
    
    _updateFillAnimation(progress);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildDatePicker(isDark),
            const SizedBox(height: 20),
            _buildWaterIndicator(progress, total, isDark),
            const SizedBox(height: 30),
            _buildActionSection(waterProvider, settingsProvider, sahur, berbuka, malam, isDark),
            const SizedBox(height: 20),
            _buildWaterTips(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
            icon: Icon(Icons.chevron_left_rounded, color: isDark ? Colors.white30 : Colors.black26),
          ),
          Text(
            DateFormat('EEEE, d MMM').format(_selectedDate).toUpperCase(),
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
          ),
          IconButton(
            onPressed: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
            icon: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white30 : Colors.black26),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterIndicator(double progress, int current, bool isDark) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1), width: 8),
            ),
          ),
          AnimatedBuilder(
            animation: _fillAnimation,
            builder: (context, child) {
              return SizedBox(
                width: 184,
                height: 184,
                child: ClipOval(
                  child: Stack(
                    children: [
                      Container(color: (isDark ? const Color(0xFF042A36) : Colors.blue.withOpacity(0.05))),
                      Positioned.fill(
                        top: 184 * (1 - _fillAnimation.value),
                        child: AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: WavePainter(
                                waveAnimation: _waveController.value,
                                fillLevel: _fillAnimation.value,
                                color: Theme.of(context).primaryColor.withOpacity(0.6),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.manrope(fontSize: 42, fontWeight: FontWeight.w200, color: isDark ? Colors.white : Colors.black87),
              ),
              Text(
                '$current / ${WaterProvider.totalTarget} GLASSES',
                style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(WaterProvider provider, SettingsProvider settings, int sahur, int berbuka, int malam, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildActionRow('SAHUR', sahur, WaterProvider.sahurTarget, (val) => _updateWater(provider, settings, 'sahur', val), isDark),
          const SizedBox(height: 12),
          _buildActionRow('BERBUKA', berbuka, WaterProvider.berbukaTarget, (val) => _updateWater(provider, settings, 'berbuka', val), isDark),
          const SizedBox(height: 12),
          _buildActionRow('MALAM', malam, WaterProvider.malamTarget, (val) => _updateWater(provider, settings, 'malam', val), isDark),
        ],
      ),
    );
  }

  void _updateWater(WaterProvider provider, SettingsProvider settings, String category, int amount) {
    provider.addWater(_selectedDate, category, amount);
    if (settings.waterNotificationsEnabled) {
      provider.scheduleSmartWaterReminders(true);
    }
  }

  Widget _buildActionRow(String title, int current, int target, Function(int) onAdd, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      isAsymmetric: false,
      borderRadius: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 11, color: Theme.of(context).primaryColor)),
              Text('$current dari $target gelas', style: GoogleFonts.inter(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => onAdd(-1),
                icon: Icon(Icons.remove_circle_outline_rounded, color: isDark ? Colors.white24 : Colors.black26),
              ),
              IconButton(
                onPressed: () => onAdd(1),
                icon: Icon(Icons.add_circle_rounded, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTips(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GlassCard(
        isAsymmetric: true,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text('Tips Hidrasi Berkah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem('2 gelas saat Sahur menjaga energi.', isDark),
            _buildTipItem('2 gelas saat Berbuka & 2 saat Makan.', isDark),
            _buildTipItem('2 gelas sebelum tidur agar rileks.', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 4, height: 4, decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87))),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double waveAnimation;
  final double fillLevel;
  final Color color;

  WavePainter({required this.waveAnimation, required this.fillLevel, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    
    final waveHeight = 8.0;
    final waveLength = size.width;
    
    path.moveTo(0, waveHeight);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(i, waveHeight * math.sin((i / waveLength * 2 * math.pi) + (waveAnimation * 2 * math.pi)));
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) => true;
}