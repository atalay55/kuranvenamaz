import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:kuranvenamaz/entity/quran_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranService {
  static const List<Surah> allSurahs = [
    Surah(number: 1, name: "الفاتحة", turkishName: "Fâtiha", englishNameTranslation: "Açılış", numberOfAyahs: 7, revelationType: "Mekke"),
    Surah(number: 2, name: "البقرة", turkishName: "Bakara", englishNameTranslation: "Boğa", numberOfAyahs: 286, revelationType: "Medine"),
    Surah(number: 3, name: "آل عمران", turkishName: "Âl-i İmrân", englishNameTranslation: "İmran Ailesi", numberOfAyahs: 200, revelationType: "Medine"),
    Surah(number: 4, name: "النساء", turkishName: "Nisâ", englishNameTranslation: "Kadınlar", numberOfAyahs: 176, revelationType: "Medine"),
    Surah(number: 5, name: "المائدة", turkishName: "Mâide", englishNameTranslation: "Sofralar", numberOfAyahs: 120, revelationType: "Medine"),
    Surah(number: 6, name: "الأنعام", turkishName: "En'âm", englishNameTranslation: "Hayvanlar", numberOfAyahs: 165, revelationType: "Mekke"),
    Surah(number: 7, name: "الأعراف", turkishName: "A'râf", englishNameTranslation: "Yüksek Yerler", numberOfAyahs: 206, revelationType: "Mekke"),
    Surah(number: 8, name: "الأنفال", turkishName: "Enfâl", englishNameTranslation: "Ganimetler", numberOfAyahs: 75, revelationType: "Medine"),
    Surah(number: 9, name: "التوبة", turkishName: "Tevbe", englishNameTranslation: "Tövbe", numberOfAyahs: 129, revelationType: "Medine"),
    Surah(number: 10, name: "يونس", turkishName: "Yûnus", englishNameTranslation: "Yunus Peygamber", numberOfAyahs: 109, revelationType: "Mekke"),
    Surah(number: 11, name: "هود", turkishName: "Hûd", englishNameTranslation: "Hud Peygamber", numberOfAyahs: 123, revelationType: "Mekke"),
    Surah(number: 12, name: "يوسف", turkishName: "Yûsuf", englishNameTranslation: "Yusuf Peygamber", numberOfAyahs: 111, revelationType: "Mekke"),
    Surah(number: 13, name: "الرعد", turkishName: "Ra'd", englishNameTranslation: "Gökgürültüsü", numberOfAyahs: 43, revelationType: "Medine"),
    Surah(number: 14, name: "إبراهيم", turkishName: "İbrâhîm", englishNameTranslation: "İbrahim Peygamber", numberOfAyahs: 52, revelationType: "Mekke"),
    Surah(number: 15, name: "الحجر", turkishName: "Hicr", englishNameTranslation: "Kayalık Bölge", numberOfAyahs: 99, revelationType: "Mekke"),
    Surah(number: 16, name: "النحل", turkishName: "Nahl", englishNameTranslation: "Bal Arısı", numberOfAyahs: 128, revelationType: "Mekke"),
    Surah(number: 17, name: "الإسراء", turkishName: "İsrâ", englishNameTranslation: "Gece Yürüyüşü", numberOfAyahs: 111, revelationType: "Mekke"),
    Surah(number: 18, name: "الكهف", turkishName: "Kehf", englishNameTranslation: "Mağara Halkı", numberOfAyahs: 110, revelationType: "Mekke"),
    Surah(number: 19, name: "مريم", turkishName: "Meryem", englishNameTranslation: "Meryem", numberOfAyahs: 98, revelationType: "Mekke"),
    Surah(number: 20, name: "طه", turkishName: "Tâhâ", englishNameTranslation: "Taha", numberOfAyahs: 135, revelationType: "Mekke"),
    Surah(number: 21, name: "الأنبيائ", turkishName: "Enbiyâ", englishNameTranslation: "Peygamberler", numberOfAyahs: 112, revelationType: "Mekke"),
    Surah(number: 22, name: "الحج", turkishName: "Hac", englishNameTranslation: "Hac İbadeti", numberOfAyahs: 78, revelationType: "Medine"),
    Surah(number: 23, name: "المؤمنون", turkishName: "Mü'minûn", englishNameTranslation: "Müminler", numberOfAyahs: 118, revelationType: "Mekke"),
    Surah(number: 24, name: "النور", turkishName: "Nûr", englishNameTranslation: "Nur", numberOfAyahs: 64, revelationType: "Medine"),
    Surah(number: 25, name: "الفرقان", turkishName: "Furkân", englishNameTranslation: "Doğru ile Yanlış", numberOfAyahs: 77, revelationType: "Mekke"),
    Surah(number: 26, name: "الشعراء", turkishName: "Şuarâ", englishNameTranslation: "Şairler", numberOfAyahs: 227, revelationType: "Mekke"),
    Surah(number: 27, name: "النمل", turkishName: "Neml", englishNameTranslation: "Karınca", numberOfAyahs: 93, revelationType: "Mekke"),
    Surah(number: 28, name: "القصص", turkishName: "Kasas", englishNameTranslation: "Kıssalar", numberOfAyahs: 88, revelationType: "Mekke"),
    Surah(number: 29, name: "العنكبوت", turkishName: "Ankebût", englishNameTranslation: "Örümcek", numberOfAyahs: 69, revelationType: "Mekke"),
    Surah(number: 30, name: "الروم", turkishName: "Rûm", englishNameTranslation: "Romalılar", numberOfAyahs: 60, revelationType: "Mekke"),
    Surah(number: 31, name: "لقمان", turkishName: "Lokmân", englishNameTranslation: "Lokman", numberOfAyahs: 34, revelationType: "Mekke"),
    Surah(number: 32, name: "السجدة", turkishName: "Secde", englishNameTranslation: "Secde", numberOfAyahs: 30, revelationType: "Mekke"),
    Surah(number: 33, name: "الأحزاب", turkishName: "Ahzâb", englishNameTranslation: "Müttefikler", numberOfAyahs: 73, revelationType: "Medine"),
    Surah(number: 34, name: "سبإ", turkishName: "Sebe'", englishNameTranslation: "Sebe Topluluğu", numberOfAyahs: 54, revelationType: "Mekke"),
    Surah(number: 35, name: "فاطر", turkishName: "Fâtır", englishNameTranslation: "Yaratan", numberOfAyahs: 45, revelationType: "Mekke"),
    Surah(number: 36, name: "يس", turkishName: "Yâsîn", englishNameTranslation: "Yasin", numberOfAyahs: 83, revelationType: "Mekke"),
    Surah(number: 37, name: "الصافات", turkishName: "Sâffât", englishNameTranslation: "Sıra Sıra Dizilenler", numberOfAyahs: 182, revelationType: "Mekke"),
    Surah(number: 38, name: "ص", turkishName: "Sâd", englishNameTranslation: "Sad", numberOfAyahs: 88, revelationType: "Mekke"),
    Surah(number: 39, name: "الزمر", turkishName: "Zümer", englishNameTranslation: "Zümreler", numberOfAyahs: 75, revelationType: "Mekke"),
    Surah(number: 40, name: "غافر", turkishName: "Mü'min (Ğâfir)", englishNameTranslation: "Bağışlayan", numberOfAyahs: 85, revelationType: "Mekke"),
    Surah(number: 41, name: "فصلت", turkishName: "Fussilet", englishNameTranslation: "Açıklanmış", numberOfAyahs: 54, revelationType: "Mekke"),
    Surah(number: 42, name: "الشورى", turkishName: "Şûrâ", englishNameTranslation: "Danışma", numberOfAyahs: 53, revelationType: "Mekke"),
    Surah(number: 43, name: "الزخرف", turkishName: "Zuhruf", englishNameTranslation: "Mücevherler", numberOfAyahs: 89, revelationType: "Mekke"),
    Surah(number: 44, name: "الدخان", turkishName: "Duhân", englishNameTranslation: "Duman", numberOfAyahs: 59, revelationType: "Mekke"),
    Surah(number: 45, name: "الجاثية", turkishName: "Câsiye", englishNameTranslation: "Diz Üstü Çökenler", numberOfAyahs: 37, revelationType: "Mekke"),
    Surah(number: 46, name: "الأحقاف", turkishName: "Ahkâf", englishNameTranslation: "Kum Tepeleri", numberOfAyahs: 35, revelationType: "Mekke"),
    Surah(number: 47, name: "محمد", turkishName: "Muhammed", englishNameTranslation: "Muhammed Peygamber", numberOfAyahs: 38, revelationType: "Medine"),
    Surah(number: 48, name: "الفتح", turkishName: "Fetih", englishNameTranslation: "Zafer", numberOfAyahs: 29, revelationType: "Medine"),
    Surah(number: 49, name: "الحجرات", turkishName: "Hucurât", englishNameTranslation: "Odalar", numberOfAyahs: 18, revelationType: "Medine"),
    Surah(number: 50, name: "ق", turkishName: "Kâf", englishNameTranslation: "Kaf", numberOfAyahs: 45, revelationType: "Mekke"),
    Surah(number: 51, name: "الذاريات", turkishName: "Zâriyât", englishNameTranslation: "Estrip Savuranlar", numberOfAyahs: 60, revelationType: "Mekke"),
    Surah(number: 52, name: "الطور", turkishName: "Tûr", englishNameTranslation: "Tur Dağı", numberOfAyahs: 49, revelationType: "Mekke"),
    Surah(number: 53, name: "النجم", turkishName: "Necm", englishNameTranslation: "Yıldız", numberOfAyahs: 62, revelationType: "Mekke"),
    Surah(number: 54, name: "القمر", turkishName: "Kamer", englishNameTranslation: "Ay", numberOfAyahs: 55, revelationType: "Mekke"),
    Surah(number: 55, name: "الرحمن", turkishName: "Rahmân", englishNameTranslation: "Çok Merhametli", numberOfAyahs: 78, revelationType: "Medine"),
    Surah(number: 56, name: "الواقعة", turkishName: "Vâkıa", englishNameTranslation: "Kıyamet Olaya", numberOfAyahs: 96, revelationType: "Mekke"),
    Surah(number: 57, name: "الحديد", turkishName: "Hadîd", englishNameTranslation: "Demir", numberOfAyahs: 29, revelationType: "Medine"),
    Surah(number: 58, name: "المجادلة", turkishName: "Mücâdele", englishNameTranslation: "Tartışma", numberOfAyahs: 22, revelationType: "Medine"),
    Surah(number: 59, name: "الحشر", turkishName: "Haşr", englishNameTranslation: "Sürgün", numberOfAyahs: 24, revelationType: "Medine"),
    Surah(number: 60, name: "الممتحنة", turkishName: "Mümtehine", englishNameTranslation: "Sınanan Kadın", numberOfAyahs: 13, revelationType: "Medine"),
    Surah(number: 61, name: "الصف", turkishName: "Saff", englishNameTranslation: "Saf Düzeni", numberOfAyahs: 14, revelationType: "Medine"),
    Surah(number: 62, name: "الجمعة", turkishName: "Cuma", englishNameTranslation: "Cuma Günü", numberOfAyahs: 11, revelationType: "Medine"),
    Surah(number: 63, name: "المنافقون", turkishName: "Münâfikûn", englishNameTranslation: "İkiyüzlüler", numberOfAyahs: 11, revelationType: "Medine"),
    Surah(number: 64, name: "التغابن", turkishName: "Teğâbün", englishNameTranslation: "Kayıp ve Kazanç", numberOfAyahs: 18, revelationType: "Medine"),
    Surah(number: 65, name: "الطلاق", turkishName: "Talâk", englishNameTranslation: "Boşanma", numberOfAyahs: 12, revelationType: "Medine"),
    Surah(number: 66, name: "التحريم", turkishName: "Tahrîm", englishNameTranslation: "Yasaklama", numberOfAyahs: 12, revelationType: "Medine"),
    Surah(number: 67, name: "الملك", turkishName: "Mülk", englishNameTranslation: "Hükümranlık", numberOfAyahs: 30, revelationType: "Mekke"),
    Surah(number: 68, name: "القلم", turkishName: "Kalem", englishNameTranslation: "Kalem", numberOfAyahs: 52, revelationType: "Mekke"),
    Surah(number: 69, name: "الحاقة", turkishName: "Hâkka", englishNameTranslation: "Gerçekleşecek Olan", numberOfAyahs: 52, revelationType: "Mekke"),
    Surah(number: 70, name: "المعارج", turkishName: "Meâric", englishNameTranslation: "Yükselme Yolları", numberOfAyahs: 44, revelationType: "Mekke"),
    Surah(number: 71, name: "نوح", turkishName: "Nûh", englishNameTranslation: "Nuh Peygamber", numberOfAyahs: 28, revelationType: "Mekke"),
    Surah(number: 72, name: "الجن", turkishName: "Cin", englishNameTranslation: "Cinler", numberOfAyahs: 28, revelationType: "Mekke"),
    Surah(number: 73, name: "المزمل", turkishName: "Müzzemmil", englishNameTranslation: "Örtünüp Bürünen", numberOfAyahs: 20, revelationType: "Mekke"),
    Surah(number: 74, name: "المدثر", turkishName: "Müddessir", englishNameTranslation: "Bürünen", numberOfAyahs: 56, revelationType: "Mekke"),
    Surah(number: 75, name: "القيامة", turkishName: "Kıyamet", englishNameTranslation: "Diriliş Günü", numberOfAyahs: 40, revelationType: "Mekke"),
    Surah(number: 76, name: "الإنسان", turkishName: "İnsân", englishNameTranslation: "İnsan", numberOfAyahs: 31, revelationType: "Medine"),
    Surah(number: 77, name: "المرسلات", turkishName: "Mürselât", englishNameTranslation: "Gönderilenler", numberOfAyahs: 50, revelationType: "Mekke"),
    Surah(number: 78, name: "النبإ", turkishName: "Nebe'", englishNameTranslation: "Büyük Haber", numberOfAyahs: 40, revelationType: "Mekke"),
    Surah(number: 79, name: "النازعات", turkishName: "Nâziât", englishNameTranslation: "Çekip Çıkaranlar", numberOfAyahs: 46, revelationType: "Mekke"),
    Surah(number: 80, name: "عبس", turkishName: "Abese", englishNameTranslation: "Yüzünü Ekşitti", numberOfAyahs: 42, revelationType: "Mekke"),
    Surah(number: 81, name: "التكوير", turkishName: "Tekvîr", englishNameTranslation: "Dürülme", numberOfAyahs: 29, revelationType: "Mekke"),
    Surah(number: 82, name: "الإنفطار", turkishName: "İnfitâr", englishNameTranslation: "Yarılma", numberOfAyahs: 19, revelationType: "Mekke"),
    Surah(number: 83, name: "المطففين", turkishName: "Mutaffifîn", englishNameTranslation: "Ölçüde Hile Yapanlar", numberOfAyahs: 36, revelationType: "Mekke"),
    Surah(number: 84, name: "الإنشقاق", turkishName: "İnşikâk", englishNameTranslation: "Yarılma", numberOfAyahs: 25, revelationType: "Mekke"),
    Surah(number: 85, name: "البروج", turkishName: "Bürüc", englishNameTranslation: "Burçlar", numberOfAyahs: 22, revelationType: "Mekke"),
    Surah(number: 86, name: "الطارق", turkishName: "Târık", englishNameTranslation: "Gece Gelen", numberOfAyahs: 17, revelationType: "Mekke"),
    Surah(number: 87, name: "الأعلى", turkishName: "A'lâ", englishNameTranslation: "En Yüce", numberOfAyahs: 19, revelationType: "Mekke"),
    Surah(number: 88, name: "الغاشية", turkishName: "Gâşiye", englishNameTranslation: "Kuşatan", numberOfAyahs: 26, revelationType: "Mekke"),
    Surah(number: 89, name: "الفجر", turkishName: "Fecr", englishNameTranslation: "Şafak Vakti", numberOfAyahs: 30, revelationType: "Mekke"),
    Surah(number: 90, name: "البلد", turkishName: "Beled", englishNameTranslation: "Şehir", numberOfAyahs: 20, revelationType: "Mekke"),
    Surah(number: 91, name: "الشمس", turkishName: "Şems", englishNameTranslation: "Güneş", numberOfAyahs: 15, revelationType: "Mekke"),
    Surah(number: 92, name: "الليل", turkishName: "Leyl", englishNameTranslation: "Gece", numberOfAyahs: 21, revelationType: "Mekke"),
    Surah(number: 93, name: "الضحى", turkishName: "Duhâ", englishNameTranslation: "Kuşluk Vakti", numberOfAyahs: 11, revelationType: "Mekke"),
    Surah(number: 94, name: "الشرح", turkishName: "İnşirâh", englishNameTranslation: "Ferahlık", numberOfAyahs: 8, revelationType: "Mekke"),
    Surah(number: 95, name: "التين", turkishName: "Tîn", englishNameTranslation: "Incir", numberOfAyahs: 8, revelationType: "Mekke"),
    Surah(number: 96, name: "العلق", turkishName: "Alak", englishNameTranslation: "Kan Pıhtısı", numberOfAyahs: 19, revelationType: "Mekke"),
    Surah(number: 97, name: "القدر", turkishName: "Kadr", englishNameTranslation: "Kadir Gecesi", numberOfAyahs: 5, revelationType: "Mekke"),
    Surah(number: 98, name: "البينة", turkishName: "Beyyine", englishNameTranslation: "Açık Delil", numberOfAyahs: 8, revelationType: "Medine"),
    Surah(number: 99, name: "الزلزلة", turkishName: "Zilzâl", englishNameTranslation: "Deprem", numberOfAyahs: 8, revelationType: "Medine"),
    Surah(number: 100, name: "العاديات", turkishName: "Âdiyât", englishNameTranslation: "Koşan Atlar", numberOfAyahs: 11, revelationType: "Mekke"),
    Surah(number: 101, name: "القارعة", turkishName: "Kâria", englishNameTranslation: "Çarpan Felaket", numberOfAyahs: 11, revelationType: "Mekke"),
    Surah(number: 102, name: "التكاثر", turkishName: "Tekâsür", englishNameTranslation: "Çokluk Yarışı", numberOfAyahs: 8, revelationType: "Mekke"),
    Surah(number: 103, name: "العصر", turkishName: "Asr", englishNameTranslation: "Zaman", numberOfAyahs: 3, revelationType: "Mekke"),
    Surah(number: 104, name: "الهمزة", turkishName: "Hümeze", englishNameTranslation: "Dedikoducu", numberOfAyahs: 9, revelationType: "Mekke"),
    Surah(number: 105, name: "الفيل", turkishName: "Fîl", englishNameTranslation: "Fil", numberOfAyahs: 5, revelationType: "Mekke"),
    Surah(number: 106, name: "قريش", turkishName: "Kureyş", englishNameTranslation: "Kureyş Kabilesi", numberOfAyahs: 4, revelationType: "Mekke"),
    Surah(number: 107, name: "الماعون", turkishName: "Mâûn", englishNameTranslation: "Yardım", numberOfAyahs: 7, revelationType: "Mekke"),
    Surah(number: 108, name: "الكوثر", turkishName: "Kevser", englishNameTranslation: "Bolluk", numberOfAyahs: 3, revelationType: "Mekke"),
    Surah(number: 109, name: "الكافرون", turkishName: "Kâfirûn", englishNameTranslation: "İnkârcılar", numberOfAyahs: 6, revelationType: "Mekke"),
    Surah(number: 110, name: "النصر", turkishName: "Nasr", englishNameTranslation: "Yardım ve Zafer", numberOfAyahs: 3, revelationType: "Medine"),
    Surah(number: 111, name: "المسد", turkishName: "Tebbet", englishNameTranslation: "Alev", numberOfAyahs: 5, revelationType: "Mekke"),
    Surah(number: 112, name: "الإخلاص", turkishName: "İhlâs", englishNameTranslation: "Samimiyet", numberOfAyahs: 4, revelationType: "Mekke"),
    Surah(number: 113, name: "الفلق", turkishName: "Felak", englishNameTranslation: "Şafak", numberOfAyahs: 5, revelationType: "Mekke"),
    Surah(number: 114, name: "الناس", turkishName: "Nâs", englishNameTranslation: "İnsanlar", numberOfAyahs: 6, revelationType: "Mekke"),
  ];

  // Fetch Surah Ayahs from Al-Quran Cloud (Arabic Uthmani + Diyanet Meal)
  Future<List<AyahDetail>> fetchSurahAyahs(int surahNumber) async {
    try {
      final url = 'https://api.alquran.cloud/v1/surah/$surahNumber/editions/quran-uthmani,tr.diyanet';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['data'] != null && jsonData['data'] is List && (jsonData['data'] as List).length >= 2) {
          final arabicList = jsonData['data'][0]['ayahs'] as List;
          final diyanetList = jsonData['data'][1]['ayahs'] as List;

          List<AyahDetail> result = [];
          for (int i = 0; i < arabicList.length && i < diyanetList.length; i++) {
            final arabicItem = arabicList[i];
            final diyanetItem = diyanetList[i];

            result.add(
              AyahDetail(
                numberInSurah: arabicItem['numberInSurah'] ?? (i + 1),
                arabicText: arabicItem['text'] ?? '',
                turkishTranslation: diyanetItem['text'] ?? '',
              ),
            );
          }
          return result;
        }
      }
    } catch (e) {
      debugPrint("Surah fetch error ($surahNumber): $e");
    }
    return [];
  }

  // Save Last Read Surah Bookmark
  static Future<void> saveLastReadSurah(int surahNumber, String surahName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_surah_num', surahNumber);
    await prefs.setString('last_read_surah_name', surahName);
  }

  // Get Last Read Surah Bookmark
  static Future<Map<String, dynamic>?> getLastReadSurah() async {
    final prefs = await SharedPreferences.getInstance();
    int? num = prefs.getInt('last_read_surah_num');
    String? name = prefs.getString('last_read_surah_name');
    if (num != null && name != null) {
      return {'number': num, 'name': name};
    }
    return null;
  }
}
