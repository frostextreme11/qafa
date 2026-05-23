import 'package:adhan/adhan.dart';

void main() {
  final coordinates = Coordinates(-6.8722, 107.5425); // Cimahi
  final params = CalculationMethod.singapore.getParameters();
  params.madhab = Madhab.shafi;
  
  final now = DateTime.now();
  final prayerTimes = PrayerTimes(coordinates, DateComponents.from(now), params);
  
  print('fajr: ${prayerTimes.fajr} (isUtc: ${prayerTimes.fajr.isUtc})');
  print('sunrise: ${prayerTimes.sunrise} (isUtc: ${prayerTimes.sunrise.isUtc})');
  print('dhuhr: ${prayerTimes.dhuhr} (isUtc: ${prayerTimes.dhuhr.isUtc})');
  print('asr: ${prayerTimes.asr} (isUtc: ${prayerTimes.asr.isUtc})');
  print('maghrib: ${prayerTimes.maghrib} (isUtc: ${prayerTimes.maghrib.isUtc})');
  print('isha: ${prayerTimes.isha} (isUtc: ${prayerTimes.isha.isUtc})');

  print('Asr hour: ${prayerTimes.asr.hour}:${prayerTimes.asr.minute}');
  print('Asr toLocal hour: ${prayerTimes.asr.toLocal().hour}:${prayerTimes.asr.toLocal().minute}');
}
