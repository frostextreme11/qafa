import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/notification_service.dart';

enum FastingType {
  qada,
  mondayThursday,
  daud,
  sunnah,
  kafarah,
}

extension FastingTypeExtension on FastingType {
  String get name {
    switch (this) {
      case FastingType.qada:
        return 'Qada';
      case FastingType.mondayThursday:
        return 'Senin/Kamis';
      case FastingType.daud:
        return 'Daud';
      case FastingType.sunnah:
        return 'Sunnah';
      case FastingType.kafarah:
        return 'Kafarah';
    }
  }

  Color get color {
    switch (this) {
      case FastingType.qada:
        return Colors.red;
      case FastingType.mondayThursday:
        return Colors.blue;
      case FastingType.daud:
        return Colors.purple;
      case FastingType.sunnah:
        return Colors.orange;
      case FastingType.kafarah:
        return Colors.green;
    }
  }
}

class FastingDay {
  final DateTime date;
  final FastingType type;

  FastingDay({required this.date, required this.type});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'type': type.index,
  };

  factory FastingDay.fromJson(Map<String, dynamic> json) => FastingDay(
    date: DateTime.parse(json['date']),
    type: FastingType.values[json['type']],
  );
}

class FastingTarget {
  final String id;
  final FastingType type;
  final int targetDays;
  final DateTime createdAt;
  final bool isCompleted;

  FastingTarget({
    required this.id,
    required this.type,
    required this.targetDays,
    required this.createdAt,
    this.isCompleted = false,
  });

  int getCompletedDays(FastingProvider provider) {
    return provider.getCompletedDaysForType(type);
  }

  double getProgress(FastingProvider provider) => getCompletedDays(provider) / targetDays;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'targetDays': targetDays,
    'createdAt': createdAt.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory FastingTarget.fromJson(Map<String, dynamic> json) => FastingTarget(
    id: json['id'],
    type: FastingType.values[json['type']],
    targetDays: json['targetDays'],
    createdAt: DateTime.parse(json['createdAt']),
    isCompleted: json['isCompleted'] ?? false,
  );
}

class FastingProvider with ChangeNotifier {
  List<FastingDay> _fastingDays = [];
  List<FastingTarget> _fastingTargets = [];
  int? _qadaTarget; // User-set target for qada fasting
  bool _isFastingToday = false;
  Set<String> _enabledSunnahReminders = {};

  List<FastingDay> get fastingDays => _fastingDays;
  List<FastingTarget> get fastingTargets => _fastingTargets;
  int? get qadaTarget => _qadaTarget;
  bool get isFastingToday => _isFastingToday;
  Set<String> get enabledSunnahReminders => _enabledSunnahReminders;

  bool isSunnahReminderEnabled(String fastKey) {
    return _enabledSunnahReminders.contains(fastKey);
  }

  void setFastingToday(bool value, {DateTime? fajrTime, DateTime? maghribTime}) {
    _isFastingToday = value;
    _saveFastingTodayState();
    
    if (value && fajrTime != null && maghribTime != null) {
      _scheduleFastingAlerts(fajrTime, maghribTime);
    } else {
      _cancelFastingAlerts();
    }
    
    notifyListeners();
  }

  void rescheduleFastingAlerts(DateTime fajrTime, DateTime maghribTime) {
    if (_isFastingToday) {
      _scheduleFastingAlerts(fajrTime, maghribTime);
    }
  }

