import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adhan/adhan.dart';
import '../providers/fasting_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/quote_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/blinking_markers.dart';
import '../widgets/semi_circle_progress.dart';
import '../widgets/glowing_reminder_button.dart';
import '../widgets/shimmer_linear_progress.dart';
import '../widgets/celebration_overlay.dart';
import '../data/local_quotes.dart';
import '../services/hijri_helper.dart';
import '../services/sunnah_fasting_helper.dart';
import 'worship_plan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  
  // Staggered interval animations
  late Animation<double> _headerAnim;
  late Animation<double> _fastingToggleAnim;
  late Animation<double> _sacredMonthAnim;
  late Animation<double> _quotesAnim;
  late Animation<double> _qadaProgressAnim;
  late Animation<double> _statsGridAnim;
  late Animation<double> _calendarAnim;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<String> _quotes = [];
  bool _isLoadingQuotes = true;
  final Set<String> _expandedFastKeys = {};
  bool _isSunnahCardExpanded = false;

  final String _geminiApiKey = 'AIzaSyAVUD3eYrPOx3Qlvsf0tp5bDwQVbrvRDl4';

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    // Stagger setup with cubic ease curve
    _headerAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic)),
    );
    _fastingToggleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.12, 0.45, curve: Curves.easeOutCubic)),
    );
    _sacredMonthAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.22, 0.55, curve: Curves.easeOutCubic)),
    );
    _quotesAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.32, 0.65, curve: Curves.easeOutCubic)),
    );
    _qadaProgressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.42, 0.75, curve: Curves.easeOutCubic)),
    );
    _statsGridAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.52, 0.85, curve: Curves.easeOutCubic)),
    );
    _calendarAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.62, 1.0, curve: Curves.easeOutCubic)),
    );

    _controller.forward();
    _generateInitialQuotes();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generateInitialQuotes() async {
    if (mounted) setState(() => _isLoadingQuotes = true);
    
    final today = DateTime.now();
    final hijri = HijriDate.fromGregorian(today);
    
    List<String> combinedList = [];
    if (hijri.isSacredMonth) {
      combinedList.addAll(hijri.sacredMonthQuotes);
    }
    
    final localList = List<String>.from(LocalQuotes.quotes);
    localList.shuffle();
    combinedList.addAll(localList);
    
    if (mounted) {
      setState(() {
        _quotes = combinedList.take(10).toList();
        _isLoadingQuotes = false;
      });
    }
  }

  Future<void> _generateMoreQuotes() async {
    setState(() => _isLoadingQuotes = true);
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: _geminiApiKey);
      const prompt = 'Generate 10 concise Islamic quotes in Indonesian. Format: "Quote" - Source';
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
      if (mounted) {
        setState(() {
          _quotes.addAll(lines);
          _isLoadingQuotes = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingQuotes = false);
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
            offset: Offset(0, 24 * (1.0 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fastingProvider = Provider.of<FastingProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;

    final today = DateTime.now();
    final hijriDate = HijriDate.fromGregorian(today);
    final gregorianStr = DateFormat('EEEE, d MMMM yyyy').format(today);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Staggered Top Hijri Date Header
          _buildStaggeredItem(
            animation: _headerAnim,
            child: _buildHeader(hijriDate, gregorianStr, primaryColor, isDark),
          ),

          const SizedBox(height: 6),

          // 2. Staggered Fasting Today Toggle
          _buildStaggeredItem(
            animation: _fastingToggleAnim,
            child: _buildFastingToggleCard(fastingProvider, settingsProvider, primaryColor),
          ),

          // 3. Staggered Sacred Month Glowing Banner
          if (hijriDate.isSacredMonth)
            _buildStaggeredItem(
              animation: _sacredMonthAnim,
              child: _buildSacredMonthBanner(hijriDate, primaryColor, isDark),
            ),

          const SizedBox(height: 10),

          // 4. Staggered Quotes Card Slider
          _buildStaggeredItem(
            animation: _quotesAnim,
            child: Stack(
              children: [
                SizedBox(
                  height: 200,
                  child: _isLoadingQuotes
                      ? const Center(child: CircularProgressIndicator())
                      : PageView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _quotes.length,
                          controller: PageController(viewportFraction: 0.92),
                          itemBuilder: (context, index) => QuoteCard(quote: _quotes[index]),
                        ),
                ),
                Positioned(
                  bottom: 12,
                  right: 32,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.white60,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _isLoadingQuotes ? null : _generateMoreQuotes,
                      icon: Icon(Icons.refresh_rounded, color: primaryColor, size: 18),
                      tooltip: 'Refresh Quotes',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 4.5. Sunnah Fasting Recommendations (NEW)
          _buildStaggeredItem(
            animation: _quotesAnim,
            child: _buildSunnahFastingCard(
              fastingProvider,
              hijriDate,
              primaryColor,
              isDark,
              textColor,
              subColor,
            ),
          ),

          const SizedBox(height: 12),

          // 5. Staggered Centralized Qada Progress
          _buildStaggeredItem(
            animation: _qadaProgressAnim,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.92,
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  isAsymmetric: false,
                  borderRadius: 28,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'QADA FASTING GOAL',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: primaryColor,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _updateQadaTarget(context, fastingProvider),
                            icon: Icon(Icons.edit_note_rounded, size: 20, color: primaryColor.withOpacity(0.5)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 160,
                            width: 240,
                            child: AnimatedSemiCircleProgress(
                              progress: fastingProvider.qadaProgress,
                              color: primaryColor,
                              strokeWidth: 16,
                              glow: true,
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(fastingProvider.qadaProgress * 100).toInt()}%',
                                  style: GoogleFonts.manrope(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w200,
                                    letterSpacing: -2,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  'COMPLETED',
                                  style: GoogleFonts.manrope(
                                    fontSize: 9, 
                                    fontWeight: FontWeight.w900, 
                                    letterSpacing: 1.5,
                                    color: subColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${fastingProvider.qadaCompleted} of ${fastingProvider.qadaTarget ?? 0} days LUNAS',
                        style: GoogleFonts.manrope(
                          fontSize: 11, 
                          fontWeight: FontWeight.w700,
                          color: subColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 6. Staggered Statistics Grid
          _buildStaggeredItem(
            animation: _statsGridAnim,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildStatsGrid(fastingProvider, isDark),
            ),
          ),
          
          const SizedBox(height: 12),  

          // 7. Staggered Calendar Section
          _buildStaggeredItem(
            animation: _calendarAnim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCalendarCard(fastingProvider, textColor),
                const SizedBox(height: 16),
                // Targets Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ACTIVE TARGETS',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: subColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showAddTargetDialog(context),
                        icon: Icon(Icons.add_circle_rounded, size: 22, color: primaryColor),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                _buildTargetList(fastingProvider, isDark, textColor, subColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(HijriDate hijri, String gregorianStr, Color primaryColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hijri.toString().toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isDark ? primaryColor : Colors.green[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gregorianStr,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white38 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.mosque_outlined,
              color: primaryColor,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFastingToggleCard(
    FastingProvider fastingProvider,
    SettingsProvider settingsProvider,
    Color primaryColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GlassCard(
        isAsymmetric: false,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        margin: EdgeInsets.zero,
        borderRadius: 24,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: fastingProvider.isFastingToday 
                  ? primaryColor.withOpacity(0.15) 
                  : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                fastingProvider.isFastingToday 
                  ? Icons.brightness_2_rounded 
                  : Icons.brightness_5_rounded, 
                color: fastingProvider.isFastingToday 
                  ? primaryColor 
                  : (isDark ? Colors.white24 : Colors.black26),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SEDANG PUASA',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fastingProvider.isFastingToday
                      ? 'Alarm Sahur & Buka Puasa Aktif'
                      : 'Nyalakan jika hari ini Anda sedang berpuasa',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: fastingProvider.isFastingToday,
              activeColor: primaryColor,
              activeTrackColor: primaryColor.withOpacity(0.3),
              inactiveThumbColor: isDark ? Colors.white30 : Colors.black26,
              inactiveTrackColor: isDark ? Colors.white10 : Colors.black12,
              onChanged: (value) async {
                if (value) {
                  try {
                    final coords = await settingsProvider.getCoordinates();
                    final params = CalculationMethod.singapore.getParameters();
                    params.madhab = Madhab.shafi;
                    final times = PrayerTimes(coords, DateComponents.from(DateTime.now()), params);
                    
                    fastingProvider.setFastingToday(
                      true,
                      fajrTime: times.fajr,
                      maghribTime: times.maghrib,
                    );
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF042A36),
                          content: Text(
                            'Alarm sahur (imsak) & berbuka (Maghrib) berhasil dijadwalkan!',
                            style: GoogleFonts.manrope(color: primaryColor, fontWeight: FontWeight.w600),
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red[900],
                          content: Text(
                            'Gagal mendeteksi lokasi untuk waktu sholat. Pastikan GPS aktif.',
                            style: GoogleFonts.manrope(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  }
                } else {
                  fastingProvider.setFastingToday(false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF042A36),
                        content: Text(
                          'Alarm puasa hari ini dinonaktifkan.',
                          style: GoogleFonts.manrope(color: Colors.white70),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSacredMonthBanner(HijriDate hijri, Color primaryColor, bool isDark) {
    final accentColor = isDark ? const Color(0xFFFFDB3C) : const Color(0xFFB57C00);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GlassCard(
        isAsymmetric: false,
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.zero,
        borderRadius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.stars_rounded,
                    color: accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BULAN HARAM (SUCI)',
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: accentColor,
                        ),
                      ),
                      Text(
                        'Bulan ${hijri.sacredMonthTitle}',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              hijri.sacredMonthDescription,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: accentColor,
                    size: 13,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Amalan kebaikan dilipatgandakan pahalanya. Jauhi kemaksiatan & perselisihan.',
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: isDark ? const Color(0xFF02161D) : Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorshipPlanScreen(
                        hijriMonth: hijri.month,
                        monthName: hijri.monthName,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.playlist_add_check_rounded, size: 20),
                label: Text(
                  'List Amalan Terbaik',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkQadaMilestones(double oldProgress, double newProgress, bool isDark) {
    if (newProgress <= oldProgress) return;
    final int oldPct = (oldProgress * 100).round();
    final int newPct = (newProgress * 100).round();
    
    if (newPct >= 100 && oldPct < 100) {
      CelebrationOverlay.show(context, type: CelebrationType.qada100, percentage: 100, isDark: isDark);
      return;
    }
    
    for (int step in [80, 60, 40, 20]) {
      if (newPct >= step && oldPct < step) {
        CelebrationOverlay.show(context, type: CelebrationType.qada20, percentage: step, isDark: isDark);
        return;
      }
    }
    
    for (int step in [95, 90, 85, 75, 70, 65, 55, 50, 45, 35, 30, 25, 15, 10, 5]) {
      if (newPct >= step && oldPct < step) {
        CelebrationOverlay.show(context, type: CelebrationType.qada5, percentage: step, isDark: isDark);
        return;
      }
    }
  }

  void _updateQadaTarget(BuildContext context, FastingProvider provider) {
    final controller = TextEditingController(text: provider.qadaTarget?.toString() ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('SET QADA GOAL', style: GoogleFonts.manrope(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            labelText: 'Total days to qada',
            labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).dividerColor)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('CANCEL', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4)))),
          ElevatedButton(
            onPressed: () {
              final target = int.tryParse(controller.text);
              if (target != null) {
                final double oldProgress = provider.qadaProgress;
                provider.setQadaTarget(target);
                final double newProgress = provider.qadaProgress;
                
                final isDark = Theme.of(context).brightness == Brightness.dark;
                _checkQadaMilestones(oldProgress, newProgress, isDark);
              }
              Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(FastingProvider provider, bool isDark) {
    final types = FastingType.values;
    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.15,
      children: [
        ...types.map((type) {
          final count = provider.getCompletedDaysForType(type);
          return _buildStatItem(type.name, count.toString(), type.color, isDark);
        }),
        _buildStatItem('TOTAL', provider.fastingDays.length.toString(), Theme.of(context).primaryColor, isDark),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(8),
      margin: EdgeInsets.zero,
      isAsymmetric: false,
      borderRadius: 16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.manrope(fontSize: 26, fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.manrope(fontSize: 8, fontWeight: FontWeight.w800, color: isDark ? Colors.white38 : Colors.black38),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGlowingDayCell(
    DateTime day,
    Map<String, dynamic> recommendation,
    bool isToday,
    bool isOutside,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Get distinct color based on recommendation, fall back to teal
    final glowColor = (recommendation['color'] as Color?) ?? const Color(0xFF64FFDA);
    final textStyle = GoogleFonts.inter(
      fontSize: 13.5,
      fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
      color: isOutside
          ? (isDark ? Colors.white24 : Colors.black26)
          : (isToday
              ? Theme.of(context).primaryColor
              : (isDark ? Colors.white : Colors.black87)),
    );

    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isToday
            ? Theme.of(context).primaryColor.withOpacity(0.15)
            : glowColor.withOpacity(isOutside ? 0.04 : 0.08),
        shape: BoxShape.circle,
        border: Border.all(
          color: isToday
              ? Theme.of(context).primaryColor.withOpacity(0.5)
              : glowColor.withOpacity(isOutside ? 0.25 : 0.55),
          width: isToday ? 2.0 : 1.2,
        ),
        boxShadow: isOutside
            ? null
            : [
                BoxShadow(
                  color: (isToday ? Theme.of(context).primaryColor : glowColor)
                      .withOpacity(0.2),
                  blurRadius: 5,
                  spreadRadius: 1.5,
                ),
              ],
      ),
      child: Text(
        day.day.toString(),
        style: textStyle,
      ),
    );
  }

  Widget _buildCalendarCard(FastingProvider provider, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        isAsymmetric: false,
        padding: const EdgeInsets.all(12),
        margin: EdgeInsets.zero,
        borderRadius: 28,
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16, color: textColor),
            leftChevronIcon: Icon(Icons.chevron_left_rounded, color: textColor),
            rightChevronIcon: Icon(Icons.chevron_right_rounded, color: textColor),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: textColor.withOpacity(0.5), fontSize: 12),
            weekendStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
          calendarStyle: CalendarStyle(
            defaultTextStyle: TextStyle(color: textColor),
            weekendTextStyle: const TextStyle(color: Colors.redAccent),
            outsideTextStyle: TextStyle(color: textColor.withOpacity(0.2)),
            todayDecoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.2), shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
            markerDecoration: const BoxDecoration(color: Colors.transparent),
          ),
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _onCalendarDayTap(selectedDay);
          },
          eventLoader: (day) => provider.fastingDaysMap[DateTime(day.year, day.month, day.day)] ?? [],
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final rec = SunnahFastingHelper.getRecommendationForDate(day);
              if (rec != null) {
                return _buildGlowingDayCell(day, rec, false, false);
              }
              return null;
            },
            todayBuilder: (context, day, focusedDay) {
              final rec = SunnahFastingHelper.getRecommendationForDate(day);
              if (rec != null) {
                return _buildGlowingDayCell(day, rec, true, false);
              }
              return null;
            },
            outsideBuilder: (context, day, focusedDay) {
              final rec = SunnahFastingHelper.getRecommendationForDate(day);
              if (rec != null) {
                return _buildGlowingDayCell(day, rec, false, true);
              }
              return null;
            },
            markerBuilder: (context, day, events) {
              if (events.isNotEmpty) return Positioned(bottom: 2, child: BlinkingMarkers(fastingDays: events.cast<FastingDay>()));
              return null;
            },
          ),
        ),
      ),
    );
  }

  void _onCalendarDayTap(DateTime date) {
    final fastingProvider = Provider.of<FastingProvider>(context, listen: false);
    final fastingDays = fastingProvider.fastingDaysMap[DateTime(date.year, date.month, date.day)];
    if (fastingDays != null && fastingDays.isNotEmpty) {
      _showFastingDetailsDialog(date, fastingDays);
    } else {
      _showAddFastingDialog(date);
    }
  }

  Widget _buildRecommendationDialogCard(
    BuildContext context,
    Map<String, dynamic> rec,
    FastingProvider provider,
    DateTime date,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = (rec['color'] as Color?) ?? const Color(0xFF64FFDA);
    final isFuture = DateTime(date.year, date.month, date.day).isAfter(
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
    final isReminderEnabled = provider.isSunnahReminderEnabled(rec['key']);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GlassCard(
        isAsymmetric: false,
        padding: const EdgeInsets.all(16),
        margin: EdgeInsets.zero,
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.stars_rounded,
                    color: accentColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REKOMENDASI PUASA SUNNAH',
                        style: GoogleFonts.manrope(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: accentColor,
                        ),
                      ),
                      Text(
                        rec['name'] ?? '',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              rec['description'] ?? '',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                rec['rationale'] ?? '',
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white54 : Colors.black54,
                  height: 1.4,
                ),
              ),
            ),
            if (isFuture) ...[
              const Divider(height: 20, thickness: 0.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PENGINGAT PUASA',
                          style: GoogleFonts.manrope(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: isReminderEnabled
                                ? accentColor
                                : (isDark ? Colors.white38 : Colors.black38),
                          ),
                        ),
                        Text(
                          isReminderEnabled
                              ? 'Aktif (H-1 Pagi & Malam)'
                              : 'Ingatkan saya untuk puasa ini',
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: isReminderEnabled,
                    activeColor: accentColor,
                    onChanged: (val) async {
                      await provider.toggleSunnahReminder(
                        rec['key'],
                        [date],
                        rec['name'],
                      );

                      if (context.mounted) {
                        final nowEnabled =
                            provider.isSunnahReminderEnabled(rec['key']);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF042A36),
                            content: Row(
                              children: [
                                Icon(
                                  nowEnabled
                                      ? Icons.notifications_active_rounded
                                      : Icons.notifications_off_rounded,
                                  color: accentColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    nowEnabled
                                        ? 'Pengingat Aktif! Notifikasi H-1 akan dikirimkan.'
                                        : 'Pengingat telah dinonaktifkan.',
                                    style: GoogleFonts.manrope(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            duration: const Duration(seconds: 3),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFastingDetailsDialog(DateTime date, List<FastingDay> days) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Details',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, a1, a2) => Container(),
      transitionBuilder: (context, a1, a2, child) {
        final recommendation =
            SunnahFastingHelper.getRecommendationForDate(date);
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: Consumer<FastingProvider>(
              builder: (context, provider, child) {
                return AlertDialog(
                  backgroundColor: Theme.of(context).dialogBackgroundColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  title: Text(
                    DateFormat('dd MMMM yyyy').format(date),
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (recommendation != null)
                          _buildRecommendationDialogCard(
                              context, recommendation, provider, date),
                        Center(
                          child: Text(
                            'KEHADIRAN PUASA',
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...days.map((d) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.check_circle_rounded,
                                  color: d.type.color),
                              title: Text(d.type.name,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: Colors.redAccent),
                                onPressed: () {
                                  provider.removeFastingDay(date, d.type);
                                  Navigator.pop(context);
                                },
                              ),
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showAddFastingDialog(DateTime date) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, a1, a2) => Container(),
      transitionBuilder: (context, a1, a2, child) {
        final recommendation =
            SunnahFastingHelper.getRecommendationForDate(date);
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: Consumer<FastingProvider>(
              builder: (context, provider, child) {
                return AlertDialog(
                  backgroundColor: Theme.of(context).dialogBackgroundColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                  title: Text(
                    'LOG & REKOMENDASI PUASA',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontSize: 13,
                      color: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (recommendation != null)
                          _buildRecommendationDialogCard(
                              context, recommendation, provider, date),
                        Text(
                          'PILIH JENIS PUASA UNTUK DI-LOG',
                          style: GoogleFonts.manrope(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...FastingType.values.map((type) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              onTap: () {
                                final double oldProgress = provider.qadaProgress;
                                provider.addFastingDay(date, type);
                                final double newProgress = provider.qadaProgress;
                                Navigator.pop(context);

                                final isDark =
                                    Theme.of(context).brightness ==
                                        Brightness.dark;
                                _checkQadaMilestones(
                                    oldProgress, newProgress, isDark);
                              },
                              leading: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                      color: type.color,
                                      shape: BoxShape.circle)),
                              title: Text(type.name,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color)),
                              trailing: Icon(Icons.add_rounded,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.2)),
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showAddTargetDialog(BuildContext context) {
    FastingType selectedType = FastingType.mondayThursday;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('NEW TARGET', style: GoogleFonts.manrope(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<FastingType>(
                value: selectedType,
                isExpanded: true,
                dropdownColor: Theme.of(context).dialogBackgroundColor,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                items: FastingType.values.where((t) => t != FastingType.qada).map((type) => DropdownMenuItem(value: type, child: Text(type.name))).toList(),
                onChanged: (val) { if (val != null) setDialogState(() => selectedType = val); },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  labelText: 'Target Days',
                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                final target = int.tryParse(controller.text);
                if (target != null) Provider.of<FastingProvider>(context, listen: false).addFastingTarget(selectedType, target);
                Navigator.pop(context);
              },
              child: const Text('CREATE'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetList(FastingProvider provider, bool isDark, Color textColor, Color subColor) {
    final active = provider.fastingTargets.where((t) => !t.isCompleted).toList();
    if (active.isEmpty) return Center(child: Padding(padding: const EdgeInsets.all(32), child: Text('Focus on your daily goal.', style: TextStyle(color: isDark ? Colors.white24 : Colors.black26))));
    return Column(children: active.map((t) => _buildTargetItem(t, textColor, subColor)).toList());
  }

  void _showDeleteTargetConfirmation(BuildContext context, FastingTarget target) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'HAPUS TARGET',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 14,
            color: Colors.redAccent,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus target puasa ${target.type.name} (${target.targetDays} hari) ini?',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'BATAL',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () {
              Provider.of<FastingProvider>(context, listen: false).removeFastingTarget(target.id);
              Navigator.pop(context);
            },
            child: const Text('HAPUS', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetItem(FastingTarget target, Color textColor, Color subColor) {
    final fastingProvider = Provider.of<FastingProvider>(context, listen: false);
    final progress = target.getProgress(fastingProvider);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GlassCard(
        isAsymmetric: false,
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.zero,
        borderRadius: 20,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(target.type.name.toUpperCase(), style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1, color: target.type.color)),
                    Text('${target.targetDays - target.getCompletedDays(fastingProvider)} days left', style: GoogleFonts.inter(fontSize: 11, color: subColor)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${(progress * 100).toInt()}%', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w200, color: textColor)),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => _showDeleteTargetConfirmation(context, target),
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Hapus Target',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: ShimmerLinearProgress(
                value: progress,
                color: target.type.color,
                backgroundColor: Colors.white.withOpacity(0.05),
                height: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSunnahFastingCard(
    FastingProvider fastingProvider,
    HijriDate hijriDate,
    Color primaryColor,
    bool isDark,
    Color textColor,
    Color subColor,
  ) {
    final fasts = _getSunnahFastsForMonth(hijriDate);
    if (fasts.isEmpty) return const SizedBox.shrink();

    final cardAccentColor = isDark ? const Color(0xFF64FFDA) : const Color(0xFF00796B);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        isAsymmetric: false,
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.zero,
        borderRadius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isSunnahCardExpanded = !_isSunnahCardExpanded;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cardAccentColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: cardAccentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REKOMENDASI PUASA SUNNAH',
                          style: GoogleFonts.manrope(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: cardAccentColor,
                          ),
                        ),
                        Text(
                          'Puasa Bulan ${hijriDate.monthName}',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isSunnahCardExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: subColor,
                    size: 24,
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Raih pahala istimewa dengan menghidupkan puasa sunnah di bulan ini. Aktifkan pengingat untuk mempersiapkan sahur Anda.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: subColor,
                        height: 1.4,
                      ),
                    ),
                    const Divider(height: 24, thickness: 0.5),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: fasts.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final fast = fasts[index];
                        return _buildSunnahFastItemRow(
                          fast,
                          fastingProvider,
                          primaryColor,
                          cardAccentColor,
                          isDark,
                          textColor,
                          subColor,
                        );
                      },
                    ),
                  ],
                ),
              ),
              crossFadeState: _isSunnahCardExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSunnahFastItemRow(
    Map<String, dynamic> fast,
    FastingProvider fastingProvider,
    Color primaryColor,
    Color cardAccentColor,
    bool isDark,
    Color textColor,
    Color subColor,
  ) {
    final isExpanded = _expandedFastKeys.contains(fast['key']);
    final isReminderEnabled = fastingProvider.isSunnahReminderEnabled(fast['key']);
    
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isReminderEnabled
              ? cardAccentColor.withOpacity(0.3)
              : (isDark ? Colors.white10 : Colors.black12),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Top clickable header to expand/collapse
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedFastKeys.remove(fast['key']);
                } else {
                  _expandedFastKeys.add(fast['key']);
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isReminderEnabled ? cardAccentColor : primaryColor).withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.nights_stay_outlined,
                      color: isReminderEnabled ? cardAccentColor : primaryColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fast['name'] ?? '',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          fast['dateString'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: subColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: subColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          
          // Expandable rationale & details
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 12, thickness: 0.5),
                  Text(
                    fast['description'] ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: textColor.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.menu_book_rounded, color: cardAccentColor, size: 12),
                            const SizedBox(width: 6),
                            Text(
                              'Hadits & Keutamaan:',
                              style: GoogleFonts.manrope(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: cardAccentColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          fast['rationale'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontStyle: FontStyle.italic,
                            color: textColor.withOpacity(0.75),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          
          // Alarm activation button at the bottom of row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: GlowingReminderButton(
                isReminderEnabled: isReminderEnabled,
                onPressed: () async {
                  await fastingProvider.toggleSunnahReminder(
                    fast['key'],
                    List<DateTime>.from(fast['dates']),
                    fast['name'],
                  );
                  
                  if (context.mounted) {
                    final nowEnabled = fastingProvider.isSunnahReminderEnabled(fast['key']);
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF042A36),
                        content: Row(
                          children: [
                            Icon(
                              nowEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                              color: cardAccentColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                nowEnabled
                                    ? 'Pengingat Aktif! H-1 pagi (06:00) & malam setelah Isya (20:30) akan dikirimkan.'
                                    : 'Pengingat untuk ${fast['name']} telah dinonaktifkan.',
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                        duration: const Duration(seconds: 4),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                activeLabel: 'PENGINGAT AKTIF',
                inactiveLabel: 'INGATKAN SAYA PUASA INI',
                activeIcon: Icons.notifications_active_rounded,
                inactiveIcon: Icons.notifications_none_rounded,
                activeColor: cardAccentColor,
                inactiveColor: subColor,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getSunnahFastsForMonth(HijriDate hijriDate) {
    final List<Map<String, dynamic>> list = [];
    final hijriMap = HijriDate.getGregorianDatesForHijriMonth(hijriDate.year, hijriDate.month);
    
    // 1. Ayyamul Bidh
    List<int> ayyamulBidhDays = [13, 14, 15];
    if (hijriDate.month == 12) {
      // Dzulhijjah: 13th is Hari Tasyrik (prohibited to fast), so only 14 & 15
      ayyamulBidhDays = [14, 15];
    }
    
    List<DateTime> ayyamulBidhDates = [];
    for (var day in ayyamulBidhDays) {
      if (hijriMap.containsKey(day)) {
        ayyamulBidhDates.add(hijriMap[day]!);
      }
    }
    
    if (ayyamulBidhDates.isNotEmpty) {
      String dateRangeStr = ayyamulBidhDays.map((d) => "$d").join(", ") + " ${hijriDate.monthName}";
      String gregRangeStr = ayyamulBidhDates.map((d) => DateFormat('d MMM').format(d)).join(", ");
      
      list.add({
        'key': 'ayyamul_bidh_${hijriDate.year}_${hijriDate.month}',
        'name': 'Puasa Ayyamul Bidh',
        'dates': ayyamulBidhDates,
        'description': 'Puasa tiga hari di tengah bulan Hijriah saat bulan purnama bersinar terang.',
        'dateString': '$dateRangeStr ($gregRangeStr)',
        'rationale': 'Dari Abu Dzarr, Rasulullah SAW bersabda: "Jika engkau ingin berpuasa tiga hari di setiap bulan, maka berpuasalah pada tanggal 13, 14, dan 15." (HR. Tirmidzi no. 761, Hasan). Keutamaannya seperti berpuasa sepanjang tahun.',
      });
    }
    
    // 2. Senin & Kamis
    List<DateTime> seninKamisDates = [];
    hijriMap.forEach((day, date) {
      if (date.weekday == DateTime.monday || date.weekday == DateTime.thursday) {
        seninKamisDates.add(date);
      }
    });
    
    if (seninKamisDates.isNotEmpty) {
      seninKamisDates.sort();
      String gregStr = seninKamisDates.map((d) => DateFormat('d').format(d)).join(", ") + " " + DateFormat('MMM').format(seninKamisDates.first);
      list.add({
        'key': 'senin_kamis_${hijriDate.year}_${hijriDate.month}',
        'name': 'Puasa Senin & Kamis',
        'dates': seninKamisDates,
        'description': 'Puasa sunnah mingguan yang rutin dilaksanakan oleh Rasulullah SAW.',
        'dateString': 'Setiap hari Senin & Kamis ($gregStr)',
        'rationale': 'Rasulullah SAW bersabda: "Amal ibadah disodorkan kepada Allah pada hari Senin dan Kamis. Maka aku menyukai ketika amalku disodorkan, aku dalam keadaan berpuasa." (HR. Tirmidzi no. 747, Shahih).',
      });
    }
    
    // 3. Month-Specific Fasts
    if (hijriDate.month == 1) { // Muharram
      // Tasu'a (9 Muharram) & Asyura (10 Muharram)
      DateTime? tasuaDate = hijriMap[9];
      DateTime? asyuraDate = hijriMap[10];
      
      if (tasuaDate != null) {
        list.add({
          'key': 'tasua_${hijriDate.year}',
          'name': 'Puasa Tasu\'a (9 Muharram)',
          'dates': [tasuaDate],
          'description': 'Puasa sehari sebelum hari Asyura untuk menyelisihi kaum Yahudi.',
          'dateString': '9 Muharram (${DateFormat('d MMMM yyyy').format(tasuaDate)})',
          'rationale': 'Rasulullah SAW bersabda: "Sungguh jika aku masih hidup sampai tahun depan, niscaya aku akan berpuasa pada hari kesembilan (Muharram)." (HR. Muslim no. 1134).',
        });
      }
      
      if (asyuraDate != null) {
        list.add({
          'key': 'asyura_${hijriDate.year}',
          'name': 'Puasa Asyura (10 Muharram)',
          'dates': [asyuraDate],
          'description': 'Puasa yang memiliki keutamaan luar biasa menghapuskan dosa setahun yang lalu.',
          'dateString': '10 Muharram (${DateFormat('d MMMM yyyy').format(asyuraDate)})',
          'rationale': 'Rasulullah SAW ditanya tentang puasa hari Asyura, beliau menjawab: "Puasa Asyura dapat menghapuskan dosa setahun yang lalu." (HR. Muslim no. 1162).',
        });
      }
    } else if (hijriDate.month == 12) { // Dzulhijjah
      // Tarwiyah (8 Dzulhijjah) & Arafah (9 Dzulhijjah)
      DateTime? tarwiyahDate = hijriMap[8];
      DateTime? arafahDate = hijriMap[9];
      
      // First 9 days of Dzulhijjah (1-9 Dzulhijjah)
      List<DateTime> dzulhijjahFirst9Dates = [];
      for (int i = 1; i <= 9; i++) {
        if (hijriMap.containsKey(i)) {
          dzulhijjahFirst9Dates.add(hijriMap[i]!);
        }
      }
      
      if (dzulhijjahFirst9Dates.isNotEmpty) {
        String firstGreg = DateFormat('d').format(dzulhijjahFirst9Dates.first);
        String lastGreg = DateFormat('d MMM').format(dzulhijjahFirst9Dates.last);
        list.add({
          'key': 'awal_dzulhijjah_${hijriDate.year}',
          'name': 'Puasa Awal Dzulhijjah (1-9 Dzulhijjah)',
          'dates': dzulhijjahFirst9Dates,
          'description': 'Puasa di sembilan hari pertama bulan Dzulhijjah yang penuh berkah.',
          'dateString': '1-9 Dzulhijjah ($firstGreg - $lastGreg)',
          'rationale': 'Rasulullah SAW bersabda: "Tidak ada hari-hari yang amal shalih di dalamnya lebih dicintai Allah daripada sepuluh hari pertama Dzulhijjah." (HR. Bukhari no. 969). Sebagian istri Nabi meriwayatkan bahwa beliau terbiasa puasa 9 hari pertama Dzulhijjah.',
        });
      }
      
      if (tarwiyahDate != null) {
        list.add({
          'key': 'tarwiyah_${hijriDate.year}',
          'name': 'Puasa Tarwiyah (8 Dzulhijjah)',
          'dates': [tarwiyahDate],
          'description': 'Puasa hari kedelapan Dzulhijjah sebelum hari Arafah.',
          'dateString': '8 Dzulhijjah (${DateFormat('d MMMM yyyy').format(tarwiyahDate)})',
          'rationale': 'Puasa pada hari-hari awal Dzulhijjah sangat dicintai Allah SWT sebagai bagian dari amal sholeh umum di awal Dzulhijjah.',
        });
      }
      
      if (arafahDate != null) {
        list.add({
          'key': 'arafah_${hijriDate.year}',
          'name': 'Puasa Arafah (9 Dzulhijjah)',
          'dates': [arafahDate],
          'description': 'Puasa sunnah paling mulia bagi yang tidak melaksanakan ibadah haji.',
          'dateString': '9 Dzulhijjah (${DateFormat('d MMMM yyyy').format(arafahDate)})',
          'rationale': 'Rasulullah SAW bersabda: "Puasa hari Arafah, aku berharap kepada Allah akan menghapuskan dosa setahun setelahnya dan setahun sebelumnya." (HR. Muslim no. 1162).',
        });
      }
    } else if (hijriDate.month == 8) { // Sya'ban
      // Nisfu Sya'ban (15 Sya'ban)
      DateTime? nisfuDate = hijriMap[15];
      if (nisfuDate != null) {
        list.add({
          'key': 'nisfu_syaban_${hijriDate.year}',
          'name': 'Puasa Nisfu Sya\'ban (15 Sya\'ban)',
          'dates': [nisfuDate],
          'description': 'Puasa sunnah pertengahan bulan Sya\'ban sebelum memasuki Ramadhan.',
          'dateString': '15 Sya\'ban (${DateFormat('d MMMM yyyy').format(nisfuDate)})',
          'rationale': 'Bulan Sya\'ban adalah bulan diangkatnya amal perbuatan kepada Allah. Rasulullah SAW bersabda: "Aku ingin amalku diangkat saat aku dalam keadaan berpuasa." (HR. An-Nasa\'i no. 2357, Shahih).',
        });
      }
    }
    
    return list;
  }
}