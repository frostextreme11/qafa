import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qafa/main.dart';
import 'package:qafa/providers/theme_provider.dart';
import 'package:qafa/providers/settings_provider.dart';
import 'package:qafa/providers/fasting_provider.dart';
import 'package:qafa/providers/water_provider.dart';

void main() {
  testWidgets('App rendering test', (WidgetTester tester) async {
    // Provide mock initial values for SharedPreferences to prevent runtime errors
    SharedPreferences.setMockInitialValues({});
    
    final themeProvider = ThemeProvider();
    final settingsProvider = SettingsProvider();
    final fastingProvider = FastingProvider();
    final waterProvider = WaterProvider();

    // Load mock settings
    await themeProvider.loadTheme();
    await settingsProvider.loadSettings();
    await fastingProvider.loadFastingData();
    await waterProvider.loadWaterData();

    await tester.pumpWidget(
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

    // Verify that the MainScreen / MyApp renders by checking for standard elements
    expect(find.byType(MyApp), findsOneWidget);
  });
}
