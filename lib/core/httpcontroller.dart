import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kuranvenamaz/entity/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entity/city.dart';
import '../entity/country.dart';

class HttpController {
  // Ülke listesi (Türkiye, Almanya ve tüm popüler ülkeler)
  Future<List<Country>> fetchCountryJSONData() async {
    return [
      Country(code: 'TR', name: 'Türkiye (Turkey)'),
      Country(code: 'DE', name: 'Almanya (Germany)'),
      Country(code: 'FR', name: 'Fransa (France)'),
      Country(code: 'NL', name: 'Hollanda (Netherlands)'),
      Country(code: 'AT', name: 'Avusturya (Austria)'),
      Country(code: 'BE', name: 'Belçika (Belgium)'),
      Country(code: 'CH', name: 'İsviçre (Switzerland)'),
      Country(code: 'GB', name: 'İngiltere (United Kingdom)'),
      Country(code: 'AZ', name: 'Azerbaycan (Azerbaijan)'),
      Country(code: 'US', name: 'Amerika (United States)'),
      Country(code: 'SA', name: 'Suudi Arabistan (Saudi Arabia)'),
      Country(code: 'BA', name: 'Bosna-Hersek (Bosnia)'),
      Country(code: 'CY', name: 'Kuzey Kıbrıs (North Cyprus)'),
      Country(code: 'SE', name: 'İsveç (Sweden)'),
      Country(code: 'NO', name: 'Norveç (Norway)'),
      Country(code: 'DK', name: 'Danimarka (Denmark)'),
      Country(code: 'IT', name: 'İtalya (Italy)'),
      Country(code: 'ES', name: 'İspanya (Spain)'),
      Country(code: 'RU', name: 'Rusya (Russia)'),
      Country(code: 'CA', name: 'Kanada (Canada)'),
      Country(code: 'AU', name: 'Avustralya (Australia)'),
      Country(code: 'UZ', name: 'Özbekistan (Uzbekistan)'),
      Country(code: 'KZ', name: 'Kazakistan (Kazakhstan)'),
    ];
  }

