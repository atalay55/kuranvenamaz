import 'app_translations.dart';
import 'httpcontroller.dart';

class ContentItem {
  final String title;
  final String arabic;
  final String turkish;
  final String? english;
  final String? german;
  final String source;
  final String? sourceEn;
  final String? sourceDe;

  const ContentItem({
    required this.title,
    required this.arabic,
    required this.turkish,
    this.english,
    this.german,
    required this.source,
    this.sourceEn,
    this.sourceDe,
  });

  String getText([String? langCode]) {
    final lang = langCode ?? AppTranslations.currentLanguageCode;
    if (lang == 'de' && german != null && german!.isNotEmpty) {
      return german!;
    }
    if (lang == 'en' && english != null && english!.isNotEmpty) {
      return english!;
    }
    return turkish;
  }

  String getSource([String? langCode]) {
    final lang = langCode ?? AppTranslations.currentLanguageCode;
    if (lang == 'de' && sourceDe != null && sourceDe!.isNotEmpty) {
      return sourceDe!;
    }
    if (lang == 'en' && sourceEn != null && sourceEn!.isNotEmpty) {
      return sourceEn!;
    }
    return source;
  }
}

class ContentData {
  static const List<ContentItem> ayetler = [
    ContentItem(
      title: "Günün Ayeti",
      arabic: "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
      turkish: "Şüphesiz zorlukla beraber bir kolaylık vardır.",
      english: "Indeed, with hardship [will be] ease.",
      german: "Wahrlich, mit der Erschwernis ist Erleichterung.",
      source: "İnşirah Sûresi, 6. Âyet",
      sourceEn: "Surah Ash-Sharh, Ayah 6",
      sourceDe: "Sure Al-Inschirah, Vers 6",
    ),
    ContentItem(
      title: "Günün Ayeti",
      arabic: "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ",
      turkish: "Bilin ki, kalpler ancak Allah'ı anmakla huzur bulur.",
      english: "Unquestionably, by the remembrance of Allah hearts are assured.",
      german: "Wahrlich, im Gedenken Allahs finden die Herzen Ruhe.",
      source: "Ra'd Sûresi, 28. Âyet",
      sourceEn: "Surah Ar-Ra'd, Ayah 28",
      sourceDe: "Sure Ar-Ra'd, Vers 28",
    ),
    ContentItem(
      title: "Günün Ayeti",
      arabic: "وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ",
      turkish: "Kullarım sana beni sorduğunda söyle ki: Ben çok yakınım.",
      english: "And when My servants ask you concerning Me - indeed I am near.",
      german: "Und wenn Meine Diener dich nach Mir fragen, siehe, Ich bin nahe.",
      source: "Bakara Sûresi, 186. Âyet",
      sourceEn: "Surah Al-Baqarah, Ayah 186",
      sourceDe: "Sure Al-Baqara, Vers 186",
    ),
    ContentItem(
      title: "Günün Ayeti",
      arabic: "وَقُل رَّبِّ زِدْنِي عِلْمًا",
      turkish: "De ki: Rabbim, ilmimi artır!",
      english: "And say: My Lord, increase me in knowledge.",
      german: "Und sprich: Mein Herr, vermehre mein Wissen!",
      source: "Tâhâ Sûresi, 114. Âyet",
      sourceEn: "Surah Ta-Ha, Ayah 114",
      sourceDe: "Sure Ta-Ha, Vers 114",
    ),
    ContentItem(
      title: "Günün Ayeti",
      arabic: "وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ",
      turkish: "Kim Allah'a tevekkül ederse, O kendisine yeter.",
      english: "And whoever relies upon Allah - then He is sufficient for him.",
      german: "Und wer auf Allah vertraut, dem ist Er Genüge.",
      source: "Talâk Sûresi, 3. Âyet",
      sourceEn: "Surah At-Talaq, Ayah 3",
      sourceDe: "Sure At-Talaq, Vers 3",
    ),
  ];

  static const List<ContentItem> hadisler = [
    ContentItem(
      title: "Günün Hadisi",
      arabic: "خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ",
      turkish: "Sizin en hayırlınız, Kur'an'ı öğrenen ve öğreteninizdir.",
      english: "The best among you are those who learn the Qur'an and teach it.",
      german: "Die besten unter euch sind diejenigen, die den Koran lernen und ihn lehren.",
      source: "Buhârî, Fezâilü'l-Kur'ân 21",
      sourceEn: "Sahih al-Bukhari 5027",
      sourceDe: "Sahih al-Bukhari 5027",
    ),
    ContentItem(
      title: "Günün Hadisi",
      arabic: "إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ",
      turkish: "Ameller ancak niyetlere göredir.",
      english: "Actions are but by intentions.",
      german: "Die Taten sind entsprechend den Absichten.",
      source: "Buhârî, Bed'ü'l-Vahy 1",
      sourceEn: "Sahih al-Bukhari 1",
      sourceDe: "Sahih al-Bukhari 1",
    ),
    ContentItem(
      title: "Günün Hadisi",
      arabic: "الدُّعَاءُ هُوَ الْعِبَادَةُ",
      turkish: "Dua, ibadetin özüdür.",
      english: "Supplication is the essence of worship.",
      german: "Das Bittgebet (Dua) ist das Wesen des Gottesdienstes.",
      source: "Tirmizî, Deavât 1",
      sourceEn: "Jami` at-Tirmidhi 3371",
      sourceDe: "Jami` at-Tirmidhi 3371",
    ),
    ContentItem(
      title: "Günün Hadisi",
      arabic: "الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ",
      turkish: "Müslüman, elinden ve dilinden diğer Müslümanların güvende olduğu kimsedir.",
      english: "A Muslim is the one from whose tongue and hand other Muslims are safe.",
      german: "Ein Muslim ist derjenige, vor dessen Zunge und Hand die anderen Muslime sicher sind.",
      source: "Buhârî, Îmân 4",
      sourceEn: "Sahih al-Bukhari 10",
      sourceDe: "Sahih al-Bukhari 10",
    ),
    ContentItem(
      title: "Günün Hadisi",
      arabic: "تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ لَكَ صَدَقَةٌ",
      turkish: "Din kardeşine tebessüm etmen senin için bir sadakadır.",
      english: "Your smiling in the face of your brother is charity for you.",
      german: "Dein Lächeln für deinen Bruder ist für dich eine Sadaqah (Almosen).",
      source: "Tirmizî, Birr 36",
      sourceEn: "Jami` at-Tirmidhi 1956",
      sourceDe: "Jami` at-Tirmidhi 1956",
    ),
  ];

