import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_card.dart';

class Doa {
  final String title;
  final String arabic;
  final String latin;
  final String translation;
  final String? count;
  const Doa({required this.title, required this.arabic, required this.latin, required this.translation, this.count});
}

class DoaCategory {
  final String name;
  final IconData icon;
  final List<Doa> doas;
  const DoaCategory({required this.name, required this.icon, required this.doas});
}

class DoaScreen extends StatefulWidget {
  const DoaScreen({super.key});
  @override
  State<DoaScreen> createState() => _DoaScreenState();
}

class _DoaScreenState extends State<DoaScreen> with TickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  late AnimationController _listController;

  final List<DoaCategory> _categories = [
    const DoaCategory(
      name: 'Niat Puasa',
      icon: Icons.brightness_auto_rounded,
      doas: [
        Doa(
          title: 'Niat Puasa Ramadhan',
          arabic: 'نَوَيْتُ صَوْمَ غَدٍ عَنْ أَدَاءِ فَرْضِ شَهْرِ رَمَضَانَ هَذِهِ السَّنَةِ لِلَّهِ تَعَالَى',
          latin: 'Nawaitu shauma ghadin \'an adaai fardhi syahri Ramadhan hadzihis sanati lillahi ta\'ala',
          translation: 'Saya berniat puasa esok hari untuk menunaikan fardhu bulan Ramadhan tahun ini karena Allah Ta\'ala',
        ),
        Doa(
          title: 'Niat Puasa Qada',
          arabic: 'نَوَيْتُ صَوْمَ غَدٍ عَنْ قَضَاءِ فَرْضِ شَهْرِ رَمَضَانَ الْمَاضِي لِلَّهِ تَعَالَى',
          latin: 'Nawaitu shauma ghadin \'an qadaai fardhi syahri Ramadhan al-madi lillahi ta\'ala',
          translation: 'Saya berniat puasa esok hari untuk mengqadha fardhu bulan Ramadhan yang lalu karena Allah Ta\'ala',
        ),
        Doa(
          title: 'Niat Puasa Senin',
          arabic: 'نَوَيْتُ صَوْمَ يَوْمِ الِاثْنَيْنِ سُنَّةً لِلّٰهِ تَعَالَى',
          latin: 'Nawaitu shauma yaumil itsnaini sunnatan lillahi ta\'ala',
          translation: 'Saya berniat puasa sunnah di hari Senin karena Allah Ta\'ala',
        ),
        Doa(
          title: 'Niat Puasa Kamis',
          arabic: 'نَوَيْتُ صَوْمَ يَوْمِ الْخَمِيْسِ سُنَّةً لِلّٰهِ تَعَالَى',
          latin: 'Nawaitu shauma yaumil khamīsi sunnatan lillahi ta\'ala',
          translation: 'Saya berniat puasa sunnah di hari Kamis karena Allah Ta\'ala',
        ),
        Doa(
          title: 'Niat Puasa Daud',
          arabic: 'نَوَيْتُ صَوْمَ دَاوُدَ سُنَّةً لِلّٰهِ تَعَالَى',
          latin: 'Nawaitu shauma dāwūda sunnatan lillāhi ta\'ālā',
          translation: 'Saya berniat puasa sunnah Daud karena Allah Ta\'ala',
        ),
        Doa(
          title: 'Niat Puasa Arafah',
          arabic: 'نَوَيْتُ صَوْمَ غَدٍ عَنْ أَدَاءِ سُنَّةِ يَوْمِ عَرَفَةَ لِلّٰهِ تَعَالَى',
          latin: 'Nawaitu shauma ghadin \'an adaai sunnati yaumi \'arafata lillahi ta\'ala',
          translation: 'Saya berniat puasa sunnah Arafah karena Allah Ta\'ala',
        ),
        Doa(
          title: 'Niat Berbuka Puasa',
          arabic: 'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوْقُ وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللهُ',
          latin: 'Dzahabaz zhama\'u wabtallatil \'uruqu wa tsabatal ajru in sya Allah',
          translation: 'Telah hilang rasa haus, telah basah urat-urat, dan telah tetap pahala, insya Allah',
        ),
      ],
    ),
    const DoaCategory(
      name: 'Dzikir Pagi',
      icon: Icons.wb_sunny_rounded,
      doas: [
        Doa(
          title: 'Ayat Kursi',
          arabic: 'اللهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ...',
          latin: 'Allāhu lā ilāha illā huwal-ḥayyul-qayyūm...',
          translation: 'Allah, tidak ada tuhan selain Dia. Yang Maha Hidup, yang terus-menerus mengurus (makhluk-Nya)...',
          count: '1x',
        ),
        Doa(
          title: 'Sayyidul Istighfar',
          arabic: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ ، خَلَقْتَنِي وَأَنَا عَبْدُكَ ، وَأَنَا عَلَى عهدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ...',
          latin: 'Allāhumma anta rabbī lā ilāha illā anta, khalaqtanī wa ana \'abduka...',
          translation: 'Ya Allah, Engkau adalah Rabbku, tidak ada ilah yang berhak disembah kecuali Engkau...',
          count: '1x',
        ),
        Doa(
          title: 'Bismillahilladzi la yadhurru',
          arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
          latin: 'Bismillāhillażī lā yaḍurru ma\'asmihī syai\'un fil-arḍi...',
          translation: 'Dengan nama Allah yang bila disebut, segala sesuatu di bumi dan langit tidak akan membahayakan...',
          count: '3x',
        ),
        Doa(
          title: 'Radhitu Billahi Rabba',
          arabic: 'رَضِيْتُ بِاللهِ رَبًّا، وَبِالْإِسْلَامِ دِيْنًا، وَبِمُحَمَّدٍ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا',
          latin: 'Raḍītu billāhi rabban, wa bil-islāmi dīnan, wa bi muḥammadin ṣallallāhu \'alaihi wa sallama nabiyyan',
          translation: 'Aku ridha Allah sebagai Rabb, Islam sebagai agama, dan Muhammad sebagai Nabi',
          count: '3x',
        ),
      ],
    ),
    const DoaCategory(
      name: 'Dzikir Petang',
      icon: Icons.nights_stay_rounded,
      doas: [
        Doa(
          title: 'Ayat Kursi',
          arabic: 'اللهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...',
          latin: 'Allāhu lā ilāha illā huwal-ḥayyul-qayyūm...',
          translation: 'Allah, tidak ada tuhan selain Dia...',
          count: '1x',
        ),
        Doa(
          title: 'A\'idzu bikalimatillahit Tammaat',
          arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
          latin: 'A\'ūżu bikalimātillāhit-tāmmāti min syarri mā khalaq',
          translation: 'Aku berlindung dengan kalimat-kalimat Allah yang sempurna dari kejahatan makhluk yang Dia ciptakan',
          count: '3x',
        ),
      ],
    ),
    const DoaCategory(
      name: 'Sahih & Mustajab',
      icon: Icons.auto_awesome_rounded,
      doas: [
        Doa(
          title: 'Doa Nabi Yunus (Kesulitan)',
          arabic: 'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
          latin: 'Lā ilāha illā anta subḥānaka innī kuntu minaẓ-ẓālimīn',
          translation: 'Tidak ada Tuhan selain Engkau. Maha Suci Engkau, sesungguhnya aku termasuk orang-orang yang zalim',
        ),
        Doa(
          title: 'Doa Sapu Jagad',
          arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
          latin: 'Rabbanā ātinā fid-dunyā ḥasanah wa fil-ākhirati ḥasanah wa qinā \'ażāban-nār',
          translation: 'Wahai Rabb kami, berikanlah kepada kami kebaikan di dunia dan kebaikan di akhirat...',
        ),
        Doa(
          title: 'Doa Kelancaran Urusan',
          arabic: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِنْ لِسَانِي يَفْقَهُوا قَوْلِي',
          latin: 'Rabbisy-syrahli sadri wa yassirli amri...',
          translation: 'Ya Tuhanku, lapangkanlah dadaku, dan mudahkanlah urusanku, dan lepaskanlah kekakuan dari lidahku...',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _listController.forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        const SizedBox(height: 10),
        // Premium Category Carousel
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedCategoryIndex == index;
              final cat = _categories[index];
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCategoryIndex = index);
                  _listController.reset();
                  _listController.forward();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? Theme.of(context).primaryColor.withOpacity(0.15) 
                      : (isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03)),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.5) : (isDark ? Colors.white12 : Colors.black12),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(cat.icon, color: isSelected ? Theme.of(context).primaryColor : (isDark ? Colors.white38 : Colors.black38), size: 32),
                      const SizedBox(height: 12),
                      Text(
                        cat.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: isSelected ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.white38 : Colors.black38),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: FadeTransition(
            opacity: _listController,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              itemCount: _categories[_selectedCategoryIndex].doas.length,
              itemBuilder: (context, index) {
                final doa = _categories[_selectedCategoryIndex].doas[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildDoaCard(doa, isDark),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoaCard(Doa doa, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                doa.title.toUpperCase(),
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              if (doa.count != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black12, borderRadius: BorderRadius.circular(4)),
                  child: Text(doa.count!, style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.black54)),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            doa.arabic,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 24, height: 1.8),
          ),
          const SizedBox(height: 20),
          Text(doa.latin, style: GoogleFonts.inter(fontSize: 13, fontStyle: FontStyle.italic, color: isDark ? Colors.white54 : Colors.black54)),
          Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Divider(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), height: 1)),
          Text(
            doa.translation,
            style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: isDark ? Colors.white70 : Colors.black87),
          ),
        ],
      ),
    );
  }
}