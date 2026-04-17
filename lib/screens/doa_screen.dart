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
  late ScrollController _scrollController;

  static const String ayatKursiArabic = 'اللّٰهُ لَآ اِلٰهَ اِلَّا هُوَ الْحَيُّ الْقَيُّوْمُ ەۚ لَا تَأْخُذُهٗ سِنَةٌ وَّلَا نَوْمٌۗ لَهٗ مَا فِى السَّمٰوٰتِ وَمَا فِى الْاَرْضِۗ مَنْ ذَا الَّذِيْ يَشْفَعُ عِنْدَهٗٓ اِلَّا بِاِذْنِهٖۗ يَعْلَمُ مَا بَيْنَ اَيْدِيْهِمْ وَمَا خَلْفَهُمْۚ وَلَا يُحِيْطُوْنَ بِشَيْءٍ مِّنْ عِلْمِهٖٓ اِلَّا بِاِذْنِهٖۗ وَسِعَ كُرْسِيُّهُ السَّمٰوٰتِ وَالْاَرْضَۚ وَلَا يَـُٔوْدُهٗ حِفْظُهُمَاۚ وَهُوَ الْعَلِيُّ الْعَظِيْمُ';
  static const String ayatKursiLatin = 'Allāhu lā ilāha illā huwal-ḥayyul-qayyūm, lā ta\'khużuhū sinatuw wa lā naum, lahū mā fis-samāwāti wa mā fil-arḍ, man żal-lażī yasyfa\'u \'indahū illā bi żinih, ya\'lamu mā baina aidīhim wa mā khalfahum, wa lā yuḥīṭūna bisyai\'im min \'ilmihī illā bimā syā\', wasi\'a kursiyyuhus-samāwāti wal-arḍ, wa lā ya\'ūduhū ḥifẓuhumā, wa huwal-\'aliyyul-\'aẓīm';
  static const String ayatKursiTranslation = 'Allah, tidak ada tuhan selain Dia. Yang Maha Hidup, yang terus-menerus mengurus (makhluk-Nya), tidak mengantuk dan tidak tidur. Milik-Nya apa yang ada di langit dan apa yang ada di bumi. Tidak ada yang dapat memberi syafaat di sisi-Nya tanpa izin-Nya. Dia mengetahui apa yang di hadapan mereka dan apa yang di belakang mereka, dan mereka tidak mengetahui sesuatu apa pun tentang ilmu-Nya melainkan apa yang Dia kehendaki. Kursi-Nya meliputi langit dan bumi. Dan Dia tidak merasa berat memelihara keduanya, dan Dia Maha Tinggi, Maha Besar.';

  static const String sayyidulIstighfarArabic = 'اَللّٰهُمَّ أَنْتَ رَبِّيْ لَا إِلَهَ إِلَّا أَنْتَ ، خَلَقْتَنِيْ وَأَنَا عَبْدُكَ ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ ، أَعُوْذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ ، أَبُوْءُ لَكَ بِنِعْمَتِكَ عَلَيَّ ، وَأَبُوْءُ بِذَنْبِيْ فَاغْفِرْ لِيْ فَإِنَّهُ لَا يَغْفِرُ الذُّنُوْبَ إِلَّا أَنْتَ';
  static const String sayyidulIstighfarLatin = 'Allāhumma anta rabbī lā ilāha illā anta, khalaqtanī wa ana \'abduka, wa ana \'alā \'ahdika wa wa\'dika mastaṭa\'tu, a\'ūżu bika min syarri mā ṣana\'tu, abū\'u laka bini\'matika \'alayya, wa abū\'u biżanbī fagfir lī fa innahū lā yagfiruż-żunūba illā anta';
  static const String sayyidulIstighfarTranslation = 'Ya Allah, Engkau adalah Rabbku, tidak ada ilah yang berhak disembah kecuali Engkau. Engkau-lah yang menciptakanku. Aku adalah hamba-Mu. Aku akan setia pada perjanjianku dengan-Mu semampuku. Aku berlindung kepada-Mu dari kejelekan yang kuperbuat. Aku mengakui nikmat-Mu kepadaku dan aku mengakui dosaku, oleh karena itu ampunilah aku. Sesungguhnya tiada yang mengampuni dosa kecuali Engkau.';

  final List<DoaCategory> _categories = [
    const DoaCategory(
      name: 'Niat Puasa',
      icon: Icons.brightness_auto_rounded,
      doas: [
        Doa(
          title: 'Niat Puasa Ramadhan',
          arabic: 'نَوَيْتُ صَوْمَ غَدٍ عَنْ أَدَاءِ فَرْضِ شَهْرِ رَمَضَانَ هَذِهِ السَّنَةِ لِلَّهِ تَعَالَى',
          latin: 'Nawaitu shauma ghadin \'an adaai fardhi syahri Ramadhāna hādzihis sanati lillāhi ta\'ālā',
          translation: 'Saya berniat puasa esok hari untuk menunaikan fardhu bulan Ramadhan tahun ini karena Allah Ta\'ala',
        ),
        Doa(
          title: 'Niat Puasa Qada',
          arabic: 'نَوَيْتُ صَوْمَ غَدٍ عَنْ قَضَاءِ فَرْضِ شَهْرِ رَمَضَانَ الْمَاضِي لِلَّهِ تَعَالَى',
          latin: 'Nawaitu shauma ghadin \'an qadā\'i fardhi syahri Ramadhāna al-mādhi lillāhi ta\'ālā',
          translation: 'Saya berniat puasa esok hari untuk mengqadha fardhu bulan Ramadhan yang lalu karena Allah Ta\'ala',
        ),
        Doa(
          title: 'Niat Puasa Kafarah',
          arabic: 'نَوَيْتُ صَوْمَ غَدٍ لِكَفَّارَةِ فَرْضًا لِلّٰهِ تَعَالَى',
          latin: 'Nawaitu shauma ghadin likaffārati fardhan lillāhi ta\'ālā',
          translation: 'Saya berniat puasa esok hari untuk kafarah (penebus dosa/denda) fardhu karena Allah Ta\'ala',
        ),
        Doa(
          title: 'Niat Puasa Senin',
          arabic: 'نَوَيْتُ صَوْمَ يَوْمِ الِاثْنَيْنِ سُنَّةً لِلّٰهِ تَعَالَى',
          latin: 'Nawaitu shauma yaumil itsnaini sunnatan lillāhi ta\'ālā',
          translation: 'Saya berniat puasa sunnah di hari Senin karena Allah Ta\'ala',
        ),
        Doa(
          title: 'Niat Puasa Kamis',
          arabic: 'نَوَيْتُ صَوْمَ يَوْمِ الْخَمِيْسِ سُنَّةً لِلّٰهِ تَعَالَى',
          latin: 'Nawaitu shauma yaumil khamīsi sunnatan lillāhi ta\'ālā',
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
          latin: 'Nawaitu shauma ghadin \'an adā\'i sunnati yaumi \'arafata lillāhi ta\'ālā',
          translation: 'Saya berniat puasa sunnah Arafah karena Allah Ta\'ala',
        ),
        Doa(
          title: 'Niat Berbuka Puasa',
          arabic: 'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوْقُ وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللهُ',
          latin: 'Dzahabaz zhama\'u wabtallatil \'urūqu wa tsabatal ajru in syā Allah',
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
          arabic: ayatKursiArabic,
          latin: ayatKursiLatin,
          translation: ayatKursiTranslation,
          count: '1x',
        ),
        Doa(
          title: 'Surah Al-Ikhlas',
          arabic: 'قُلْ هُوَ اللّٰهُ اَحَدٌۚ اَللّٰهُ الصَّمَدُۚ لَمْ يَلِدْ وَلَمْ يُولَدْۚ وَلَمْ يَكُنْ لَهُ كُفُوًا اَحَدٌ',
          latin: 'Qul huwallāhu aḥad, Allāhuṣ-ṣamad, lam yalid wa lam yūlad, wa lam yakul lahū kufuwan aḥad',
          translation: 'Katakanlah (Muhammad), "Dialah Allah Yang Maha Esa. Allah tempat meminta segala sesuatu. (Allah) tidak beranak dan tidak pula diperanakkan. Dan tidak ada sesuatu yang setara dengan Dia."',
          count: '3x',
        ),
        Doa(
          title: 'Surah Al-Falaq',
          arabic: 'قُلْ اَعُوْذُ بِرَبِّ الْفَلَقِۙ مِنْ شَرِّ مَا خَلَقَۙ وَمِنْ شَرِّ غَاسِقٍ اِذَا وَقَبَۙ وَمِنْ شَرِّ النَّفّٰثٰتِ فِى الْعُقَدِۙ وَمِنْ شَرِّ حَاسِدٍ اِذَا حَسَدَ',
          latin: 'Qul a\'ūżu birabbil-falaq, min syarri mā khalaq, wa min syarri gāsiqin iżā waqab, wa min syarrin-naffāṡāti fil-\'uqad, wa min syarri ḥāsidin iżā ḥasad',
          translation: 'Katakanlah, "Aku berlindung kepada Tuhan yang menguasai subuh (fajar), dari kejahatan (makhluk yang) Dia ciptakan, dan dari kejahatan malam apabila telah gelap gulita, dan dari kejahatan (perempuan-perempuan) penyihir yang meniup pada buhul-buhul (talinya), dan dari kejahatan orang yang dengki apabila dia dengki."',
          count: '3x',
        ),
        Doa(
          title: 'Surah An-Naas',
          arabic: 'قُلْ اَعُوْذُ بِرَبِّ النَّاسِۙ مَلِكِ النَّاسِۙ اِلٰهِ النَّاسِۙ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِۖ الَّذِيْ يُوَسْوِسُ فِيْ صُدُوْرِ النَّاسِۙ مِنَ الْجِنَّةِ وَالنَّاسِ',
          latin: 'Qul a\'ūżu birabbin-nās, malikin-nās, ilāhin-nās, min syarril-waswāsil-khannās, allażī yuwaswisu fī ṣudūrin-nās, minal-jinnati wan-nās',
          translation: 'Katakanlah, "Aku berlindung kepada Tuhannya manusia, Raja manusia, Sembahan manusia, dari kejahatan (bisikan) setan yang bersembunyi, yang membisikkan (kejahatan) ke dalam dada manusia, dari (golongan) jin dan manusia."',
          count: '3x',
        ),
        Doa(
          title: 'Dzikir Pagi (Ashbahna)',
          arabic: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
          latin: 'Aṣbaḥnā wa aṣbaḥal-mulku lillāh, wal-ḥamdu lillāh, lā ilāha illallāhu waḥdahū lā syarīka lah, lahul-mulku wa lahul-ḥamdu wa huwa \'alā kulli syai\'in qadīr',
          translation: 'Kami memasuki waktu pagi dan kerajaan hanya milik Allah, segala puji bagi Allah. Tidak ada ilah yang berhak disembah kecuali Allah semata, tidak ada sekutu bagi-Nya. Bagi-Nya kerajaan dan bagi-Nya pujian. Dia-lah Yang Mahakuasa atas segala sesuatu.',
          count: '1x',
        ),
        Doa(
          title: 'Sayyidul Istighfar',
          arabic: sayyidulIstighfarArabic,
          latin: sayyidulIstighfarLatin,
          translation: sayyidulIstighfarTranslation,
          count: '1x',
        ),
        Doa(
          title: 'Perlindungan dari Bahaya',
          arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
          latin: 'Bismillāhillażī lā yaḍurru ma\'asmihī syai\'un fil-arḍi wa lā fis-samā\'i wa huwas-samī\'ul-\'alīm',
          translation: 'Dengan nama Allah yang bila disebut, segala sesuatu di bumi dan langit tidak akan membahayakan, Dia-lah Yang Maha Mendengar lagi Maha Mengetahui.',
          count: '3x',
        ),
        Doa(
          title: 'Keridhaan kepada Allah',
          arabic: 'رَضِيْتُ بِاللهِ رَبًّا، وَبِالْإِسْلَامِ دِيْنًا، وَبِمُحَمَّدٍ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا',
          latin: 'Raḍītu billāhi rabban, wa bil-islāmi dīnan, wa bi muḥammadin ṣallallāhu \'alaihi wa sallama nabiyyan',
          translation: 'Aku ridha Allah sebagai Rabb, Islam sebagai agama, dan Muhammad sebagai Nabi.',
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
          arabic: ayatKursiArabic,
          latin: ayatKursiLatin,
          translation: ayatKursiTranslation,
          count: '1x',
        ),
        Doa(
          title: 'Surah Al-Ikhlas',
          arabic: 'قُلْ هُوَ اللّٰهُ اَحَدٌۚ اَللّٰهُ الصَّمَدُۚ لَمْ يَلِدْ وَلَمْ يُولَدْۚ وَلَمْ يَكُنْ لَهُ كُفُوًا اَحَدٌ',
          latin: 'Qul huwallāhu aḥad, Allāhuṣ-ṣamad, lam yalid wa lam yūlad, wa lam yakul lahū kufuwan aḥad',
          translation: 'Katakanlah (Muhammad), "Dialah Allah Yang Maha Esa..." (Membaca 3x di sore hari)',
          count: '3x',
        ),
        Doa(
          title: 'Surah Al-Falaq',
          arabic: 'قُلْ اَعُوْذُ بِرَبِّ الْفَلَقِۙ مِنْ شَرِّ مَا خَلَقَۙ وَمِنْ شَرِّ غَاسِقٍ اِذَا وَقَبَۙ وَمِنْ شَرِّ النَّفّٰثٰتِ فِى الْعُقَدِۙ وَمِنْ شَرِّ حَاسِدٍ اِذَا حَسَدَ',
          latin: 'Qul a\'ūżu birabbil-falaq, min syarri mā khalaq, wa min syarri gāsiqin iżā waqab...',
          translation: 'Aku berlindung kepada Tuhan yang menguasai subuh...',
          count: '3x',
        ),
        Doa(
          title: 'Surah An-Naas',
          arabic: 'قُلْ اَعُوْذُ بِرَبِّ النَّاسِۙ مَلِكِ النَّاسِۙ اِلٰهِ النَّاسِۙ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِۖ الَّذِيْ يُوَسْوِسُ فِيْ صُدُوْرِ النَّاسِۙ مِنَ الْجِنَّةِ وَالنَّاسِ',
          latin: 'Qul a\'ūżu birabbin-nās, malikin-nās, ilāhin-nās...',
          translation: 'Aku berlindung kepada Tuhannya manusia...',
          count: '3x',
        ),
        Doa(
          title: 'Dzikir Petang (Amsaina)',
          arabic: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
          latin: 'Amsainā wa amsayal-mulku lillāh, wal-ḥamdu lillāh, lā ilāha illallāhu waḥdahū lā syarīka lah, lahul-mulku wa lahul-ḥamdu wa huwa \'alā kulli syai\'in qadīr',
          translation: 'Kami memasuki waktu petang dan kerajaan hanya milik Allah, segala puji bagi Allah. Tidak ada ilah yang berhak disembah kecuali Allah semata...',
          count: '1x',
        ),
        Doa(
          title: 'Sayyidul Istighfar',
          arabic: sayyidulIstighfarArabic,
          latin: sayyidulIstighfarLatin,
          translation: sayyidulIstighfarTranslation,
          count: '1x',
        ),
        Doa(
          title: 'A\'idzu bikalimatillahit Tammaat',
          arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
          latin: 'A\'ūżu bikalimātillāhit-tāmmāti min syarri mā khalaq',
          translation: 'Aku berlindung dengan kalimat-kalimat Allah yang sempurna dari kejahatan makhluk yang Dia ciptakan.',
          count: '3x',
        ),
      ],
    ),
    const DoaCategory(
      name: 'Setelah Sholat',
      icon: Icons.mosque_rounded,
      doas: [
        Doa(
          title: 'Istighfar',
          arabic: 'أَسْتَغْفِرُ اللهَ',
          latin: 'Astaghfirullāh',
          translation: 'Aku mohon ampun kepada Allah.',
          count: '3x',
        ),
        Doa(
          title: 'Allahumma Antas Salam',
          arabic: 'اَللّٰهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
          latin: 'Allāhumma antas-salām wa minkas-salām tabārakta yā żal-jalāli wal-ikrām',
          translation: 'Ya Allah, Engkau Mahasejahtera dan dari-Mu kesejahteraan. Maha Berkah Engkau, wahai Rabb Pemilik keagungan dan kemuliaan.',
        ),
        Doa(
          title: 'Pujian Tauhid',
          arabic: 'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، اَللّٰهُمَّ لَا مَانِعَ لِمَا أَعْطيتَ وَلَا مُعْطِيَ لِمَا مَنَعْتَ وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ',
          latin: 'Lā ilāha illallāhu waḥdahū lā syarīka lah, lahul-mulku wa lahul-ḥamdu wa huwa \'alā kulli syai\'in qadīr. Allāhumma lā māni\'a limā a\'ṭaita wa lā mu\'ṭiya limā mana\'ta wa lā yanfa\'u żal-jaddi minkal-jadd',
          translation: 'Tiada ilah yang berhak disembah selain Allah semata... Ya Allah, tidak ada yang dapat menghalangi apa yang Engkau berikan, dan tidak ada yang dapat memberi apa yang Engkau halangi, dan tidak bermanfaat kekayaan bagi orang yang memilikinya dari azab-Mu.',
        ),
        Doa(
          title: 'Tasbih',
          arabic: 'سُبْحَانَ اللهِ',
          latin: 'Subḥānallāh',
          translation: 'Maha Suci Allah.',
          count: '33x',
        ),
        Doa(
          title: 'Tahmid',
          arabic: 'الْحَمْدُ لِلَّهِ',
          latin: 'Alḥamdulillāh',
          translation: 'Segala puji bagi Allah.',
          count: '33x',
        ),
        Doa(
          title: 'Takbir',
          arabic: 'اللهُ أَكْبَرُ',
          latin: 'Allāhu akbar',
          translation: 'Allah Maha Besar.',
          count: '33x',
        ),
        Doa(
          title: 'Tahlil Pelengkap 100',
          arabic: 'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
          latin: 'Lā ilāha illallāhu waḥdahū lā syarīka lah, lahul-mulku wa lahul-ḥamdu wa huwa \'alā kulli syai\'in qadīr',
          translation: 'Tiada ilah yang berhak disembah selain Allah semata, tidak ada sekutu bagi-Nya. Bagi-Nya kerajaan dan bagi-Nya pujian. Dia-lah Yang Mahakuasa atas segala sesuatu.',
        ),
      ],
    ),
    const DoaCategory(
      name: 'Sahih & Mustajab',
      icon: Icons.auto_awesome_rounded,
      doas: [
        Doa(
          title: 'Doa Nabi Yunus',
          arabic: 'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
          latin: 'Lā ilāha illā anta subḥānaka innī kuntu minaẓ-ẓālimīn',
          translation: 'Tidak ada Tuhan Selain Engkau. Maha Suci Engkau, sesungguhnya aku termasuk orang-orang yang zalim.',
        ),
        Doa(
          title: 'Doa Sapu Jagad',
          arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
          latin: 'Rabbanā ātinā fid-dunyā ḥasanah wa fil-ākhirati ḥasanah wa qinā \'ażāban-nār',
          translation: 'Wahai Rabb kami, berikanlah kepada kami kebaikan di dunia dan kebaikan di akhirat, dan peliharalah kami dari siksa neraka.',
        ),
        Doa(
          title: 'Doa Kelancaran Urusan',
          arabic: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِنْ لِسَانِي يَفْقَهُوا قَوْلِي',
          latin: 'Rabbisy-syrah lī ṣadrī wa yassir lī amrī waḥlul \'uqdatam mil lisānī yafqahū qaulī',
          translation: 'Ya Tuhanku, lapangkanlah dadaku, mudahkanlah urusanku, dan lepaskanlah kekakuan dari lidahku agar mereka mengerti perkataanku.',
        ),
        Doa(
          title: 'Doa Ketetapan Hati',
          arabic: 'يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ',
          latin: 'Yā muqallibal-qulūbi tsabbit qalbī \'alā dīnik',
          translation: 'Wahai Dzat yang membolak-balikkan hati, tetapkanlah hatiku di atas agama-Mu.',
        ),
        Doa(
          title: 'Doa Mohon Perlindungan 4 Perkara',
          arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ جَهَنَّمَ ، وَمِنْ عَذَابِ الْقَبْرِ ، وَمِنْ فِتْنَةِ الْمَحْيَا وَالْمَمَاتِ ، وَمِنْ شَرِّ فِتْنَةِ الْمَسِيحِ الدَّجَّالِ',
          latin: 'Allāhumma innī a\'ūżu bika min \'ażābi jahannam, wa min \'ażābil-qabr, wa min fitnatil-maḥyā wal-mamāt, wa min syarri fitnatil-masīḥid-dajjāl',
          translation: 'Ya Allah, sesungguhnya aku berlindung kepada-Mu dari azab neraka Jahannam, dari azab kubur, dari fitnah kehidupan dan kematian, dan dari buruknya fitnah Al-Masih Ad-Dajjal.',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _scrollController = ScrollController();
    _listController.forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        const SizedBox(height: 10),
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
                   if (_selectedCategoryIndex != index) {
                    setState(() => _selectedCategoryIndex = index);
                    _listController.reset();
                    _listController.forward();
                    // Scroll to top automatically
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  }
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
                          fontSize: 8,
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
              controller: _scrollController,
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
              Expanded(
                child: Text(
                  doa.title.toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: Theme.of(context).primaryColor,
                  ),
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
          SizedBox(
            width: double.infinity,
            child: Text(
              doa.arabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiri(fontSize: 26, height: 1.8),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            doa.latin, 
            style: GoogleFonts.inter(
              fontSize: 13, 
              fontStyle: FontStyle.italic, 
              color: isDark ? Colors.white54 : Colors.black54,
              height: 1.4,
            )
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20), 
            child: Divider(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), height: 1)
          ),
          Text(
            doa.translation,
            style: GoogleFonts.inter(
              fontSize: 13, 
              height: 1.6, 
              color: isDark ? Colors.white70 : Colors.black87
            ),
          ),
        ],
      ),
    );
  }
}