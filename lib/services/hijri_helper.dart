class HijriDate {
  final int year;
  final int month;
  final int day;

  HijriDate(this.year, this.month, this.day);

  static const List<String> monthNames = [
    'Muharram', 'Safar', 'Rabi\'ul Awal', 'Rabi\'ul Akhir',
    'Jumadil Awal', 'Jumadil Akhir', 'Rajab', 'Sya\'ban',
    'Ramadhan', 'Syawal', 'Dzulqa\'dah', 'Dzulhijjah'
  ];

  String get monthName => monthNames[month - 1];

  bool get isSacredMonth => month == 1 || month == 7 || month == 11 || month == 12;

  String get sacredMonthTitle {
    switch (month) {
      case 1:
        return 'MUHARRAM';
      case 7:
        return 'RAJAB';
      case 11:
        return 'DZULQA\'DAH';
      case 12:
        return 'DZULHIJJAH';
      default:
        return '';
    }
  }

  String get sacredMonthDescription {
    switch (month) {
      case 1:
        return 'Awal Tahun Baru Islam. Hindari perbuatan maksiat, perbanyak puasa sunnah terutama Asyura (10 Muharram) dan Tasu\'a (9 Muharram).';
      case 7:
        return 'Terletak di antara Jumadil Akhir dan Sya\'ban. Bulan menanam kebajikan, perbanyak istighfar dan hindari kezaliman terhadap diri sendiri.';
      case 11:
        return 'Bulan persiapan pelaksanaan ibadah haji. Bulan yang tenang, mulailah mempersiapkan rohani dan jauhi pertikaian.';
      case 12:
        return 'Bulan ibadah haji dan kurban. Sangat dianjurkan meningkatkan amal shalih pada 10 hari pertama, puasa Arafah (9 Dzulhijjah), dan berzikir.';
      default:
        return '';
    }
  }

  List<String> get sacredMonthQuotes {
    switch (month) {
      case 1: // Muharram
        return [
          '"Puasa yang paling utama setelah Ramadhan adalah puasa pada bulan Allah (yaitu) Muharram." - HR. Muslim',
          '"Puasa hari Asyura (10 Muharram), aku berharap kepada Allah akan menghapuskan dosa setahun yang lalu." - HR. Muslim',
          '"Janganlah kamu menzalimi dirimu sendiri dalam (bulan yang empat) itu..." - QS. At-Taubah: 36',
          '"Di bulan Muharram ini, sebaiknya kita memperbanyak puasa sunnah dan menghindari perselisihan." - Nasihat Ulama',
        ];
      case 7: // Rajab
        return [
          '"Janganlah kamu menzalimi dirimu dalam (bulan yang empat) itu..." - QS. At-Taubah: 36 (Bulan Rajab termasuk di dalamnya)',
          '"Bulan Rajab adalah bulan menanam, Sya\'ban menyiram, dan Ramadhan memanen hasil." - Abu Bakar al-Balkhi',
          '"Di bulan Rajab ini, perbanyaklah istighfar dan taubat nasuha sebagai persiapan menyambut Ramadhan." - Nasihat Ulama',
          '"Dosa maksiat dan pahala ketaatan dilipatgandakan nilainya di bulan-bulan suci, termasuk Rajab." - Tafsir Ibnu Katsir',
        ];
      case 11: // Dzulqa'dah
        return [
          '"(Musim) haji itu pada bulan-bulan yang telah dimaklumi..." - QS. Al-Baqarah: 197 (Dzulqa\'dah termasuk bulan haji)',
          '"Rasulullah SAW melakukan umrah sebanyak empat kali, semuanya pada bulan Dzulqa\'dah." - HR. Bukhari',
          '"Dzulqa\'dah adalah pintu masuk bulan-bulan suci berurutan. Perbanyaklah ibadah dan persiapan batin." - Nasihat Ulama',
          '"Di antara empat bulan haram... yaitu tiga berurutan: Dzulqa\'dah, Dzulhijjah, Muharram." - HR. Bukhari',
        ];
      case 12: // Dzulhijjah
        return [
          '"Tidak ada hari-hari yang amal shalih di dalamnya lebih dicintai Allah daripada sepuluh hari pertama Dzulhijjah." - HR. Bukhari',
          '"Demi fajar, dan malam yang sepuluh." - QS. Al-Fajr: 1-2 (Menunjukkan kemuliaan 10 hari pertama Dzulhijjah)',
          '"Puasa Arafah (9 Dzulhijjah) dapat menghapuskan dosa setahun yang lalu dan setahun yang akan datang." - HR. Muslim',
          '"Sebaik-baik doa adalah doa pada hari Arafah." - HR. Tirmidzi',
          '"Perbanyaklah bertasbih, bertahmid, bertakbir, dan bertahlil di 10 hari pertama Dzulhijjah." - HR. Ahmad',
        ];
      default:
        return [];
    }
  }

  /// Calculates Hijri Date from a Gregorian DateTime using the Kuwaiti Algorithm
  /// (Default adjustment set to -1 to align perfectly with Southeast Asian moon sightings)
  factory HijriDate.fromGregorian(DateTime date, {int adjustment = -1}) {
    DateTime adjustedDate = date.add(Duration(days: adjustment));
    
    int wjd;
    int y = adjustedDate.year;
    int m = adjustedDate.month;
    int d = adjustedDate.day;

    if (y > 1582 || (y == 1582 && m > 10) || (y == 1582 && m == 10 && d >= 15)) {
      int a = ((14 - m) / 12).floor();
      y = y + 4800 - a;
      m = m + 12 * a - 3;
      wjd = d + ((153 * m + 2) / 5).floor() + 365 * y + (y / 4).floor() - (y / 100).floor() + (y / 400).floor() - 32045;
    } else {
      int a = ((14 - m) / 12).floor();
      y = y + 4800 - a;
      m = m + 12 * a - 3;
      wjd = d + ((153 * m + 2) / 5).floor() + 365 * y + (y / 4).floor() - 32083;
    }

    double epoch = 1948439.5; // Friday 16 July 622 AD
    double dDays = wjd - epoch + 0.5;

    int cyc = (dDays / 10631).floor();
    int r = (dDays - cyc * 10631).floor();
    int iy = cyc * 30 + 1;
    
    // Leap years in 30-year cycle
    const List<int> leapYears = [2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29];
    
    while (true) {
      bool isLeap = leapYears.contains((iy - 1) % 30 + 1);
      int daysInYear = isLeap ? 355 : 354;
      if (r < daysInYear) break;
      r -= daysInYear;
      iy++;
    }

    int im = 1;
    while (true) {
      int daysInMonth;
      if (im == 12) {
        bool isLeap = leapYears.contains((iy - 1) % 30 + 1);
        daysInMonth = isLeap ? 30 : 29;
      } else {
        daysInMonth = (im % 2 == 1) ? 30 : 29;
      }
      if (r < daysInMonth) break;
      r -= daysInMonth;
      im++;
    }

    int id = r + 1;

    return HijriDate(iy, im, id);
  }

  static Map<int, DateTime> getGregorianDatesForHijriMonth(int hijriYear, int hijriMonth, {int adjustment = -1}) {
    Map<int, DateTime> map = {};
    DateTime today = DateTime.now();
    for (int i = -35; i <= 35; i++) {
      DateTime candidate = today.add(Duration(days: i));
      HijriDate h = HijriDate.fromGregorian(candidate, adjustment: adjustment);
      if (h.year == hijriYear && h.month == hijriMonth) {
        map[h.day] = DateTime(candidate.year, candidate.month, candidate.day);
      }
    }
    return map;
  }

  @override
  String toString() {
    return "$day $monthName $year H";
  }
}
