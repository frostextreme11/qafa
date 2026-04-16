import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  List<FastingDay> get fastingDays => _fastingDays;
  List<FastingTarget> get fastingTargets => _fastingTargets;
  int? get qadaTarget => _qadaTarget;

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
}