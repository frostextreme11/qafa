import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
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
  late Animation<double> _animation;

  PrayerTimes? _prayerTimes;
  bool _isLoading = true;
  String _errorMessage = '';
  Timer? _countdownTimer;
  Duration _timeUntilNextPrayer = Duration.zero;
  String _nextPrayerName = '';
  double _progressValue = 0.0;

  final Map<String, Map<String, double>> _presetLocations = {
    'Cimahi': {'lat': -6.8722, 'lng': 107.5425},
    'Bandung': {'lat': -6.9175, 'lng': 107.6191},
    'Madinah': {'lat': 24.5247, 'lng': 39.5692},
    'Mekkah': {'lat': 21.3891, 'lng': 39.8579},
    'Jeddah': {'lat': 21.4858, 'lng': 39.1925},
  };

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
    setState(() => _isLoading = true);
    try {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      final city = settingsProvider.selectedCity;
      double latitude, longitude;

      if (_presetLocations.containsKey(city)) {
        latitude = _presetLocations[city]!['lat']!;
        longitude = _presetLocations[city]!['lng']!;
      } else {
        final position = await _getCurrentLocation();
        latitude = position.latitude;
        longitude = position.longitude;
      }

      final coordinates = Coordinates(latitude, longitude);
      final params = CalculationMethod.karachi.getParameters();
      params.madhab = Madhab.hanafi;
      final prayerTimes = PrayerTimes(coordinates, DateComponents.from(DateTime.now()), params);

        setState(() {
          _prayerTimes = prayerTimes;
          _isLoading = false;
          _errorMessage = '';
        });
        if (settingsProvider.prayerNotificationsEnabled) {
          _scheduleAllPrayerReminders(prayerTimes, settingsProvider);
        }
        _updateCountdown();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat jadwal sholat: ${e.toString()}';
      });
    }
  }

  void _scheduleAllPrayerReminders(PrayerTimes times, SettingsProvider provider) async {
    final prayers = {
      'Subuh': times.fajr,
      'Dzuhur': times.dhuhr,
      'Ashar': times.asr,
      'Maghrib': times.maghrib,
      'Isya': times.isha,
    };
    
    for (var entry in prayers.entries) {
      await NotificationService().schedulePrayerReminders(
        prayerName: entry.key,
        prayerTime: entry.value,
        remind15: provider.prayerReminder15,
        remind5: provider.prayerReminder5,
        remindNow: provider.prayerNow,
        customSound: provider.notificationSound == 'default' ? null : provider.notificationSound,
      );
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Layanan lokasi tidak aktif.');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw Exception('Izin lokasi ditolak');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: InkWell(
              onTap: _showCitySelectionDialog,
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    settingsProvider.selectedCity.toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, size: 20, color: isDark ? Colors.white24 : Colors.black26),
                ],
              ),
            ),
          ),

          if (_isLoading)
            const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage.isNotEmpty)
            _buildErrorUI()
          else ...[
            if (_nextPrayerName.isNotEmpty) _buildNextPrayerHero(isDark),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'DAILY SCHEDULE',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    fontSize: 10,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ..._buildPrayerTimeCards(isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildNextPrayerHero(bool isDark) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            Text(
              'NEXT: ${_nextPrayerName.toUpperCase()}',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
                fontSize: 12,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _formatCountdown(_timeUntilNextPrayer),
              style: GoogleFonts.manrope(
                fontSize: 54,
                fontWeight: FontWeight.w200,
                letterSpacing: -2,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            Stack(
              children: [
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: _progressValue,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor.withOpacity(0.4), primaryColor],
                      ),
                      borderRadius: BorderRadius.circular(2),
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

  List<Widget> _buildPrayerTimeCards(bool isDark) {
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
          borderRadius: 16,
          opacity: isNext ? 0.2 : 0.05,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          margin: EdgeInsets.zero,
          child: Row(
            children: [
              Icon(p['icon'] as IconData, size: 20, color: isNext ? Theme.of(context).primaryColor : (isDark ? Colors.white24 : Colors.black26)),
              const SizedBox(width: 20),
              Text(
                (p['name'] as String).toUpperCase(),
                style: GoogleFonts.manrope(
                  fontWeight: isNext ? FontWeight.w800 : FontWeight.w400,
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
                  fontWeight: isNext ? FontWeight.bold : FontWeight.w300,
                  color: isNext ? Theme.of(context).primaryColor : (isDark ? Colors.white : Colors.black87),
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
        title: Text('Select Region', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _presetLocations.keys.map((city) => ListTile(
            title: Text(city),
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

  Widget _buildErrorUI() => Column(children: [Text(_errorMessage), ElevatedButton(onPressed: _loadPrayerTimes, child: const Text('RETRY'))]);

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