import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/fasting_provider.dart';
import 'screens/home_screen.dart';
import 'screens/prayer_times_screen.dart';
import 'screens/qibla_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/doa_screen.dart';
import 'screens/water_screen.dart';
import 'widgets/glass_card.dart';
import 'services/notification_service.dart';
import 'providers/water_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  final themeProvider = ThemeProvider();
  final settingsProvider = SettingsProvider();
  final fastingProvider = FastingProvider();
  final waterProvider = WaterProvider();
  
  await themeProvider.loadTheme();
  await settingsProvider.loadSettings();
  await fastingProvider.loadFastingData();
  await waterProvider.loadWaterData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeProvider),
        ChangeNotifierProvider(create: (_) => settingsProvider),
        ChangeNotifierProvider(create: (_) => fastingProvider),
        ChangeNotifierProvider(create: (_) => waterProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Qada Fast Tracker',
      theme: themeProvider.getLightTheme(),
      darkTheme: themeProvider.getDarkTheme(),
      themeMode: themeProvider.themeMode,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PrayerTimesScreen(),
    const QiblaScreen(),
    const DoaScreen(),
    const WaterScreen(),
  ];

  final List<String> _titles = [
    'DASHBOARD',
    'SHOLAT',
    'KIBLAT',
    'DOA',
    'AIR',
  ];

  final List<IconData> _icons = [
    Icons.grid_view_rounded,
    Icons.mosque_rounded,
    Icons.explore_rounded,
    Icons.auto_stories_rounded,
    Icons.opacity_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBody: true, // Important for glass navigation bar
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            fontSize: 14,
            color: isDark ? Theme.of(context).primaryColor : Colors.green[800],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white70 : Colors.black54),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
        opacity: _controller,
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        height: 80,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: GlassCard(
          isAsymmetric: false,
          borderRadius: 30,
          padding: EdgeInsets.zero,
          blur: 15,
          opacity: isDark ? 0.05 : 0.4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_screens.length, (index) {
              final isSelected = _selectedIndex == index;
              return InkWell(
                onTap: () => _onItemTapped(index),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? Theme.of(context).primaryColor.withOpacity(0.1) 
                      : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _icons[index],
                        color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : (isDark ? Colors.white38 : Colors.black26),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      if (isSelected)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}