  // Seçilen ülkeye özel şehir listesi
  Future<List<City>> fetchCities(String country) async {
    final lower = country.toLowerCase().trim();

    // 1. Almanya Şehirleri
    if (lower.contains('alman') || lower.contains('german') || lower == 'de') {
      const germanyCities = [
        'Berlin',
        'Köln (Cologne)',
        'Frankfurt',
        'München (Munich)',
        'Hamburg',
        'Stuttgart',
        'Düsseldorf',
        'Dortmund',
        'Essen',
        'Bremen',
        'Hannover',
        'Leipzig',
        'Dresden',
        'Nürnberg',
        'Duisburg',
        'Bochum',
        'Wuppertal',
        'Bielefeld',
        'Bonn',
        'Münster',
        'Karlsruhe',
        'Mannheim',
        'Augsburg',
        'Wiesbaden',
        'Gelsenkirchen',
        'Mönchengladbach',
        'Braunschweig',
        'Chemnitz',
        'Kiel',
        'Aachen',
        'Halle',
        'Magdeburg',
        'Freiburg',
        'Krefeld',
        'Mainz',
        'Lübeck',
        'Erfurt',
        'Oberhausen',
        'Rostock',
        'Kassel',
        'Hagen',
        'Saarbrücken',
        'Potsdam',
        'Ludwigshafen',
        'Mülheim an der Ruhr',
        'Oldenburg',
        'Osnabrück',
        'Leverkusen',
        'Heidelberg',
        'Darmstadt',
        'Solingen',
        'Herne',
        'Neuss',
        'Regensburg',
        'Paderborn',
        'Ingolstadt',
        'Offenbach am Main',
        'Würzburg',
        'Ulm',
        'Heilbronn',
        'Pforzheim',
        'Wolfsburg',
        'Göttingen',
        'Bottrop',
        'Reutlingen',
        'Koblenz',
        'Bremerhaven',
        'Bergisch Gladbach',
        'Remscheid',
        'Jena',
        'Trier',
        'Erlangen',
        'Moers',
        'Siegen',
        'Hildesheim',
        'Salzgitter',
      ];
      return germanyCities.map((c) => City(c)).toList();
    }

    // 2. Fransa Şehirleri
    if (lower.contains('fran') || lower == 'fr') {
      const franceCities = [
        'Paris',
        'Marseille (Marsilya)',
        'Lyon',
        'Toulouse',
        'Nice',
        'Nantes',
        'Strasbourg',
        'Montpellier',
        'Bordeaux',
        'Lille',
        'Rennes',
        'Reims',
        'Saint-Étienne',
        'Toulon',
        'Le Havre',
        'Grenoble',
        'Dijon',
        'Angers',
        'Nîmes',
        'Aix-en-Provence',
        'Mulhouse',
        'Clermont-Ferrand',
        'Tours',
        'Amiens',
        'Metz',
        'Besançon',
        'Orléans',
        'Rouen',
      ];
      return franceCities.map((c) => City(c)).toList();
    }

    // 3. Hollanda Şehirleri
    if (lower.contains('holland') || lower.contains('netherland') || lower == 'nl') {
      const netherlandsCities = [
        'Amsterdam',
        'Rotterdam',
        'Den Haag (Lahey)',
        'Utrecht',
        'Eindhoven',
        'Groningen',
        'Tilburg',
        'Almere',
        'Breda',
        'Nijmegen',
        'Apeldoorn',
        'Arnhem',
        'Haarlem',
        'Enschede',
        'Amersfoort',
        'Zaanstad',
        '\'s-Hertogenbosch',
        'Zwolle',
        'Leiden',
        'Maastricht',
        'Dordrecht',
        'Delft',
        'Alkmaar',
      ];
      return netherlandsCities.map((c) => City(c)).toList();
    }

    // 4. Avusturya Şehirleri
    if (lower.contains('avustur') || lower.contains('austria') || lower == 'at') {
      const austriaCities = [
        'Wien (Viyana)',
        'Graz',
        'Linz',
        'Salzburg',
        'Innsbruck',
        'Klagenfurt',
        'Villach',
        'Wels',
        'Sankt Pölten',
        'Dornbirn',
        'Wiener Neustadt',
        'Bregenz',
        'Baden',
      ];
      return austriaCities.map((c) => City(c)).toList();
    }

    // 5. Belçika Şehirleri
    if (lower.contains('belç') || lower.contains('belg') || lower == 'be') {
      const belgiumCities = [
        'Bruxelles (Brüksel)',
        'Antwerpen (Anvers)',
        'Gent',
        'Charleroi',
        'Liège',
        'Brugge',
        'Namur',
        'Leuven',
        'Mons',
        'Aalst',
        'Mechelen',
        'Kortrijk',
        'Hasselt',
        'Genk',
      ];
      return belgiumCities.map((c) => City(c)).toList();
    }

    // 6. İsviçre Şehirleri
    if (lower.contains('isviç') || lower.contains('switz') || lower == 'ch') {
      const switzerlandCities = [
        'Zürich',
        'Genève (Cenevre)',
        'Basel',
        'Lausanne (Lozan)',
        'Bern',
        'Winterthur',
        'Luzern',
        'St. Gallen',
        'Lugano',
        'Biel/Bienne',
        'Thun',
        'Fribourg',
        'Schaffhausen',
      ];
      return switzerlandCities.map((c) => City(c)).toList();
    }

    // 7. Birleşik Krallık / İngiltere Şehirleri
    if (lower.contains('ingil') || lower.contains('united kingdom') || lower.contains('britain') || lower == 'gb' || lower == 'uk') {
      const ukCities = [
        'London (Londra)',
        'Birmingham',
        'Manchester',
        'Leeds',
        'Glasgow',
        'Liverpool',
        'Newcastle',
        'Sheffield',
        'Bristol',
        'Belfast',
        'Edinburgh',
        'Leicester',
        'Nottingham',
        'Southampton',
        'Cardiff',
        'Coventry',
        'Bradford',
        'Luton',
        'Cambridge',
        'Oxford',
      ];
      return ukCities.map((c) => City(c)).toList();
    }

    // 8. Amerika Birleşik Devletleri (ABD) Şehirleri
    if (lower.contains('amerik') || lower.contains('united states') || lower == 'us' || lower == 'usa') {
      const usCities = [
        'New York',
        'Los Angeles',
        'Chicago',
        'Houston',
        'Phoenix',
        'Philadelphia',
        'San Antonio',
        'San Diego',
        'Dallas',
        'San Jose',
        'Austin',
        'Jacksonville',
        'San Francisco',
        'Seattle',
        'Denver',
        'Washington',
        'Boston',
        'Detroit',
        'Miami',
        'Atlanta',
        'Orlando',
        'Minneapolis',
        'Las Vegas',
      ];
      return usCities.map((c) => City(c)).toList();
    }

    // 9. Azerbaycan Şehirleri
    if (lower.contains('azer') || lower == 'az') {
      const azerbaijanCities = [
        'Baku (Bakü)',
        'Ganja (Gence)',
        'Sumqayit (Sumgayıt)',
        'Mingachevir (Mingeçevir)',
        'Shirvan (Şirvan)',
        'Nakhchivan (Nahçıvan)',
        'Sheki (Şeki)',
        'Lankaran (Lenkeran)',
        'Yevlakh (Yevlah)',
        'Guba (Kuba)',
        'Shusha (Şuşa)',
        'Khankendi (Hankendi)',
      ];
      return azerbaijanCities.map((c) => City(c)).toList();
    }

    // 10. Suudi Arabistan Şehirleri
    if (lower.contains('suud') || lower.contains('saudi') || lower == 'sa') {
      const saudiCities = [
        'Makkah (Mekke)',
        'Madinah (Medine)',
        'Riyadh (Riyad)',
        'Jeddah (Cidde)',
        'Dammam',
        'Taif',
        'Tabuk (Tebük)',
        'Buraidah',
        'Al Khobar',
        'Abha',
        'Yanbu',
      ];
      return saudiCities.map((c) => City(c)).toList();
    }

    // 11. Bosna-Hersek Şehirleri
    if (lower.contains('bosna') || lower.contains('bosnia') || lower == 'ba') {
      const bosniaCities = [
        'Sarajevo (Saraybosna)',
        'Mostar',
        'Banja Luka',
        'Tuzla',
        'Zenica',
        'Bihac',
        'Travnik',
      ];
      return bosniaCities.map((c) => City(c)).toList();
    }

    // 12. Kuzey Kıbrıs Şehirleri
    if (lower.contains('kıbrıs') || lower.contains('kibris') || lower.contains('cyprus') || lower == 'cy') {
      const cyprusCities = [
        'Lefkosa (Nicosia)',
        'Gazimagusa (Famagusta)',
        'Girne (Kyrenia)',
        'Guzelyurt',
        'Iskele',
      ];
      return cyprusCities.map((c) => City(c)).toList();
    }

    // 13. İsveç Şehirleri
    if (lower.contains('isveç') || lower.contains('isvec') || lower.contains('sweden') || lower == 'se') {
      const swedenCities = [
        'Stockholm',
        'Göteborg',
        'Malmö',
        'Uppsala',
        'Västerås',
        'Örebro',
        'Linköping',
        'Helsingborg',
      ];
      return swedenCities.map((c) => City(c)).toList();
    }

    // 14. Norveç Şehirleri
    if (lower.contains('norveç') || lower.contains('norvec') || lower.contains('norway') || lower == 'no') {
      const norwayCities = [
        'Oslo',
        'Bergen',
        'Trondheim',
        'Stavanger',
        'Drammen',
        'Kristiansand',
        'Tromsø',
      ];
      return norwayCities.map((c) => City(c)).toList();
    }

    // 15. Danimarka Şehirleri
    if (lower.contains('danimark') || lower.contains('denmark') || lower == 'dk') {
      const denmarkCities = [
        'København (Kopenhag)',
        'Aarhus',
        'Odense',
        'Aalborg',
        'Esbjerg',
        'Randers',
      ];
      return denmarkCities.map((c) => City(c)).toList();
    }

    // 16. İtalya Şehirleri
    if (lower.contains('ital') || lower == 'it') {
      const italyCities = [
        'Roma (Rome)',
        'Milano (Milan)',
        'Napoli',
        'Torino',
        'Palermo',
        'Bologna',
        'Firenze (Florence)',
        'Venezia (Venice)',
      ];
      return italyCities.map((c) => City(c)).toList();
    }

    // 17. İspanya Şehirleri
    if (lower.contains('ispan') || lower.contains('spain') || lower == 'es') {
      const spainCities = [
        'Madrid',
        'Barcelona',
        'Valencia',
        'Sevilla',
        'Zaragoza',
        'Malaga',
        'Granada',
        'Cordoba',
      ];
      return spainCities.map((c) => City(c)).toList();
    }

    // 18. Rusya Şehirleri
    if (lower.contains('rus') || lower == 'ru') {
      const russiaCities = [
        'Moscow (Moskova)',
        'Saint Petersburg',
        'Kazan',
        'Ufa',
        'Novosibirsk',
        'Yekaterinburg',
        'Grozny',
        'Makhachkala',
      ];
      return russiaCities.map((c) => City(c)).toList();
    }

    // 19. Kanada Şehirleri
    if (lower.contains('kanada') || lower.contains('canada') || lower == 'ca') {
      const canadaCities = [
        'Toronto',
        'Montreal',
        'Vancouver',
        'Calgary',
        'Edmonton',
        'Ottawa',
        'Winnipeg',
      ];
      return canadaCities.map((c) => City(c)).toList();
    }

    // 20. Avustralya Şehirleri
    if (lower.contains('avustral') || lower.contains('australia') || lower == 'au') {
      const australiaCities = [
        'Sydney',
        'Melbourne',
        'Brisbane',
        'Perth',
        'Adelaide',
        'Canberra',
      ];
      return australiaCities.map((c) => City(c)).toList();
    }

    // 21. Özbekistan Şehirleri
    if (lower.contains('özbek') || lower.contains('uzbek') || lower == 'uz') {
      const uzbekistanCities = [
        'Tashkent (Taşkent)',
        'Samarkand (Semerkant)',
        'Bukhara (Buhara)',
        'Namangan',
        'Andijan',
        'Fergana',
        'Khiva',
      ];
      return uzbekistanCities.map((c) => City(c)).toList();
    }

    // 22. Kazakistan Şehirleri
    if (lower.contains('kazak') || lower == 'kz') {
      const kazakhstanCities = [
        'Almaty',
        'Astana (Nur-Sultan)',
        'Shymkent',
        'Karaganda',
        'Aktobe',
        'Taraz',
        'Turkistan',
      ];
      return kazakhstanCities.map((c) => City(c)).toList();
    }

    // Varsayılan: Türkiye'nin 81 İli
    const turkeyCities = [
      'Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Aksaray', 'Amasya', 'Ankara', 'Antalya',
      'Ardahan', 'Artvin', 'Aydın', 'Balıkesir', 'Bartın', 'Batman', 'Bayburt', 'Bilecik',
      'Bingöl', 'Bitlis', 'Bolu', 'Burdur', 'Bursa', 'Çanakkale', 'Çankırı', 'Çorum',
      'Denizli', 'Diyarbakır', 'Düzce', 'Edirne', 'Elazığ', 'Erzincan', 'Erzurum', 'Eskişehir',
      'Gaziantep', 'Giresun', 'Gümüşhane', 'Hakkari', 'Hatay', 'Iğdır', 'Isparta', 'İstanbul',
      'İzmir', 'Kahramanmaraş', 'Karabük', 'Karaman', 'Kars', 'Kastamonu', 'Kayseri', 'Kilis',
      'Kırıkkale', 'Kırklareli', 'Kırşehir', 'Kocaeli', 'Konya', 'Kütahya', 'Malatya', 'Manisa',
      'Mardin', 'Mersin', 'Muğla', 'Muş', 'Nevşehir', 'Niğde', 'Ordu', 'Osmaniye',
      'Rize', 'Sakarya', 'Samsun', 'Şanlıurfa', 'Siirt', 'Sinop', 'Sivas', 'Şırnak',
      'Tekirdağ', 'Tokat', 'Trabzon', 'Tunceli', 'Uşak', 'Van', 'Yalova', 'Yozgat', 'Zonguldak'
    ];
    return turkeyCities.map((c) => City(c)).toList();
  }