  static const List<ContentItem> dualar = [
    ContentItem(
      title: "Günün Duası",
      arabic: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
      turkish: "Rabbimiz! Bize dünyada da iyilik ver, ahirette de iyilik ver ve bizi ateş azabından koru.",
      english: "Our Lord, give us in this world [that which is] good and in the Hereafter [that which is] good and protect us from the punishment of the Fire.",
      german: "Unser Herr, gib uns im Diesseits Gutes und im Jenseits Gutes und behüte uns vor der Pein des Feuers!",
      source: "Bakara Sûresi, 201. Âyet",
      sourceEn: "Surah Al-Baqarah, Ayah 201",
      sourceDe: "Sure Al-Baqara, Vers 201",
    ),
    ContentItem(
      title: "Günün Duası",
      arabic: "رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي",
      turkish: "Rabbim! Göğsümü ferahlat, işimi bana kolaylaştır.",
      english: "My Lord, expand for me my chest and ease for me my task.",
      german: "Mein Herr, weite mir meine Brust und erleichtere mir meine Aufgabe.",
      source: "Tâhâ Sûresi, 25-26. Âyetler",
      sourceEn: "Surah Ta-Ha, Ayahs 25-26",
      sourceDe: "Sure Ta-Ha, Verse 25-26",
    ),
    ContentItem(
      title: "Günün Duası",
      arabic: "رَبَّنَا لاَ تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً",
      turkish: "Rabbimiz! Bizi hidayete erdirdikten sonra kalplerimizi eğriltme. Bize katından bir rahmet bağışla.",
      english: "Our Lord, let not our hearts deviate after You have guided us and grant us from Yourself mercy.",
      german: "Unser Herr, lass unsere Herzen nicht abweichen, nachdem Du uns rechtgeleitet hast, und schenke uns Barmherzigkeit von Dir.",
      source: "Âl-i İmrân Sûresi, 8. Âyet",
      sourceEn: "Surah Ali 'Imran, Ayah 8",
      sourceDe: "Sure Al-i 'Imran, Vers 8",
    ),
    ContentItem(
      title: "Günün Duası",
      arabic: "اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ",
      turkish: "Allah'ım! Seni anıp zikretmek, sana şükretmek ve sana güzelce ibadet etmek için bana yardım et.",
      english: "O Allah, help me to remember You, thank You, and worship You in the best manner.",
      german: "O Allah, hilf mir, Deiner zu gedenken, Dir zu danken und Dir auf beste Weise zu dienen.",
      source: "Ebu Davud, Vitir 26",
      sourceEn: "Abu Dawud 1522",
      sourceDe: "Abu Dawud 1522",
    ),
  ];

  static ContentItem getRandomAyet() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return ayetler[dayOfYear % ayetler.length];
  }

  static Future<ContentItem> fetchLiveAyet([int? ayahNumber]) async {
    try {
      final diyanetData = await HttpController().fetchDiyanetAyet(ayahNumber);
      if (diyanetData != null && (diyanetData['turkish']?.isNotEmpty ?? false)) {
        return ContentItem(
          title: "Günün Ayeti",
          arabic: diyanetData['arabic'] ?? '',
          turkish: diyanetData['turkish'] ?? '',
          english: diyanetData['english'],
          german: diyanetData['german'],
          source: diyanetData['sourceTr'] ?? '',
          sourceEn: diyanetData['sourceEn'],
          sourceDe: diyanetData['sourceDe'],
        );
      }
    } catch (_) {}
    return getRandomAyet();
  }

  static ContentItem getRandomHadis() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return hadisler[dayOfYear % hadisler.length];
  }

  static Future<ContentItem> fetchLiveHadis() async {
    try {
      final liveData = await HttpController().fetchLiveHadis();
      if (liveData != null && (liveData['turkish']?.isNotEmpty ?? false)) {
        return ContentItem(
          title: liveData['title'] ?? "Günün Hadisi",
          arabic: liveData['arabic'] ?? '',
          turkish: liveData['turkish'] ?? '',
          english: liveData['english'],
          german: liveData['german'],
          source: liveData['sourceTr'] ?? '',
          sourceEn: liveData['sourceEn'],
          sourceDe: liveData['sourceDe'],
        );
      }
    } catch (_) {}
    return getRandomHadis();
  }

  static ContentItem getRandomDua() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return dualar[dayOfYear % dualar.length];
  }
}
