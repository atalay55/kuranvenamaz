import 'httpcontroller.dart';

class ContentItem {
  final String title;
  final String arabic;
  final String turkish;
  final String source;

  const ContentItem({
    required this.title,
    required this.arabic,
    required this.turkish,
    required this.source,
  });
}

class ContentData {
  static const List<ContentItem> ayetler = [
    ContentItem(
      title: "Günün Ayeti",
      arabic: "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
      turkish: "Şüphesiz zorlukla beraber bir kolaylık vardır.",
      source: "İnşirah Sûresi, 6. Âyet",
    ),
    ContentItem(
      title: "Günün Ayeti",
      arabic: "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ",
      turkish: "Bilin ki, kalpler ancak Allah'ı anmakla huzur bulur.",
      source: "Ra'd Sûresi, 28. Âyet",
    ),
    ContentItem(
      title: "Günün Ayeti",
      arabic: "وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ",
      turkish: "Kullarım sana beni sorduğunda söyle ki: Ben çok yakınım.",
      source: "Bakara Sûresi, 186. Âyet",
    ),
    ContentItem(
      title: "Günün Ayeti",
      arabic: "وَقُل رَّبِّ زِدْنِي عِلْمًا",
      turkish: "De ki: Rabbim, ilmimi artır!",
      source: "Tâhâ Sûresi, 114. Âyet",
    ),
    ContentItem(
      title: "Günün Ayeti",
      arabic: "وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ",
      turkish: "Kim Allah'a tevekkül ederse, O kendisine yeter.",
      source: "Talâk Sûresi, 3. Âyet",
    ),
  ];

  static const List<ContentItem> hadisler = [
    ContentItem(
      title: "Günün Hadisi",
      arabic: "خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ",
      turkish: "Sizin en hayırlınız, Kur'an'ı öğrenen ve öğreteninizdir.",
      source: "Buhârî, Fezâilü'l-Kur'ân 21",
    ),
    ContentItem(
      title: "Günün Hadisi",
      arabic: "إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ",
      turkish: "Ameller ancak niyetlere göredir.",
      source: "Buhârî, Bed'ü'l-Vahy 1",
    ),
    ContentItem(
      title: "Günün Hadisi",
      arabic: "الدُّعَاءُ هُوَ الْعِبَادَةُ",
      turkish: "Dua, ibadetin özüdür.",
      source: "Tirmizî, Deavât 1",
    ),
    ContentItem(
      title: "Günün Hadisi",
      arabic: "الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ",
      turkish: "Müslüman, elinden ve dilinden diğer Müslümanların güvende olduğu kimsedir.",
      source: "Buhârî, Îmân 4",
    ),
    ContentItem(
      title: "Günün Hadisi",
      arabic: "تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ لَكَ صَدَقَةٌ",
      turkish: "Din kardeşine tebessüm etmen senin için bir sadakadır.",
      source: "Tirmizî, Birr 36",
    ),
  ];

  static const List<ContentItem> dualar = [
    ContentItem(
      title: "Günün Duası",
      arabic: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
      turkish: "Rabbimiz! Bize dünyada da iyilik ver, ahirette de iyilik ver ve bizi ateş azabından koru.",
      source: "Bakara Sûresi, 201. Âyet",
    ),
    ContentItem(
      title: "Günün Duası",
      arabic: "رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي",
      turkish: "Rabbim! Göğsümü ferahlat, işimi bana kolaylaştır.",
      source: "Tâhâ Sûresi, 25-26. Âyetler",
    ),
    ContentItem(
      title: "Günün Duası",
      arabic: "رَبَّنَا لاَ تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً",
      turkish: "Rabbimiz! Bizi hidayete erdirdikten sonra kalplerimizi eğriltme. Bize katından bir rahmet bağışla.",
      source: "Âl-i İmrân Sûresi, 8. Âyet",
    ),
    ContentItem(
      title: "Günün Duası",
      arabic: "اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ",
      turkish: "Allah'ım! Seni anıp zikretmek, sana şükretmek ve sana güzelce ibadet etmek için bana yardım et.",
      source: "Ebu Davud, Vitir 26",
    ),
  ];

  static ContentItem getRandomAyet() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return ayetler[dayOfYear % ayetler.length];
  }

  static Future<ContentItem> fetchLiveAyet([int? ayahNumber]) async {
    try {
      final diyanetData = await HttpController().fetchDiyanetAyet(ayahNumber);
      if (diyanetData != null) {
        return ContentItem(
          title: "Günün Ayeti (Diyanet)",
          arabic: diyanetData['arabic'] ?? '',
          turkish: diyanetData['turkish'] ?? '',
          source: diyanetData['source'] ?? '',
        );
      }
    } catch (_) {}
    return getRandomAyet();
  }

  static ContentItem getRandomHadis() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return hadisler[dayOfYear % hadisler.length];
  }

  static ContentItem getRandomDua() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return dualar[dayOfYear % dualar.length];
  }
}
