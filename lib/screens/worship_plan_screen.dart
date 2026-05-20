import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/glass_card.dart';

class WorshipPlanScreen extends StatefulWidget {
  final int hijriMonth;
  final String monthName;

  const WorshipPlanScreen({
    super.key,
    required this.hijriMonth,
    required this.monthName,
  });

  @override
  State<WorshipPlanScreen> createState() => _WorshipPlanScreenState();
}

class _WorshipPlanScreenState extends State<WorshipPlanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<bool> _checklistStates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadChecklistStates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Get checklist items based on month
  List<String> get _checklistItems {
    switch (widget.hijriMonth) {
      case 1: // Muharram
        return [
          'Melakukan Puasa Tasu\'a pada tanggal 9 Muharram.',
          'Melakukan Puasa Asyura pada tanggal 10 Muharram.',
          'Memperbanyak Puasa Sunnah mutlak selama bulan Muharram.',
          'Membaca doa awal & akhir tahun Hijriah.',
          'Menghindari kezaliman, pertikaian, dan maksiat secara ekstra.',
          'Memperbanyak bersedekah & menyantuni anak yatim pada hari Asyura.',
          'Melakukan taubat nasuha untuk memulai lembaran baru.',
        ];
      case 7: // Rajab
        return [
          'Memperbanyak membaca Istighfar & memohon ampunan Allah.',
          'Melakukan Puasa Sunnah (Senin-Kamis & Ayyamul Bidh).',
          'Memperbanyak Shalat Sunnah rawatib, tahajjud, dan dhuha.',
          'Melakukan sedekah subuh secara konsisten.',
          'Meningkatkan tilawah Al-Qur\'an minimal 1 juz setiap hari.',
          'Menjaga lisan dari ghibah, dusta, dan perdebatan.',
          'Mempersiapkan target rohani & fisik menyambut Ramadhan.',
        ];
      case 11: // Dzulqa'dah
        return [
          'Membaca & merenungkan Al-Qur\'an sebagai santapan rohani harian.',
          'Melakukan Puasa Sunnah Ayyamul Bidh (13, 14, 15 Dzulqa\'dah).',
          'Memperbanyak doa memohon kelancaran ibadah haji bagi umat Islam.',
          'Melatih keikhlasan, menjauhi kemarahan, dan menjaga damai hati.',
          'Menghidupkan malam dengan Qiyamul Lail (Tahajjud & Witir).',
          'Meningkatkan sedekah jariyah secara berkala.',
          'Membaca shalawat kepada Rasulullah SAW minimal 100x setiap hari.',
        ];
      case 12: // Dzulhijjah
        return [
          'Menghidupkan zikir (tahlil, takbir, tahmid) di 10 hari pertama.',
          'Melakukan Puasa Sunnah 1-9 Dzulhijjah (terutama Tarwiyah & Arafah).',
          'Menyiapkan kurban terbaik & menyembelihnya setelah shalat Id.',
          'Melaksanakan Shalat Idul Adha bersama keluarga di masjid/lapangan.',
          'Tidak memotong kuku & rambut jika berkurban sejak masuk 1 Dzulhijjah.',
          'Memperbanyak doa di hari Arafah (sebaik-baik doa).',
          'Menghindari puasa di Hari Idul Adha & Hari Tasyrik (11, 12, 13 Dzulhijjah).',
        ];
      default:
        return [];
    }
  }

  // Get Dalil & Hadits based on month
  List<Map<String, String>> get _dalilItems {
    switch (widget.hijriMonth) {
      case 1: // Muharram
        return [
          {
            'title': 'Keutamaan Puasa Muharram',
            'arabic': 'أَفْضَلُ الصِّيَامِ بَعْدَ رَمَضَانَ شَهْرُ اللَّهِ الْمُحَرَّمُ',
            'translation': '"Puasa yang paling utama setelah Ramadhan adalah puasa pada bulan Allah (yaitu) Muharram."',
            'reference': 'HR. Muslim no. 1163',
          },
          {
            'title': 'Penghapusan Dosa Setahun Lalu',
            'arabic': 'صِيَامُ يَوْمِ عَاشُورَاءَ أَحْتَسِبُ عَلَى اللَّهِ أَنْ يُكَفِّرَ السَّنَةَ الَّتِي قَبْلَهُ',
            'translation': '"Puasa hari Asyura (10 Muharram), aku berharap kepada Allah akan menghapuskan dosa setahun yang lalu."',
            'reference': 'HR. Muslim no. 1162',
          },
          {
            'title': 'Larangan Menzalimi Diri',
            'arabic': 'فَلَا تَظْلِمُوا فِيهِنَّ أَنْفُسَكُمْ',
            'translation': '"Maka janganlah kamu menzalimi dirimu sendiri dalam (bulan yang empat) itu..."',
            'reference': 'QS. At-Taubah: 36',
          },
        ];
      case 7: // Rajab
        return [
          {
            'title': 'Bulan Rajab di Antara Bulan Haram',
            'arabic': 'إِنَّ الزَّمَانَ قَدِ اسْتَدَارَ كَهَيْئَتِهِ... مِنْهَا أَرْبَعَةٌ حُرُمٌ ثَلَاثٌ مُتَوَالِيَاتٌ... وَرَجَبُ مُضَرَ الَّذِي بَيْنَ جُمَادَى وَشَعْبَانَ',
            'translation': '"Sesungguhnya zaman itu berputar seperti keadaannya... di antaranya ada empat bulan haram; tiga berurutan (Dzulqa\'dah, Dzulhijjah, Muharram) dan Rajab Mudhar yang terletak di antara Jumada dan Sya\'ban."',
            'reference': 'HR. Bukhari no. 4662 & Muslim no. 1679',
          },
          {
            'title': 'Filosofi Bulan Rajab',
            'arabic': 'شَهْرُ رَجَبٍ شَهْرُ الزَّرْعِ وَشَهْرُ شَعْبَانَ شَهْرُ السَّقْيِ وَشَهْرُ رَمَضَانَ شَهْرُ الْحَصَادِ',
            'translation': '"Bulan Rajab adalah bulan menanam, Sya\'ban adalah bulan menyiram, dan Ramadhan adalah bulan memanen hasil."',
            'reference': 'Abu Bakar al-Balkhi (Lathaiful Ma\'arif)',
          },
          {
            'title': 'Larangan Berbuat Zalim',
            'arabic': 'إِنَّ الذُّنُوبَ فِي الْأَشْهُرِ الْحُرُمِ أَعْظَمُ خَطِيئَةً وَوِزْرًا',
            'translation': '"Sesungguhnya dosa di bulan-bulan haram dilipatgandakan besarnya keburukan dan bebannya."',
            'reference': 'Tafsir Qatadah (Tafsir Ibnu Katsir)',
          },
        ];
      case 11: // Dzulqa'dah
        return [
          {
            'title': 'Umrah Rasulullah di Bulan Dzulqa\'dah',
            'arabic': 'اعْتَمَرَ رَسُولُ اللَّهِ صلى الله عليه وسلم أَرْبَعَ عُمْرَاتٍ كُلُّهُنَّ فِي ذِي الْقَعْدَةِ',
            'translation': '"Rasulullah SAW melakukan umrah sebanyak empat kali, semuanya pada bulan Dzulqa\'dah..."',
            'reference': 'HR. Bukhari no. 1780 & Muslim no. 1253',
          },
          {
            'title': 'Bulan Tenang dan Mulia',
            'arabic': 'وَذُو الْقَعْدَةِ لِقُعُودِهِمْ فِيهِ عَنِ الْقِتَالِ وَالتَّرْحَالِ',
            'translation': '"Dinamakan Dzulqa\'dah karena orang-orang Arab dahulu menahan diri (duduk) di bulan ini dari peperangan dan perjalanan."',
            'reference': 'Tafsir Ibnu Katsir',
          },
        ];
      case 12: // Dzulhijjah
        return [
          {
            'title': 'Keagungan 10 Hari Pertama',
            'arabic': 'مَا مِنْ أَيَّامٍ الْعَمَلُ الصَّالِحُ فِيهَا أَحَبُّ إِلَى اللَّهِ مِنْ هَذِهِ الْأَيَّامِ',
            'translation': '"Tidak ada hari-hari di mana amal shalih di dalamnya lebih dicintai oleh Allah daripada sepuluh hari pertama Dzulhijjah ini."',
            'reference': 'HR. Bukhari no. 969',
          },
          {
            'title': 'Kemuliaan Puasa Arafah',
            'arabic': 'صِيَامُ يَوْمِ عَرَفَةَ أَحْتَسِبُ عَلَى اللَّهِ أَنْ يُكَفِّرَ السَّنَةَ الَّتِي بَعْدَهُ وَالسَّنَةَ الَّتِي قَبْلَهُ',
            'translation': '"Puasa hari Arafah (9 Dzulhijjah), aku berharap kepada Allah akan menghapuskan dosa setahun setelahnya dan setahun sebelumnya."',
            'reference': 'HR. Muslim no. 1162',
          },
          {
            'title': 'Anjuran Memperbanyak Zikir',
            'arabic': 'فَأَكْثِرُوا فِيهِنَّ مِنَ التَّسْبِيحِ وَالتَّحْمِيدِ وَالتَّكْبِيرِ وَالتَّهْلِيلِ',
            'translation': '"Maka perbanyaklah bertasbih, bertahmid, bertakbir, dan bertahlil di hari-hari tersebut."',
            'reference': 'HR. Ahmad (Hadits Shahih)',
          },
        ];
      default:
        return [];
    }
  }

  Future<void> _loadChecklistStates() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsCount = _checklistItems.length;
    
    setState(() {
      _checklistStates.clear();
      for (int i = 0; i < itemsCount; i++) {
        final val = prefs.getBool('worship_${widget.hijriMonth}_$i') ?? false;
        _checklistStates.add(val);
      }
      _isLoading = false;
    });
  }

  Future<void> _toggleChecklistItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final currentVal = _checklistStates[index];
    
    setState(() {
      _checklistStates[index] = !currentVal;
    });
    
    await prefs.setBool('worship_${widget.hijriMonth}_$index', !currentVal);

    // Calculate if 100% completed
    if (_checklistStates.every((element) => element)) {
      _showCompletionCelebration();
    }
  }

  void _showCompletionCelebration() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Celebration',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, a1, a2) => Container(),
      transitionBuilder: (context, a1, a2, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return ScaleTransition(
          scale: CurvedAnimation(parent: a1, curve: Curves.elasticOut),
          child: AlertDialog(
            backgroundColor: isDark ? const Color(0xFF042A36) : const Color(0xFFEBF6F0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 1.5),
            ),
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.stars_rounded, size: 50, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 16),
                Text(
                  'Masyallah! 🎉',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            content: Text(
              'Anda telah menyelesaikan seluruh rencana amalan terbaik di bulan ${widget.monthName}. Semoga Allah menerima seluruh ketaatan dan melipatgandakan pahala Anda!',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: isDark ? const Color(0xFF02161D) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Aamiin Yaa Rabbal \'Aalamiin',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double get _completionPercent {
    if (_checklistStates.isEmpty) return 0.0;
    int completedCount = _checklistStates.where((c) => c).length;
    return completedCount / _checklistStates.length;
  }

  int get _completedCount => _checklistStates.where((c) => c).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;

    return Scaffold(
      body: Stack(
        children: [
          // Background celestial gradient or theme surface
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        colors: [Color(0xFF02161D), Color(0xFF042B37)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFF8FCF9), Color(0xFFEEF5F1)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
              ),
            ),
          ),
          
          // Header / Custom App Bar
          SafeArea(
            child: Column(
              children: [
                // Top Custom Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AMALAN TERBAIK',
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: primaryColor,
                              ),
                            ),
                            Text(
                              'Bulan ${widget.monthName}',
                              style: GoogleFonts.manrope(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),

                // Top Progress Card
                _isLoading
                    ? const SizedBox(height: 100)
                    : Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: GlassCard(
                          isAsymmetric: false,
                          padding: const EdgeInsets.all(20),
                          margin: EdgeInsets.zero,
                          borderRadius: 24,
                          child: Row(
                            children: [
                              // Radial Progress ring
                              SizedBox(
                                height: 70,
                                width: 70,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: _completionPercent,
                                      strokeWidth: 8,
                                      backgroundColor: primaryColor.withOpacity(0.12),
                                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                    ),
                                    Text(
                                      '${(_completionPercent * 100).toInt()}%',
                                      style: GoogleFonts.manrope(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Checklist numbers text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rencana Ibadah Anda',
                                      style: GoogleFonts.manrope(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$_completedCount dari ${_checklistItems.length} amalan telah selesai dilakukan.',
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        color: subColor,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                const SizedBox(height: 16),

                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isDark
                          ? [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: isDark ? const Color(0xFF02161D) : Colors.white,
                    unselectedLabelColor: subColor,
                    labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
                    unselectedLabelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 12),
                    tabs: const [
                      Tab(text: 'HADITS & DALIL'),
                      Tab(text: 'RENCANA AMALAN'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Tab Contents
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            // Hadits & Dalil Tab
                            _buildDalilTab(textColor, subColor, isDark),
                            
                            // Amalan Checklist Tab
                            _buildChecklistTab(textColor, subColor, primaryColor, isDark),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDalilTab(Color textColor, Color subColor, bool isDark) {
    final dalils = _dalilItems;
    if (dalils.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada dalil khusus untuk bulan ini.',
          style: TextStyle(color: subColor),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      itemCount: dalils.length,
      itemBuilder: (context, index) {
        final dalil = dalils[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: GlassCard(
            isAsymmetric: false,
            padding: const EdgeInsets.all(20),
            margin: EdgeInsets.zero,
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dalil Title
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        dalil['title'] ?? '',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const Divider(height: 24, thickness: 0.5),

                // Arabic Script if any
                if (dalil['arabic'] != null && dalil['arabic']!.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      dalil['arabic'] ?? '',
                      style: GoogleFonts.amiri(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Translation
                Text(
                  dalil['translation'] ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: textColor.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 12),

                // Reference / Sanad
                Text(
                  dalil['reference'] ?? '',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.secondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChecklistTab(Color textColor, Color subColor, Color primaryColor, bool isDark) {
    final items = _checklistItems;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isChecked = _checklistStates[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _toggleChecklistItem(index),
            borderRadius: BorderRadius.circular(20),
            child: GlassCard(
              isAsymmetric: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              margin: EdgeInsets.zero,
              borderRadius: 20,
              child: Row(
                children: [
                  // Animated custom checkbox
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      color: isChecked ? primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isChecked ? primaryColor : subColor.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: isChecked
                        ? Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: isDark ? const Color(0xFF02161D) : Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Amalan text
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: isChecked ? FontWeight.w600 : FontWeight.w500,
                        color: isChecked ? textColor.withOpacity(0.5) : textColor,
                        decoration: isChecked ? TextDecoration.lineThrough : null,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