  Future<void> _scheduleFastingAlerts(DateTime fajrTime, DateTime maghribTime) async {
    final notificationService = NotificationService();
    
    final imsakTime = fajrTime.subtract(const Duration(minutes: 10));
    final imsakWarningTime = imsakTime.subtract(const Duration(minutes: 15));

    await _cancelFastingAlerts();

    if (imsakWarningTime.isAfter(DateTime.now())) {
      await notificationService.scheduleNotification(
        id: 7001,
        title: '15 Menit Menuju Imsak ⏳',
        body: 'Persiapkan sahur Anda, waktu imsak akan tiba dalam 15 menit lagi.',
        scheduledDate: imsakWarningTime,
        channelId: 'fasting_alerts',
        channelName: 'Fasting Reminders',
      );
    }

    if (imsakTime.isAfter(DateTime.now())) {
      await notificationService.scheduleNotification(
        id: 7002,
        title: 'Waktu Imsak Telah Tiba! 🔔',
        body: 'Imsak! Hentikan makan dan minum sahur sekarang. Semoga puasa Anda diberkahi.',
        scheduledDate: imsakTime,
        channelId: 'fasting_alerts',
        channelName: 'Fasting Reminders',
      );
    }

    if (maghribTime.isAfter(DateTime.now())) {
      await notificationService.scheduleNotification(
        id: 7003,
        title: 'Selamat Berbuka Puasa! 🎉 🌅',
        body: 'Waktu Maghrib telah tiba. Segeralah membatalkan puasa dan menunaikan ibadah sholat Maghrib.',
        scheduledDate: maghribTime,
        channelId: 'fasting_alerts',
        channelName: 'Fasting Reminders',
      );
    }
  }

  Future<void> _cancelFastingAlerts() async {
    final notificationService = NotificationService();
    await notificationService.cancel(7001);
    await notificationService.cancel(7002);
    await notificationService.cancel(7003);
  }

