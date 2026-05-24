import 'package:flutter/material.dart';
import 'hijri_helper.dart';

class SunnahFastingHelper {
  /// Checks if a given Gregorian [date] has a recommended Sunnah fast.
  /// Returns a Map of details if yes, or null otherwise.
  static Map<String, dynamic>? getRecommendationForDate(DateTime date) {
    final dayDate = DateTime(date.year, date.month, date.day);
    final hDate = HijriDate.fromGregorian(dayDate);

    // 1. Dzulhijjah Specific Fasts (Prioritized)
    if (hDate.month == 12) {
      // 10, 11, 12, 13 are Eid Al-Adha and Days of Tashreeq (Fasting is PROHIBITED)
      if (hDate.day >= 10 && hDate.day <= 13) {
        return null;
      }
      
      if (hDate.day == 9) {
        return {
          'key': 'arafah_${hDate.year}',
          'name': 'Puasa Arafah',
          'description': 'Puasa sunnah paling mulia bagi yang tidak melaksanakan ibadah haji.',
          'rationale': 'Rasulullah SAW bersabda: "Puasa hari Arafah, aku berharap kepada Allah akan menghapuskan dosa setahun setelahnya dan setahun sebelumnya." (HR. Muslim no. 1162).',
          'date': dayDate,
          'color': const Color(0xFFFFD700), // Gold
        };
      }
      if (hDate.day == 8) {
        return {
          'key': 'tarwiyah_${hDate.year}',
          'name': 'Puasa Tarwiyah',
          'description': 'Puasa hari kedelapan Dzulhijjah sebelum hari Arafah.',
          'rationale': 'Puasa pada hari-hari awal Dzulhijjah sangat dicintai Allah SWT sebagai bagian dari amal sholeh umum di awal Dzulhijjah.',
          'date': dayDate,
          'color': const Color(0xFFFF5722), // Deep Orange
        };
      }
      if (hDate.day >= 1 && hDate.day <= 7) {
        return {
          'key': 'awal_dzulhijjah_${hDate.year}',
          'name': 'Puasa Awal Dzulhijjah',
          'description': 'Puasa di sembilan hari pertama bulan Dzulhijjah yang penuh berkah.',
          'rationale': 'Rasulullah SAW bersabda: "Tidak ada hari-hari yang amal shalih di dalamnya lebih dicintai Allah daripada sepuluh hari pertama Dzulhijjah." (HR. Bukhari no. 969).',
          'date': dayDate,
          'color': const Color(0xFF4CAF50), // Emerald Green
        };
      }
    }

    // 2. Tasu'a & Asyura (Muharram)
    if (hDate.month == 1) {
      if (hDate.day == 9) {
        return {
          'key': 'tasua_${hDate.year}',
          'name': 'Puasa Tasu\'a',
          'description': 'Puasa sehari sebelum hari Asyura untuk menyelisihi kaum Yahudi.',
          'rationale': 'Rasulullah SAW bersabda: "Sungguh jika aku masih hidup sampai tahun depan, niscaya aku akan berpuasa pada hari kesembilan (Muharram)." (HR. Muslim no. 1134).',
          'date': dayDate,
          'color': const Color(0xFFFFA726), // Orange
        };
      }
      if (hDate.day == 10) {
        return {
          'key': 'asyura_${hDate.year}',
          'name': 'Puasa Asyura',
          'description': 'Puasa yang memiliki keutamaan luar biasa menghapuskan dosa setahun yang lalu.',
          'rationale': 'Rasulullah SAW ditanya tentang puasa hari Asyura, beliau menjawab: "Puasa Asyura dapat menghapuskan dosa setahun yang lalu." (HR. Muslim no. 1162).',
          'date': dayDate,
          'color': const Color(0xFFFFD700), // Gold
        };
      }
    }

    // 3. Nisfu Sya'ban
    if (hDate.month == 8 && hDate.day == 15) {
      return {
        'key': 'nisfu_syaban_${hDate.year}',
        'name': 'Puasa Nisfu Sya\'ban',
        'description': 'Puasa sunnah pertengahan bulan Sya\'ban sebelum memasuki Ramadhan.',
        'rationale': 'Bulan Sya\'ban adalah bulan diangkatnya amal perbuatan kepada Allah. Rasulullah SAW bersabda: "Aku ingin amalku diangkat saat aku dalam keadaan berpuasa." (HR. An-Nasa\'i no. 2357, Shahih).',
        'date': dayDate,
        'color': const Color(0xFF00BCD4), // Cyan
      };
    }

    // 4. Ayyamul Bidh
    List<int> ayyamulBidhDays = [13, 14, 15];
    if (hDate.month == 12) {
      ayyamulBidhDays = [14, 15]; // 13 Dzulhijjah is Tashreeq (prohibited)
    }
    // Fasting during Ramadhan (month 9) is already obligatory, no sunnah ayyamul bidh
    if (hDate.month != 9 && ayyamulBidhDays.contains(hDate.day)) {
      return {
        'key': 'ayyamul_bidh_${hDate.year}_${hDate.month}',
        'name': 'Puasa Ayyamul Bidh',
        'description': 'Puasa tiga hari di tengah bulan Hijriah saat bulan purnama bersinar terang.',
        'rationale': 'Dari Abu Dzarr, Rasulullah SAW bersabda: "Jika engkau ingin berpuasa tiga hari di setiap bulan, maka berpuasalah pada tanggal 13, 14, dan 15." (HR. Tirmidzi no. 761, Hasan). Keutamaannya seperti berpuasa sepanjang tahun.',
        'date': dayDate,
        'color': const Color(0xFF9C27B0), // Purple
      };
    }

    // 5. Senin & Kamis (Weekly)
    // Avoid recommending Monday/Thursday during Ramadhan (month 9)
    if (hDate.month != 9 && (dayDate.weekday == DateTime.monday || dayDate.weekday == DateTime.thursday)) {
      final dayName = dayDate.weekday == DateTime.monday ? 'Senin' : 'Kamis';
      final isMonday = dayDate.weekday == DateTime.monday;
      return {
        'key': 'senin_kamis_${hDate.year}_${hDate.month}',
        'name': 'Puasa $dayName',
        'description': 'Puasa sunnah mingguan yang rutin dilaksanakan oleh Rasulullah SAW.',
        'rationale': 'Rasulullah SAW bersabda: "Amal ibadah disodorkan kepada Allah pada hari Senin dan Kamis. Maka aku menyukai ketika amalku disodorkan, aku dalam keadaan berpuasa." (HR. Tirmidzi no. 747, Shahih).',
        'date': dayDate,
        'color': isMonday ? const Color(0xFF2196F3) : const Color(0xFF009688), // Blue for Monday, Teal for Thursday
      };
    }

    return null;
  }
}
