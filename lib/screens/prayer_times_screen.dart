import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../providers/settings_provider.dart';
import '../widgets/glass_card.dart';
import '../services/notification_service.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  
  // Staggered Animations
  late Animation<double> _topBarAnim;
  late Animation<double> _heroAnim;
  late Animation<double> _titleAnim;
  late Animation<double> _cardsAnim;

  PrayerTimes? _prayerTimes;
  bool _isLoading = true;
  String _errorMessage = '';
  Timer? _countdownTimer;
  Duration _timeUntilNextPrayer = Duration.zero;
  String _nextPrayerName = '';
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _topBarAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic)),
    );
    _heroAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.15, 0.55, curve: Curves.easeOutCubic)),
    );
    _titleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic)),
    );
    _cardsAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic)),
    );

    _controller.forward();
    _loadPrayerTimes();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) _updateCountdown();
    });
  }

  void _updateCountdown() {
    if (_prayerTimes == null) return;
    final now = DateTime.now();
    final nextPrayer = _getNextPrayerData();

    if (nextPrayer != null) {
      final nextTime = nextPrayer['time'] as DateTime;
      final prevTime = nextPrayer['prevTime'] as DateTime;
      _timeUntilNextPrayer = nextTime.difference(now);
      _nextPrayerName = nextPrayer['name'] as String;
      final totalDuration = nextTime.difference(prevTime).inSeconds;
      final elapsed = nextTime.difference(now).inSeconds;
      if (totalDuration > 0) {
        _progressValue = (elapsed / totalDuration).clamp(0.0, 1.0);
      }
      if (_timeUntilNextPrayer.isNegative) {
        _loadPrayerTimes();
      } else {
        setState(() {});
      }
    }
  }

  Future<void> _loadPrayerTimes() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      final coordinates = await settingsProvider.getCoordinates();

      // Precision: Switch to MUIS Singapore method (Fajr 20°, Isha 18°) and Shafi'i Madhab
      final params = CalculationMethod.singapore.getParameters();
      params.madhab = Madhab.shafi;
      
      final prayerTimes = PrayerTimes(coordinates, DateComponents.from(DateTime.now()), params);

      if (mounted) {
        setState(() {
          _prayerTimes = prayerTimes;
          _isLoading = false;
          _errorMessage = '';
        });
      }
      if (settingsProvider.prayerNotificationsEnabled) {
        _scheduleAllPrayerReminders(prayerTimes, settingsProvider);
      }
      _updateCountdown();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat jadwal sholat: ${e.toString()}';
        });
      }
    }
  }

  void _scheduleAllPrayerReminders(PrayerTimes times, SettingsProvider provider) async {
    // Hapus seluruh pengingat sholat lama terlebih dahulu agar jam notifikasi baru akurat sesuai lokasi pilihan user
    await NotificationService().cancelAllPrayerReminders();

    final prayers = {
      'Subuh': times.fajr,
      'Dzuhur': times.dhuhr,
      'Ashar': times.asr,
      'Maghrib': times.maghrib,
      'Isya': times.isha,
    };
    
    final activeSound = provider.notificationSound == 'default' 
        ? null 
        : (provider.notificationSound == 'custom' ? provider.customSoundPath : provider.notificationSound);

    for (var entry in prayers.entries) {
      await NotificationService().schedulePrayerReminders(
        prayerName: entry.key,
        prayerTime: entry.value,
        remind15: provider.prayerReminder15,
        remind5: provider.prayerReminder5,
        remindNow: provider.prayerNow,
        customSound: activeSound,
      );
    }
  }

  Widget _buildStaggeredItem({
    required Animation<double> animation,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1.0 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildNotificationToggle(SettingsProvider settings, bool isDark, Color primaryColor) {
    return _buildStaggeredItem(
      animation: _titleAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          isAsymmetric: false,
          borderRadius: 20,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  settings.prayerNotificationsEnabled 
                      ? Icons.notifications_active_rounded 
                      : Icons.notifications_off_rounded,
                  color: primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PENGINGAT SHOLAT',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        fontSize: 12,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      settings.prayerNotificationsEnabled
                          ? 'Notifikasi adzan aktif untuk wilayah terpilih'
                          : 'Aktifkan pengingat adzan otomatis',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: settings.prayerNotificationsEnabled,
                activeColor: primaryColor,
                onChanged: (bool value) async {
                  if (value) {
                    await NotificationService().requestPermissions();
                    settings.setPrayerNotificationsEnabled(true);
                    if (_prayerTimes != null) {
                      _scheduleAllPrayerReminders(_prayerTimes!, settings);
                    }
                  } else {
                    settings.setPrayerNotificationsEnabled(false);
                    await NotificationService().cancelAllPrayerReminders();
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value 
                            ? 'Notifikasi jadwal sholat berhasil diaktifkan!' 
                            : 'Notifikasi jadwal sholat dinonaktifkan.',
                          style: GoogleFonts.inter(),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: value 
                          ? primaryColor.withOpacity(0.9)
                          : Colors.grey[800],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        children: [
          // 1. Staggered Top Bar (Region Selection / GPS Toggle)
          _buildStaggeredItem(
            animation: _topBarAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  // GPS Status Icon
                  _LocationStatusIndicator(
                    useCurrentLocation: settingsProvider.useCurrentLocation,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(width: 10),
                  // Location name button
                  Expanded(
                    child: InkWell(
                      onTap: settingsProvider.useCurrentLocation ? null : _showCitySelectionDialog,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              settingsProvider.useCurrentLocation 
                                ? 'GPS REALTIME' 
                                : settingsProvider.selectedCity.toUpperCase(),
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                fontSize: 13,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            if (!settingsProvider.useCurrentLocation) ...[
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_drop_down, size: 20, color: isDark ? Colors.white30 : Colors.black38),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  // GPS Toggle Chip
                  ActionChip(
                    avatar: Icon(
                      Icons.gps_fixed_rounded,
                      size: 14,
                      color: settingsProvider.useCurrentLocation ? Colors.black87 : primaryColor,
                    ),
                    label: Text(
                      'GPS REALTIME',
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: settingsProvider.useCurrentLocation ? Colors.black87 : Colors.white70,
                      ),
                    ),
                    backgroundColor: settingsProvider.useCurrentLocation 
                        ? primaryColor 
                        : Colors.white.withOpacity(0.04),
                    side: BorderSide(
                      color: settingsProvider.useCurrentLocation 
                          ? Colors.transparent 
                          : primaryColor.withOpacity(0.2),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onPressed: () {
                      settingsProvider.setUseCurrentLocation(!settingsProvider.useCurrentLocation);
                      _loadPrayerTimes();
                    },
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            const SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_errorMessage.isNotEmpty)
            _buildErrorUI()
          else ...[
            // 2. Next Prayer Hero Card
            if (_nextPrayerName.isNotEmpty)
              _buildStaggeredItem(
                animation: _heroAnim,
                child: _buildNextPrayerHero(isDark, primaryColor),
              ),
            
            const SizedBox(height: 20),
            _buildNotificationToggle(settingsProvider, isDark, primaryColor),
            const SizedBox(height: 24),
            
            // 3. Staggered daily schedule heading
            _buildStaggeredItem(
              animation: _titleAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'DAILY SCHEDULE',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 10,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 4. Staggered Prayer Time Cards list
            _buildStaggeredItem(
              animation: _cardsAnim,
              child: Column(
                children: _buildPrayerTimeCards(isDark, primaryColor),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNextPrayerHero(bool isDark, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(28),
        margin: EdgeInsets.zero,
        borderRadius: 30,
        child: Column(
          children: [
            Text(
              'NEXT PRAYER: ${_nextPrayerName.toUpperCase()}',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                fontSize: 11,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _formatCountdown(_timeUntilNextPrayer),
              style: GoogleFonts.manrope(
                fontSize: 52,
                fontWeight: FontWeight.w200,
                letterSpacing: -2,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Stack(
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: _progressValue,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor.withOpacity(0.5), primaryColor],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPrayerTimeCards(bool isDark, Color primaryColor) {
    if (_prayerTimes == null) return [];
    final prayers = [
      {'name': 'Subuh', 'time': _prayerTimes!.fajr, 'icon': Icons.wb_twilight_rounded},
      {'name': 'Terbit', 'time': _prayerTimes!.sunrise, 'icon': Icons.wb_sunny_outlined},
      {'name': 'Dzuhur', 'time': _prayerTimes!.dhuhr, 'icon': Icons.wb_sunny_rounded},
      {'name': 'Ashar', 'time': _prayerTimes!.asr, 'icon': Icons.cloud_queue_rounded},
      {'name': 'Maghrib', 'time': _prayerTimes!.maghrib, 'icon': Icons.nightlight_round_rounded},
      {'name': 'Isya', 'time': _prayerTimes!.isha, 'icon': Icons.nights_stay_rounded},
    ];

    return prayers.map((p) {
      final isNext = _nextPrayerName == p['name'];
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: GlassCard(
          isAsymmetric: false,
          borderRadius: 18,
          opacity: isNext ? 0.16 : 0.03,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          margin: EdgeInsets.zero,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isNext ? primaryColor.withOpacity(0.1) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  p['icon'] as IconData, 
                  size: 18, 
                  color: isNext ? primaryColor : (isDark ? Colors.white30 : Colors.black26),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                (p['name'] as String).toUpperCase(),
                style: GoogleFonts.manrope(
                  fontWeight: isNext ? FontWeight.w900 : FontWeight.w500,
                  letterSpacing: 1.5,
                  fontSize: 13,
                  color: isNext ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.white60 : Colors.black54),
                ),
              ),
              const Spacer(),
              Text(
                _formatTime(p['time'] as DateTime),
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: isNext ? FontWeight.bold : FontWeight.w400,
                  color: isNext ? primaryColor : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _showCitySelectionDialog() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF042A36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Pilih Wilayah',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SettingsProvider.presetLocations.keys.map((city) => ListTile(
            title: Text(city, style: GoogleFonts.inter(color: Colors.white70)),
            trailing: settingsProvider.selectedCity == city 
                ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 18) 
                : null,
            onTap: () {
              settingsProvider.setSelectedCity(city);
              _loadPrayerTimes();
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  
  String _formatCountdown(Duration d) {
    if (d.isNegative) return "00:00:00";
    return '${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Widget _buildErrorUI() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage,
                style: GoogleFonts.manrope(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.black87,
                ),
                onPressed: _loadPrayerTimes,
                icon: const Icon(Icons.refresh),
                label: const Text('COBA LAGI'),
              ),
            ],
          ),
        ),
      );

  Map<String, dynamic>? _getNextPrayerData() {
    if (_prayerTimes == null) return null;
    final now = DateTime.now();
    final prayers = [
      {'name': 'Subuh', 'time': _prayerTimes!.fajr},
      {'name': 'Dzuhur', 'time': _prayerTimes!.dhuhr},
      {'name': 'Ashar', 'time': _prayerTimes!.asr},
      {'name': 'Maghrib', 'time': _prayerTimes!.maghrib},
      {'name': 'Isya', 'time': _prayerTimes!.isha},
    ];
    for (int i = 0; i < prayers.length; i++) {
      if ((prayers[i]['time'] as DateTime).isAfter(now)) {
        return {'name': prayers[i]['name'], 'time': prayers[i]['time'], 'prevTime': i == 0 ? _prayerTimes!.isha.subtract(const Duration(days: 1)) : prayers[i-1]['time']};
      }
    }
    return {'name': 'Subuh', 'time': _prayerTimes!.fajr.add(const Duration(days: 1)), 'prevTime': _prayerTimes!.isha};
  }
}

class _LocationStatusIndicator extends StatefulWidget {
  final bool useCurrentLocation;
  final Color primaryColor;

  const _LocationStatusIndicator({
    required this.useCurrentLocation,
    required this.primaryColor,
  });

  @override
  State<_LocationStatusIndicator> createState() => _LocationStatusIndicatorState();
}

class _LocationStatusIndicatorState extends State<_LocationStatusIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.useCurrentLocation) {
      return Icon(Icons.location_on_rounded, color: widget.primaryColor, size: 18);
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.primaryColor.withOpacity(0.15),
              ),
            ),
            Container(
              width: 10 + (8 * _pulseController.value),
              height: 10 + (8 * _pulseController.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.primaryColor.withOpacity(1.0 - _pulseController.value),
                  width: 1.5,
                ),
              ),
            ),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }
}