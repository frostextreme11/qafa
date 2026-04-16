import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/fasting_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/quote_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/blinking_markers.dart';
import '../widgets/semi_circle_progress.dart';
import '../data/local_quotes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<String> _quotes = [];
  bool _isLoadingQuotes = true;

  final String _geminiApiKey = 'AIzaSyAVUD3eYrPOx3Qlvsf0tp5bDwQVbrvRDl4';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
    _generateInitialQuotes();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generateInitialQuotes() async {
    setState(() => _isLoadingQuotes = true);
    final localList = List<String>.from(LocalQuotes.quotes);
    localList.shuffle();
    setState(() {
      _quotes = localList.take(10).toList();
      _isLoadingQuotes = false;
    });
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

  @override
  Widget build(BuildContext context) {
    final fastingProvider = Provider.of<FastingProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quotes Section
          Stack(
            children: [
              SizedBox(
                height: 220,
                child: _isLoadingQuotes
                    ? const Center(child: CircularProgressIndicator())
                    : PageView.builder(
                        itemCount: _quotes.length,
                        controller: PageController(viewportFraction: 0.9),
                        itemBuilder: (context, index) => QuoteCard(quote: _quotes[index]),
                      ),
              ),
              Positioned(
                bottom: 15,
                right: 35,
                child: IconButton(
                  onPressed: _isLoadingQuotes ? null : _generateMoreQuotes,
                  icon: Icon(Icons.refresh_rounded, color: Theme.of(context).primaryColor, size: 20),
                  tooltip: 'Refresh Quotes',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Centralized Qada Progress
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: GlassCard(
                padding: const EdgeInsets.all(24),
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
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _updateQadaTarget(context, fastingProvider),
                          icon: Icon(Icons.edit_note_rounded, size: 20, color: Theme.of(context).primaryColor.withOpacity(0.5)),
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
                          child: CustomPaint(
                            painter: SemiCircleProgressPainter(
                              progress: fastingProvider.qadaProgress,
                              color: Theme.of(context).primaryColor,
                              strokeWidth: 16,
                              glow: true,
                            ),
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


          // Detailed Statistics Grid
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: _buildStatsGrid(fastingProvider, isDark),
          ),
          const SizedBox(height: 6),  
          // Calendar Section
          _buildCalendarCard(fastingProvider, textColor),
          const SizedBox(height: 6),

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
                  icon: Icon(Icons.add_circle_rounded, size: 22, color: Theme.of(context).primaryColor),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          _buildTargetList(fastingProvider, isDark, textColor, subColor),
        ],
      ),
    );
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
              if (target != null) provider.setQadaTarget(target);
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
      mainAxisSpacing: 6,
      childAspectRatio: 1.1,
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
            style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w900, color: color),
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

  void _showFastingDetailsDialog(DateTime date, List<FastingDay> days) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Details',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, a1, a2) => Container(),
      transitionBuilder: (context, a1, a2, child) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(DateFormat('dd MMMM yyyy').format(date), style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: days.map((d) => ListTile(
                  leading: Icon(Icons.check_circle_rounded, color: d.type.color),
                  title: Text(d.type.name, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    onPressed: () {
                      Provider.of<FastingProvider>(context, listen: false).removeFastingDay(date, d.type);
                      Navigator.pop(context);
                    },
                  ),
                )).toList(),
              ),
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
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              title: Text('LOG FASTING', style: GoogleFonts.manrope(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14, color: Theme.of(context).textTheme.titleLarge?.color?.withOpacity(0.7))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: FastingType.values.map((type) => ListTile(
                  onTap: () {
                    Provider.of<FastingProvider>(context, listen: false).addFastingDay(date, type);
                    Navigator.pop(context);
                  },
                  leading: Container(width: 12, height: 12, decoration: BoxDecoration(color: type.color, shape: BoxShape.circle)),
                  title: Text(type.name, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                  trailing: Icon(Icons.add_rounded, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.2)),
                )).toList(),
              ),
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
    if (active.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Focus on your daily goal.', style: TextStyle(color: Colors.white24))));
    return Column(children: active.map((t) => _buildTargetItem(t, textColor, subColor)).toList());
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
                Text('${(progress * 100).toInt()}%', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w200, color: textColor)),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation(target.type.color),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}