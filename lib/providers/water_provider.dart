import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';

class WaterProvider with ChangeNotifier {
  Map<String, Map<String, int>> _waterData = {};
  
  static const int sahurTarget = 2;
  static const int berbukaTarget = 4;
  static const int malamTarget = 2;
  static const int totalTarget = sahurTarget + berbukaTarget + malamTarget;

  Map<String, Map<String, int>> get waterData => _waterData;

  Future<void> loadWaterData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('water_data_v1');
    if (data != null) {
      try {
        final decoded = json.decode(data) as Map<String, dynamic>;
        _waterData = decoded.map((key, value) {
          final dayData = value as Map<String, dynamic>;
          return MapEntry(key, {
            'sahur': (dayData['sahur'] ?? 0) as int,
            'berbuka': (dayData['berbuka'] ?? 0) as int,
            'malam': (dayData['malam'] ?? 0) as int,
          });
        });
      } catch (e) {
        debugPrint('Error decoding water data: $e');
      }
    }
    notifyListeners();
  }

  Future<void> addWater(DateTime date, String category, int amount) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    if (!_waterData.containsKey(dateKey)) {
      _waterData[dateKey] = {'sahur': 0, 'berbuka': 0, 'malam': 0};
    }
    
    _waterData[dateKey]![category] = (_waterData[dateKey]![category] ?? 0) + amount;
    await _saveWaterData();
    notifyListeners();
  }

  int getWaterAmount(DateTime date, String category) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    return _waterData[dateKey]?[category] ?? 0;
  }

  int getTodayTotal() {
    final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dayData = _waterData[dateKey];
    if (dayData == null) return 0;
    return (dayData['sahur'] ?? 0) + (dayData['berbuka'] ?? 0) + (dayData['malam'] ?? 0);
  }

  Future<void> _saveWaterData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('water_data_v1', json.encode(_waterData));
  }

  void scheduleSmartWaterReminders(bool enabled) async {
    if (!enabled) {
      // Logic to cancel water specific notifications if needed
      return;
    }

    final now = DateTime.now();
    final dateKey = DateFormat('yyyy-MM-dd').format(now);
    final dayData = _waterData[dateKey] ?? {'sahur': 0, 'berbuka': 0, 'malam': 0};
    
    int totalToday = (dayData['sahur'] ?? 0) + (dayData['berbuka'] ?? 0) + (dayData['malam'] ?? 0);
    int remaining = totalTarget - totalToday;

    if (remaining <= 0) return;

    // Smart Timer Logic:
    // Define active windows: 18:00 - 23:00 (Post-Iftar) and 03:00 - 04:30 (Pre-Sahur)
    List<DateTime> reminderTimes = [];
    
    // Check if we are in evening window
    DateTime iftarStart = DateTime(now.year, now.month, now.day, 18, 15);
    DateTime sleepTime = DateTime(now.year, now.month, now.day, 22, 30);
    
    if (now.isBefore(sleepTime)) {
      Duration window = sleepTime.difference(now.isAfter(iftarStart) ? now : iftarStart);
      if (window.inMinutes > 30) {
        int slots = (window.inMinutes / 60).floor().clamp(1, remaining);
        for (int i = 1; i <= slots; i++) {
          reminderTimes.add((now.isAfter(iftarStart) ? now : iftarStart).add(Duration(minutes: i * 60)));
        }
      }
    }

    // Schedule them
    for (int i = 0; i < reminderTimes.length; i++) {
      if (reminderTimes[i].isAfter(now)) {
        await NotificationService().scheduleWaterReminder(
          id: 9000 + i,
          body: 'Sudah saatnya minum segelas air lagi untuk mencapai target harianmu.',
          time: reminderTimes[i],
        );
      }
    }
  }
}