  String _normalizeTurkishCharacters(String input) {
    return input
        .replaceAll('İ', 'I')
        .replaceAll('ı', 'i')
        .replaceAll('Ş', 'S')
        .replaceAll('ş', 's')
        .replaceAll('Ğ', 'G')
        .replaceAll('ğ', 'g')
        .replaceAll('Ü', 'U')
        .replaceAll('ü', 'u')
        .replaceAll('Ö', 'O')
        .replaceAll('ö', 'o')
        .replaceAll('Ç', 'C')
        .replaceAll('ç', 'c')
        .trim();
  }

  String _normalizeCityName(String city) {
    if (city.isEmpty) return 'Istanbul';
    // Parantez içindeki açıklamayı ayır (örn: "Köln (Cologne)" -> "Köln")
    String cleaned = city.contains('(') ? city.split('(')[0].trim() : city;
    String norm = _normalizeTurkishCharacters(cleaned);
    return norm.isEmpty ? 'Istanbul' : norm;
  }

  String _normalizeCountryName(String country) {
    if (country.isEmpty) return 'Turkey';
    final lower = country.toLowerCase().trim();

    // Aladhan API için standart ülke adı eşleştirmeleri
    if (lower.contains('alman') || lower.contains('german') || lower == 'de') return 'Germany';
    if (lower.contains('türk') || lower.contains('turk') || lower == 'tr') return 'Turkey';
    if (lower.contains('fran') || lower == 'fr') return 'France';
    if (lower.contains('holland') || lower.contains('netherland') || lower == 'nl') return 'Netherlands';
    if (lower.contains('avustur') || lower.contains('austria') || lower == 'at') return 'Austria';
    if (lower.contains('belç') || lower.contains('belg') || lower == 'be') return 'Belgium';
    if (lower.contains('isviç') || lower.contains('switz') || lower == 'ch') return 'Switzerland';
    if (lower.contains('ingil') || lower.contains('united kingdom') || lower == 'gb' || lower == 'uk') return 'United Kingdom';
    if (lower.contains('amerik') || lower.contains('united states') || lower == 'us' || lower == 'usa') return 'United States';
    if (lower.contains('azer') || lower == 'az') return 'Azerbaijan';
    if (lower.contains('suud') || lower.contains('saudi') || lower == 'sa') return 'Saudi Arabia';
    if (lower.contains('bosna') || lower.contains('bosnia') || lower == 'ba') return 'Bosnia and Herzegovina';
    if (lower.contains('kıbrıs') || lower.contains('kibris') || lower.contains('cyprus') || lower == 'cy') return 'Cyprus';
    if (lower.contains('isveç') || lower.contains('isvec') || lower.contains('sweden') || lower == 'se') return 'Sweden';
    if (lower.contains('norveç') || lower.contains('norvec') || lower.contains('norway') || lower == 'no') return 'Norway';
    if (lower.contains('danimark') || lower.contains('denmark') || lower == 'dk') return 'Denmark';
    if (lower.contains('ital') || lower == 'it') return 'Italy';
    if (lower.contains('ispan') || lower.contains('spain') || lower == 'es') return 'Spain';
    if (lower.contains('rus') || lower == 'ru') return 'Russia';
    if (lower.contains('kanada') || lower.contains('canada') || lower == 'ca') return 'Canada';
    if (lower.contains('avustral') || lower.contains('australia') || lower == 'au') return 'Australia';
    if (lower.contains('özbek') || lower.contains('uzbek') || lower == 'uz') return 'Uzbekistan';
    if (lower.contains('kazak') || lower == 'kz') return 'Kazakhstan';

    String cleaned = country.contains('(') ? country.split('(')[0].trim() : country;
    String norm = _normalizeTurkishCharacters(cleaned);
    return norm.isEmpty ? 'Turkey' : norm;
  }

