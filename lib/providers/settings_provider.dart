import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  String _selectedCity = 'Cimahi';
  Color _selectedColor = const Color(0xFF3CE36A); 

  // Notification Toggles
  bool _prayerNotificationsEnabled = false;
  bool _prayerReminder15 = true;
  bool _prayerReminder5 = true;
  bool _prayerNow = true;
  bool _waterNotificationsEnabled = false;
  String _notificationSound = 'default';

  String get selectedCity => _selectedCity;
  Color get selectedColor => _selectedColor;
  bool get prayerNotificationsEnabled => _prayerNotificationsEnabled;
  bool get prayerReminder15 => _prayerReminder15;
  bool get prayerReminder5 => _prayerReminder5;
  bool get prayerNow => _prayerNow;
  bool get waterNotificationsEnabled => _waterNotificationsEnabled;
  String get notificationSound => _notificationSound;

  void setPrayerNotificationsEnabled(bool value) {
    _prayerNotificationsEnabled = value;
    _saveSettings();
    notifyListeners();
  }

  void setPrayerReminder15(bool value) {
    _prayerReminder15 = value;
    _saveSettings();
    notifyListeners();
  }

  void setPrayerReminder5(bool value) {
    _prayerReminder5 = value;
    _saveSettings();
    notifyListeners();
  }

  void setPrayerNow(bool value) {
    _prayerNow = value;
    _saveSettings();
    notifyListeners();
  }

  void setWaterNotificationsEnabled(bool value) {
    _waterNotificationsEnabled = value;
    _saveSettings();
    notifyListeners();
  }

  void setNotificationSound(String sound) {
    _notificationSound = sound;
    _saveSettings();
    notifyListeners();
  }

  void setSelectedCity(String city) {
    _selectedCity = city;
    _saveSettings();
    notifyListeners();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCity = prefs.getString('selectedCity') ?? 'Cimahi';
    _prayerNotificationsEnabled = prefs.getBool('prayerNotificationsEnabled') ?? false;
    _prayerReminder15 = prefs.getBool('prayerReminder15') ?? true;
    _prayerReminder5 = prefs.getBool('prayerReminder5') ?? true;
    _prayerNow = prefs.getBool('prayerNow') ?? true;
    _waterNotificationsEnabled = prefs.getBool('waterNotificationsEnabled') ?? false;
    _notificationSound = prefs.getString('notificationSound') ?? 'default';
    
    final colorValue = prefs.getInt('selectedColor');
    if (colorValue != null) {
      _selectedColor = Color(colorValue);
    }
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCity', _selectedCity);
    await prefs.setInt('selectedColor', _selectedColor.value);
    await prefs.setBool('prayerNotificationsEnabled', _prayerNotificationsEnabled);
    await prefs.setBool('prayerReminder15', _prayerReminder15);
    await prefs.setBool('prayerReminder5', _prayerReminder5);
    await prefs.setBool('prayerNow', _prayerNow);
    await prefs.setBool('waterNotificationsEnabled', _waterNotificationsEnabled);
    await prefs.setString('notificationSound', _notificationSound);
  }
}