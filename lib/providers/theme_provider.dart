import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark; // Default to Dark as requested

  ThemeMode get themeMode => _themeMode;

  // Celestial Prism Design Tokens
  static const Color darkBase = Color(0xFF02161D);
  static const Color emerald = Color(0xFF3CE36A);
  static const Color emeraldContainer = Color(0xFF004F1C);
  static const Color gold = Color(0xFFFFDB3C);
  static const Color cyan = Color(0xFF45D8ED);
  static const Color ghostBorder = Color(0x263CE36A); // 15% Emerald

  static const Color lightBase = Color(0xFFF8FCF9);
  static const Color lightSurface = Color(0xFFF0F5F2);

  ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: emerald,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF2BBD55),
        primaryContainer: const Color(0xFFD5F4DE),
        secondary: const Color(0xFFA5921D), // Darker gold for light theme
        surface: lightBase,
        background: lightSurface,
        onPrimary: Colors.white,
        onSurface: const Color(0xFF02161D),
      ),
      scaffoldBackgroundColor: lightSurface,
      textTheme: GoogleFonts.manropeTextTheme().copyWith(
        bodyMedium: GoogleFonts.inter(),
        bodyLarge: GoogleFonts.inter(),
      ),
      cardTheme: CardThemeData(
        color: lightBase,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.green.withOpacity(0.1)),
        ),
      ),
    );
  }

  ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: emerald,
      colorScheme: const ColorScheme.dark(
        primary: emerald,
        primaryContainer: emeraldContainer,
        secondary: gold,
        tertiary: cyan,
        surface: darkBase,
        background: darkBase,
        onPrimary: darkBase,
        onSurface: Colors.white,
        surfaceVariant: Color(0xFF042A36),
      ),
      scaffoldBackgroundColor: darkBase,
      textTheme: GoogleFonts.manropeTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ).copyWith(
        bodyMedium: GoogleFonts.inter(color: Colors.white70),
        bodyLarge: GoogleFonts.inter(color: Colors.white),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF042A36),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveTheme();
    notifyListeners();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? ThemeMode.dark.index;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', _themeMode.index);
  }
}