  // Diyanet takvimine göre Namaz Vakitleri Alma (Aladhan Diyanet Method = 13)
  Future<Times> fetchPrayerTimesData(String country, String city) async {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final cleanCity = _normalizeCityName(city);
    final cleanCountry = _normalizeCountryName(country);
    final cacheKey = 'prayer_times_cache_${cleanCountry.toLowerCase().replaceAll(' ', '_')}_${cleanCity.toLowerCase().replaceAll(' ', '_')}';
    final encodedCity = Uri.encodeComponent(cleanCity);
    final encodedCountry = Uri.encodeComponent(cleanCountry);

    // 1. Öncelik: Tüm ayın takvim verisini çekme
    try {
      final url = 'https://api.aladhan.com/v1/calendarByCity?city=$encodedCity&country=$encodedCountry&method=13&month=${now.month}&year=${now.year}';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['data'] != null && jsonData['data'] is List) {
          final List<dynamic> daysList = jsonData['data'];
          Map<String, List<String>> timesByDate = {};

          for (var dayData in daysList) {
            final timings = dayData['timings'];
            final dateObj = dayData['date']?['gregorian']?['date']; // DD-MM-YYYY
            if (timings != null && dateObj != null) {
              final parts = dateObj.toString().split('-'); // [DD, MM, YYYY]
              if (parts.length == 3) {
                final dateStr = "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
                timesByDate[dateStr] = [
                  _cleanTime(timings['Fajr']),
                  _cleanTime(timings['Sunrise']),
                  _cleanTime(timings['Dhuhr']),
                  _cleanTime(timings['Asr']),
                  _cleanTime(timings['Maghrib']),
                  _cleanTime(timings['Isha']),
                ];
              }
            }
          }

          if (timesByDate.isNotEmpty) {
            _saveTimesToCache(cacheKey, timesByDate);
            return Times(timesByDate: timesByDate);
          }
        }
      }
    } catch (e) {
      debugPrint("Diyanet Aylık Namaz Vakti API hatası ($cleanCity): $e");
    }

    // 2. Öncelik: Tek günlük vakit çekme fallback
    try {
      final url = 'https://api.aladhan.com/v1/timingsByCity?city=$encodedCity&country=$encodedCountry&method=13';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['data'] != null && jsonData['data']['timings'] != null) {
          final Map<String, dynamic> timings = jsonData['data']['timings'];

          final List<String> prayerTimes = [
            _cleanTime(timings['Fajr']),
            _cleanTime(timings['Sunrise']),
            _cleanTime(timings['Dhuhr']),
            _cleanTime(timings['Asr']),
            _cleanTime(timings['Maghrib']),
            _cleanTime(timings['Isha']),
          ];

          final Map<String, List<String>> singleDayMap = {todayStr: prayerTimes};
          _saveTimesToCache(cacheKey, singleDayMap);
          return Times(timesByDate: singleDayMap);
        }
      }
    } catch (e) {
      debugPrint("Diyanet Tek Günlük Namaz Vakti API hatası ($cleanCity): $e");
    }

    // 3. Öncelik: İnternet yoksa Önbellekten (SharedPreferences) yükleme
    debugPrint("Offline mode: $cleanCity için önbellek kontrol ediliyor.");
    final cachedTimesMap = await _loadTimesFromCache(cacheKey);
    if (cachedTimesMap != null && cachedTimesMap.isNotEmpty) {
      if (cachedTimesMap.containsKey(todayStr)) {
        debugPrint("Offline mode: $cleanCity için bugünün önbellek vakitleri başarıyla yüklendi.");
        return Times(timesByDate: cachedTimesMap);
      } else {
        final closestKey = _getClosestDateKey(cachedTimesMap.keys.toList(), todayStr);
        final closestTimes = cachedTimesMap[closestKey]!;
        debugPrint("Offline mode: $cleanCity için $closestKey tarihli önbellek vakitleri kullanılıyor.");
        return Times(timesByDate: {todayStr: closestTimes, ...cachedTimesMap});
      }
    }

    // 4. Son Fallback: Önbellek bulunamadıysa seçilen şehre göre ofsetli vakitler
    debugPrint("Önbellek bulunamadı. $cleanCity için şehir ofsetli fallback vakitleri kullanılıyor.");
    List<String> baseTimes = ["04:15", "05:52", "13:12", "16:58", "20:21", "21:51"];
    int cityOffset = _getCityOffsetInMinutes(cleanCity);
    List<String> adjustedTimes = _adjustTimesByOffset(baseTimes, cityOffset);

    Map<String, List<String>> fallbackTimes = {
      todayStr: adjustedTimes
    };
    return Times(timesByDate: fallbackTimes);
  }

  Future<void> _saveTimesToCache(String cacheKey, Map<String, List<String>> timesByDate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingJson = prefs.getString(cacheKey);
      Map<String, List<String>> mergedMap = Map.from(timesByDate);
      if (existingJson != null && existingJson.isNotEmpty) {
        try {
          final Map<String, dynamic> decoded = jsonDecode(existingJson);
          decoded.forEach((k, v) {
            if (v is List && !mergedMap.containsKey(k)) {
              mergedMap[k] = List<String>.from(v.map((e) => e.toString()));
            }
          });
        } catch (_) {}
      }
      await prefs.setString(cacheKey, jsonEncode(mergedMap));
      await prefs.setString('prayer_times_cache_latest', jsonEncode(mergedMap));
    } catch (e) {
      debugPrint("Önbellek kaydetme hatası: $e");
    }
  }

  Future<Map<String, List<String>>?> _loadTimesFromCache(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? cachedJson = prefs.getString(cacheKey);
      cachedJson ??= prefs.getString('prayer_times_cache_latest');

      if (cachedJson != null && cachedJson.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(cachedJson);
        Map<String, List<String>> result = {};
        decoded.forEach((key, value) {
          if (value is List) {
            result[key] = List<String>.from(value.map((e) => e.toString()));
          }
        });
        if (result.isNotEmpty) return result;
      }
    } catch (e) {
      debugPrint("Önbellek okuma hatası: $e");
    }
    return null;
  }

  String _getClosestDateKey(List<String> dates, String targetDateStr) {
    if (dates.isEmpty) return targetDateStr;
    if (dates.contains(targetDateStr)) return targetDateStr;

    DateTime target = DateTime.tryParse(targetDateStr) ?? DateTime.now();
    String closest = dates.first;
    int minDiff = 999999999;

    for (String dStr in dates) {
      DateTime? d = DateTime.tryParse(dStr);
      if (d != null) {
        int diff = d.difference(target).inSeconds.abs();
        if (diff < minDiff) {
          minDiff = diff;
          closest = dStr;
        }
      }
    }
    return closest;
  }

  int _getCityOffsetInMinutes(String cityName) {
    final name = _normalizeCityName(cityName).toLowerCase().trim();
    switch (name) {
      case 'istanbul': return 0;
      case 'ankara': return -10;
      case 'izmir': return 6;
      case 'bursa': return 1;
      case 'antalya': return -2;
      case 'adana': return -14;
      case 'konya': return -11;
      case 'gaziantep': return -22;
      case 'sanliurfa': return -27;
      case 'kocaeli': return -3;
      case 'mersin': return -15;
      case 'diyarbakir': return -33;
      case 'samsun': return -17;
      case 'denizli': return 3;
      case 'eskisehir': return -4;
      case 'trabzon': return -27;
      case 'erzurum': return -37;
      case 'malatya': return -26;
      case 'kahramanmaras': return -20;
      case 'van': return -47;
      default: return 0;
    }
  }

  List<String> _adjustTimesByOffset(List<String> baseTimes, int offsetMinutes) {
    if (offsetMinutes == 0) return baseTimes;
    return baseTimes.map((timeStr) {
      final parts = timeStr.split(':').map((e) => int.tryParse(e) ?? 0).toList();
      if (parts.length < 2) return timeStr;
      int totalMinutes = parts[0] * 60 + parts[1] + offsetMinutes;
      if (totalMinutes < 0) totalMinutes += 1440;
      totalMinutes %= 1440;
      final h = (totalMinutes ~/ 60).toString().padLeft(2, '0');
      final m = (totalMinutes % 60).toString().padLeft(2, '0');
      return "$h:$m";
    }).toList();
  }

  String _cleanTime(dynamic timeStr) {
    if (timeStr == null) return "00:00";
    String s = timeStr.toString().trim();
    if (s.contains(' ')) {
      s = s.split(' ')[0];
    }
    return s;
  }

  static const Map<String, String> _apiHeaders = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'application/json',
  };

  // Diyanet Meal Resmi Ayet API (Al-Quran Cloud Diyanet Meali)
  Future<Map<String, String>?> fetchDiyanetAyet([int? ayahNumber]) async {
    try {
      final now = DateTime.now();
      final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
      final targetAyah = ayahNumber ?? ((dayOfYear * 17) % 6236 + 1);

      final url = 'https://api.alquran.cloud/v1/ayah/$targetAyah/editions/quran-uthmani,tr.diyanet';
      final response = await http.get(Uri.parse(url), headers: _apiHeaders).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['data'] != null && jsonData['data'] is List && (jsonData['data'] as List).length >= 2) {
          final arabicData = jsonData['data'][0];
          final diyanetData = jsonData['data'][1];

          final String arabicText = arabicData['text'] ?? '';
          final String diyanetText = diyanetData['text'] ?? '';
          final String surahName = diyanetData['surah']?['englishName'] ?? 'Sûre';
          final int numberInSurah = diyanetData['numberInSurah'] ?? 1;

          return {
            'arabic': arabicText,
            'turkish': diyanetText,
            'source': "$surahName Sûresi, $numberInSurah. Âyet (Diyanet Meali)",
          };
        }
      }
    } catch (e) {
      debugPrint("Diyanet Ayet API hatası: $e");
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> fetchHadithCategories() async {
    try {
      const url = 'https://hadeethenc.com/api/v1/categories/list/?language=tr';
      debugPrint("🚀 [HADITH CATEGORIES API] Request: $url");
      final response = await http.get(Uri.parse(url), headers: _apiHeaders).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);
        final result = list.map((item) => {
          'id': item['id'].toString(),
          'title': item['title'].toString(),
          'count': item['hadeeths_count'] ?? 0,
          'parent_id': item['parent_id']?.toString(),
        }).toList();

        debugPrint("✅ [HADITH CATEGORIES API] Fetched ${result.length} categories!");
        if (result.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cached_hadith_categories', jsonEncode(result));
          return result;
        }
      }
    } catch (e) {
      debugPrint("❌ [HADITH CATEGORIES API Error]: $e");
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cached = prefs.getString('cached_hadith_categories');
      if (cached != null && cached.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cached);
        if (decoded.isNotEmpty) {
          return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (_) {}

    return [];
  }

  Future<List<Map<String, dynamic>>> fetchHadithsByCategory(String categoryId, {int perPage = 20, int page = 1}) async {
    final cacheKey = 'cached_hadiths_cat_${categoryId}_p$page';
    try {
      final url = 'https://hadeethenc.com/api/v1/hadeeths/list/?language=tr&category_id=$categoryId&per_page=$perPage&page=$page';
      debugPrint("🚀 [HADITH LIST API] Requesting HadeethEnc Page $page: $url");
      final response = await http.get(Uri.parse(url), headers: _apiHeaders).timeout(const Duration(seconds: 4));
      debugPrint("📥 [HADITH LIST API] Response Code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        if (jsonMap['data'] != null && jsonMap['data'] is List) {
          final List<dynamic> items = jsonMap['data'];
          final result = items.map((item) => {
            'id': item['id'].toString(),
            'title': item['title'].toString(),
          }).toList();

          debugPrint("✅ [HADITH LIST API] Fetched ${result.length} hadiths (Page $page)!");
          if (result.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(cacheKey, jsonEncode(result));
            return result;
          }
        }
      }
    } catch (e) {
      debugPrint("⚠️ [HADITH LIST API] HadeethEnc DNS engeline takıldı: $e. Engelsiz Canlı Hadis API'sine geçiliyor...");
    }

    return await fetchPopularOrAllHadiths(page: page);
  }

  Future<Map<String, dynamic>?> fetchHadithDetail(String hadithId) async {
    final cacheKey = 'cached_hadith_detail_$hadithId';
    try {
      final url = 'https://hadeethenc.com/api/v1/hadeeths/one/?language=tr&id=$hadithId';
      final response = await http.get(Uri.parse(url), headers: _apiHeaders).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final Map<String, dynamic> item = json.decode(response.body);
        final turkishText = (item['hadeeth'] != null && item['hadeeth'].toString().isNotEmpty)
            ? item['hadeeth'].toString()
            : (item['title'] ?? '');
        final arabicText = (item['hadeeth_ar'] != null && item['hadeeth_ar'].toString().isNotEmpty)
            ? item['hadeeth_ar'].toString()
            : (item['title'] ?? '');

        final result = {
          'id': item['id'].toString(),
          'turkish': turkishText,
          'arabic': arabicText,
          'source': item['attribution'] ?? 'Hadis-i Şerif [HadeethEnc API]',
          'explanation': item['explanation'] ?? '',
          'grade': item['grade'] ?? '',
        };

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, jsonEncode(result));
        return result;
      }
    } catch (e) {
      debugPrint("Hadis detay çekme hatası ($hadithId): $e");
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cached = prefs.getString(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        return Map<String, dynamic>.from(jsonDecode(cached));
      }
    } catch (_) {}

    return null;
  }

  Future<List<Map<String, dynamic>>> fetchPopularOrAllHadiths({int page = 1}) async {
    // 1. Önce HadeethEnc API'yi dene
    try {
      final url = 'https://hadeethenc.com/api/v1/hadeeths/list/?language=tr&category_id=646&per_page=20&page=$page';
      final response = await http.get(Uri.parse(url), headers: _apiHeaders).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        if (jsonMap['data'] != null && jsonMap['data'] is List) {
          final List<dynamic> items = jsonMap['data'];
          final result = items.map((item) => {
            'id': item['id'].toString(),
            'turkish': item['title'].toString(),
            'arabic': '',
            'source': 'Hadis-i Şerif [HadeethEnc CANLI API]',
            'explanation': '',
          }).toList();

          if (result.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('cached_popular_hadiths_p$page', jsonEncode(result));
            return result;
          }
        }
      }
    } catch (e) {
      debugPrint("⚠️ HadeethEnc DNS engeli: $e. Türkiye Engelsiz Canlı Hadis API'sine geçiliyor...");
    }

    // 2. Türkiye Operatörlerinde %100 Engelsiz Çalışan Canlı Buhârî Hadis API'si (jsDelivr CDN API)
    try {
      const url = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/tur-bukhari.json';
      debugPrint("🚀 [ENGELSİZ CANLI HADİS API] İstek atılıyor (Sayfa $page): $url");
      final response = await http.get(Uri.parse(url), headers: _apiHeaders).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        if (jsonMap['hadiths'] != null && jsonMap['hadiths'] is List) {
          final List<dynamic> rawHadiths = jsonMap['hadiths'];
          final offset = (page - 1) * 20 + 1;
          final items = rawHadiths.skip(offset).take(20).toList();
          final result = items.map((item) => {
            'id': item['hadithnumber'].toString(),
            'turkish': item['text'].toString(),
            'arabic': '',
            'source': "Sahîh-i Buhârî, Hadis No: ${item['hadithnumber']} [Engelsiz Canlı API]",
            'explanation': '',
          }).toList();

          debugPrint("✅ [ENGELSİZ CANLI HADİS API] ${result.length} adet CANLI HADİS çekildi (Sayfa $page)!");
          if (result.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('cached_popular_hadiths_p$page', jsonEncode(result));
            return result;
          }
        }
      }
    } catch (e) {
      debugPrint("❌ Engelsiz Canlı Hadis API Hatası: $e");
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cached = prefs.getString('cached_popular_hadiths_p$page');
      if (cached != null && cached.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cached);
        if (decoded.isNotEmpty) {
          return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (_) {}

    return [];
  }

  // Canlı Hadis Çekme (Günün Hadisi için API entegrasyonu)
  Future<Map<String, String>?> fetchLiveHadis() async {
    try {
      final now = DateTime.now();
      final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
      // Popüler ve bilinen Türkçe hadis ID'leri
      final sampleIds = ["5913", "5907", "6208", "6274", "6275", "8402", "3410", "6258", "15"];
      final targetId = sampleIds[dayOfYear % sampleIds.length];

      final detail = await fetchHadithDetail(targetId);
      if (detail != null && detail['turkish']!.toString().isNotEmpty) {
        return {
          'title': "Günün Hadisi",
          'arabic': detail['arabic'].toString(),
          'turkish': detail['turkish'].toString(),
          'source': "${detail['source']} (${detail['grade']})",
        };
      }
    } catch (e) {
      debugPrint("Canlı Hadis API hatası: $e");
    }
    return null;
  }
}