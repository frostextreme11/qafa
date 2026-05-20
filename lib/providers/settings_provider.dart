import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';

class SettingsProvider with ChangeNotifier {
  static const Map<String, Map<String, double>> presetLocations = {
    'Cimahi': {'lat': -6.8722, 'lng': 107.5425},
    'Bandung': {'lat': -6.9175, 'lng': 107.6191},
    'Madinah': {'lat': 24.5247, 'lng': 39.5692},
    'Mekkah': {'lat': 21.3891, 'lng': 39.8579},
    'Jeddah': {'lat': 21.4858, 'lng': 39.1925},
  };

  String _selectedCity = 'Cimahi';
  Color _selectedColor = const Color(0xFF3CE36A); 

  // Notification Toggles
  bool _prayerNotificationsEnabled = false;
  bool _prayerReminder15 = true;
  bool _prayerReminder5 = true;
  bool _prayerNow = true;
  bool _waterNotificationsEnabled = false;
  String _notificationSound = 'default';

  // Realtime GPS Prayer Times Option
  bool _useCurrentLocation = false;

  // Custom Audio Path from device
  String? _customSoundPath;
  String? _customSoundName;

  String get selectedCity => _selectedCity;
  Color get selectedColor => _selectedColor;
  bool get prayerNotificationsEnabled => _prayerNotificationsEnabled;
  bool get prayerReminder15 => _prayerReminder15;
  bool get prayerReminder5 => _prayerReminder5;
  bool get prayerNow => _prayerNow;
  bool get waterNotificationsEnabled => _waterNotificationsEnabled;
  String get notificationSound => _notificationSound;
  bool get useCurrentLocation => _useCurrentLocation;
  String? get customSoundPath => _customSoundPath;
  String? get customSoundName => _customSoundName;

  Future<Coordinates> getCoordinates() async {
    if (_useCurrentLocation) {
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          final latLng = presetLocations[_selectedCity] ?? presetLocations['Cimahi']!;
          return Coordinates(latLng['lat']!, latLng['lng']!);
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            final latLng = presetLocations[_selectedCity] ?? presetLocations['Cimahi']!;
            return Coordinates(latLng['lat']!, latLng['lng']!);
          }
        }
        
        if (permission == LocationPermission.deniedForever) {
          final latLng = presetLocations[_selectedCity] ?? presetLocations['Cimahi']!;
          return Coordinates(latLng['lat']!, latLng['lng']!);
        }

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        return Coordinates(position.latitude, position.longitude);
      } catch (e) {
        // Fallback
      }
    }
    final latLng = presetLocations[_selectedCity] ?? presetLocations['Cimahi']!;
    return Coordinates(latLng['lat']!, latLng['lng']!);
  }

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
    if (sound != 'custom') {
      _customSoundPath = null;
      _customSoundName = null;
    }
    _saveSettings();
    notifyListeners();
  }

  void setCustomSound(String? path, String? name) {
    _customSoundPath = path;
    _customSoundName = name;
    if (path != null) {
      _notificationSound = 'custom';
    }
    _saveSettings();
    notifyListeners();
  }

  void setUseCurrentLocation(bool value) {
    _useCurrentLocation = value;
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
    _useCurrentLocation = prefs.getBool('useCurrentLocation') ?? false;
    _customSoundPath = prefs.getString('customSoundPath');
    _customSoundName = prefs.getString('customSoundName');
    
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
    await prefs.setBool('useCurrentLocation', _useCurrentLocation);
    if (_customSoundPath != null) {
      await prefs.setString('customSoundPath', _customSoundPath!);
      await prefs.setString('customSoundName', _customSoundName!);
    } else {
      await prefs.remove('customSoundPath');
      await prefs.remove('customSoundName');
    }
  }
}