  Future<void> _saveFastingTodayState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFastingToday', _isFastingToday);
  }

  Map<DateTime, List<FastingDay>> get fastingDaysMap {
    Map<DateTime, List<FastingDay>> map = {};
    for (var day in _fastingDays) {
      DateTime key = DateTime(day.date.year, day.date.month, day.date.day);
      if (map[key] == null) {
        map[key] = [];
      }
      map[key]!.add(day);
    }
    return map;
  }

  void addFastingDay(DateTime date, FastingType type) {
    // Remove existing fasting on this date
    _fastingDays.removeWhere((day) =>
      day.date.year == date.year &&
      day.date.month == date.month &&
      day.date.day == date.day &&
      day.type == type
    );

    _fastingDays.add(FastingDay(date: date, type: type));
    _checkAndUpdateTargets();
    _saveFastingData();
    notifyListeners();
  }

  void removeFastingDay(DateTime date, FastingType type) {
    _fastingDays.removeWhere((day) =>
      day.date.year == date.year &&
      day.date.month == date.month &&
      day.date.day == date.day &&
      day.type == type
    );
    _saveFastingData();
    notifyListeners();
  }

  bool hasFastingOnDate(DateTime date, FastingType type) {
    return _fastingDays.any((day) =>
      day.date.year == date.year &&
      day.date.month == date.month &&
      day.date.day == date.day &&
      day.type == type
    );
  }

  // Target methods
  void addFastingTarget(FastingType type, int targetDays) {
    final target = FastingTarget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      targetDays: targetDays,
      createdAt: DateTime.now(),
    );
    _fastingTargets.add(target);
    _saveFastingTargets();
    notifyListeners();
  }

  void removeFastingTarget(String id) {
    _fastingTargets.removeWhere((target) => target.id == id);
    _saveFastingTargets();
    notifyListeners();
  }

  void updateTargetCompletion(String id, bool isCompleted) {
    final index = _fastingTargets.indexWhere((target) => target.id == id);
    if (index != -1) {
      _fastingTargets[index] = FastingTarget(
        id: _fastingTargets[index].id,
        type: _fastingTargets[index].type,
        targetDays: _fastingTargets[index].targetDays,
        createdAt: _fastingTargets[index].createdAt,
        isCompleted: isCompleted,
      );
      _saveFastingTargets();
      notifyListeners();
    }
  }

  int getCompletedDaysForType(FastingType type) {
    return _fastingDays.where((day) => day.type == type).length;
  }

  // Get qada fasting progress
  int get qadaCompleted => getCompletedDaysForType(FastingType.qada);
  int get defaultQadaTarget => 30; // Default target for qada fasting debt
  double get qadaProgress => _qadaTarget != null ? qadaCompleted / _qadaTarget! : 0.0;

  void setQadaTarget(int target) {
    _qadaTarget = target;
    _saveQadaTarget();
    notifyListeners();
  }

  Future<void> loadFastingData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('fastingDays');
    if (data != null) {
      final List<dynamic> jsonList = json.decode(data);
      _fastingDays = jsonList.map((json) => FastingDay.fromJson(json)).toList();
    }

    final targetsData = prefs.getString('fastingTargets');
    if (targetsData != null) {
      final List<dynamic> jsonList = json.decode(targetsData);
      _fastingTargets = jsonList.map((json) => FastingTarget.fromJson(json)).toList();
    }

    _qadaTarget = prefs.getInt('qadaTarget');
    _isFastingToday = prefs.getBool('isFastingToday') ?? false;

    final sunnahRemindersData = prefs.getStringList('enabledSunnahReminders');
    if (sunnahRemindersData != null) {
      _enabledSunnahReminders = sunnahRemindersData.toSet();
    }
  }

  Future<void> _saveFastingData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _fastingDays.map((day) => day.toJson()).toList();
    await prefs.setString('fastingDays', json.encode(jsonList));
  }

  Future<void> _saveFastingTargets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _fastingTargets.map((target) => target.toJson()).toList();
    await prefs.setString('fastingTargets', json.encode(jsonList));
  }

  Future<void> _saveQadaTarget() async {
    final prefs = await SharedPreferences.getInstance();
    if (_qadaTarget != null) {
      await prefs.setInt('qadaTarget', _qadaTarget!);
    } else {
      await prefs.remove('qadaTarget');
    }
  }

  void _checkAndUpdateTargets() {
    for (int i = 0; i < _fastingTargets.length; i++) {
      final target = _fastingTargets[i];
      if (!target.isCompleted) {
        final completedDays = getCompletedDaysForType(target.type);
        if (completedDays >= target.targetDays) {
          _fastingTargets[i] = FastingTarget(
            id: target.id,
            type: target.type,
            targetDays: target.targetDays,
            createdAt: target.createdAt,
            isCompleted: true,
          );
        }
      }
    }
  }

  Future<void> toggleSunnahReminder(String fastKey, List<DateTime> fastDates, String fastName) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationService = NotificationService();
    
    if (_enabledSunnahReminders.contains(fastKey)) {
      _enabledSunnahReminders.remove(fastKey);
      
      // Cancel scheduled notifications for these dates
      for (var date in fastDates) {
        int baseId = 8000 + (date.month * 100) + date.day;
        int morningId = baseId * 10;
        int eveningId = (baseId * 10) + 1;
        await notificationService.cancel(morningId);
        await notificationService.cancel(eveningId);
      }
    } else {
      _enabledSunnahReminders.add(fastKey);
      
      // Schedule H-1 notifications
      for (var date in fastDates) {
        DateTime h1 = date.subtract(const Duration(days: 1));
        
        DateTime morningTime = DateTime(h1.year, h1.month, h1.day, 6, 0);
        DateTime eveningTime = DateTime(h1.year, h1.month, h1.day, 20, 30);
        
        int baseId = 8000 + (date.month * 100) + date.day;
        int morningId = baseId * 10;
        int eveningId = (baseId * 10) + 1;
        
        String dateStr = "${date.day} ${_getMonthNameIndo(date.month)} ${date.year}";
        
        if (morningTime.isAfter(DateTime.now())) {
          await notificationService.scheduleNotification(
            id: morningId,
            title: 'Persiapan Puasa Besok! 🌅',
            body: 'Besok ada puasa sunnah $fastName ($dateStr). Jangan lupa sahur nanti malam!',
            scheduledDate: morningTime,
            channelId: 'sunnah_fasting',
            channelName: 'Sunnah Fasting Reminders',
          );
        }
        
        if (eveningTime.isAfter(DateTime.now())) {
          await notificationService.scheduleNotification(
            id: eveningId,
            title: 'Persiapan Puasa Besok! 🌙',
            body: 'Niatkan puasa sunnah $fastName untuk esok hari ($dateStr). Siapkan sahur Anda sekarang.',
            scheduledDate: eveningTime,
            channelId: 'sunnah_fasting',
            channelName: 'Sunnah Fasting Reminders',
          );
        }
      }
    }
    
    await prefs.setStringList('enabledSunnahReminders', _enabledSunnahReminders.toList());
    notifyListeners();
  }
  
  String _getMonthNameIndo(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}