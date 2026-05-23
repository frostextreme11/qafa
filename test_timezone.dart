import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz.initializeTimeZones();
  final location = tz.getLocation('Asia/Jakarta');
  tz.setLocalLocation(location);

  // local DateTime: 15:08
  final localDateTime = DateTime(2026, 5, 21, 15, 8);
  print('localDateTime: $localDateTime (isUtc: ${localDateTime.isUtc})');

  final tzDateTime = tz.TZDateTime.from(localDateTime, tz.local);
  print('tzDateTime: $tzDateTime');
  print('tzDateTime toUtc: ${tzDateTime.toUtc()}');
  print('tzDateTime year: ${tzDateTime.year}, month: ${tzDateTime.month}, day: ${tzDateTime.day}, hour: ${tzDateTime.hour}, minute: ${tzDateTime.minute}');
}
