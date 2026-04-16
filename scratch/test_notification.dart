import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  final plugin = FlutterLocalNotificationsPlugin();
  plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('app_icon'),
    ),
    onDidReceiveNotificationResponse: (details) {},
  );
}
