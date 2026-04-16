import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    // In flutter_timezone 5.0.2, getLocalTimezone returns a Future<TimezoneInfo>
    // We must extract the identifier string to set the location.
    final TimezoneInfo tzInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = tzInfo.identifier;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }

  Future<void> requestPermissions() async {
    await Permission.notification.request();
    
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? sound,
    String? channelId,
    String? channelName,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId ?? 'default_channel',
      channelName ?? 'Default Notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: sound != null ? RawResourceAndroidNotificationSound(sound) : null,
      playSound: true,
    );

    final iosDetails = DarwinNotificationDetails(
      sound: sound != null ? '$sound.aiff' : null,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> schedulePrayerReminders({
    required String prayerName,
    required DateTime prayerTime,
    required bool remind15,
    required bool remind5,
    required bool remindNow,
    String? customSound,
  }) async {
    int baseId = _getPrayerId(prayerName);

    if (remind15) {
      final time = prayerTime.subtract(const Duration(minutes: 15));
      if (time.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: baseId + 1,
          title: '15 Menit Lagi $prayerName',
          body: 'Bersiaplah untuk menunaikan ibadah sholat $prayerName.',
          scheduledDate: time,
          sound: customSound,
        );
      }
    }

    if (remind5) {
      final time = prayerTime.subtract(const Duration(minutes: 5));
      if (time.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: baseId + 2,
          title: '5 Menit Lagi $prayerName',
          body: 'Segera bersuci, waktu $prayerName tinggal 5 menit lagi.',
          scheduledDate: time,
          sound: customSound,
        );
      }
    }

    if (remindNow) {
      if (prayerTime.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: baseId + 3,
          title: 'Waktu Sholat $prayerName',
          body: 'Hayya \'alash Shalah! Waktu sholat $prayerName telah tiba.',
          scheduledDate: prayerTime,
          sound: customSound,
        );
      }
    }
  }

  Future<void> scheduleWaterReminder({
    required int id,
    required String body,
    required DateTime time,
  }) async {
    await scheduleNotification(
      id: id,
      title: 'Hidrasi Berkah',
      body: body,
      scheduledDate: time,
    );
  }

  int _getPrayerId(String name) {
    switch (name.toLowerCase()) {
      case 'subuh': return 1000;
      case 'dzuhur': return 2000;
      case 'ashar': return 3000;
      case 'maghrib': return 4000;
      case 'isya': return 5000;
      default: return 6000;
    }
  }
}
