import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kuranvenamaz/entity/location.dart';

import '../entity/city.dart';
import '../entity/country.dart';

class HttpController {
  // Ülke listesi (Varsayılan olarak Türkiye ve popüler ülkeler)
  Future<List<Country>> fetchCountryJSONData() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.aladhan.com/v1/methods'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return [
          Country(code: 'TR', name: 'Turkey'),
          Country(code: 'DE', name: 'Germany'),
          Country(code: 'FR', name: 'France'),
          Country(code: 'NL', name: 'Netherlands'),
          Country(code: 'AZ', name: 'Azerbaijan'),
          Country(code: 'US', name: 'United States'),
          Country(code: 'GB', name: 'United Kingdom'),
          Country(code: 'SA', name: 'Saudi Arabia'),
        ];
      }
    } catch (e) {
      debugPrint("Country fetch error: $e");
    }

    return [
      Country(code: 'TR', name: 'Turkey'),
      Country(code: 'DE', name: 'Germany'),
      Country(code: 'AZ', name: 'Azerbaijan'),
    ];
  }

  // Şehir listesi
  Future<List<City>> fetchCities(String country) async {
    return [
      City('Istanbul'),
      City('Ankara'),
      City('Izmir'),
      City('Bursa'),
      City('Antalya'),
      City('Adana'),
      City('Konya'),
      City('Gaziantep'),
      City('Sanliurfa'),
      City('Kocaeli'),
      City('Mersin'),
      City('Diyarbakir'),
      City('Samsun'),
      City('Denizli'),
      City('Eskisehir'),
      City('Trabzon'),
      City('Erzurum'),
      City('Malatya'),
      City('Kahramanmaras'),
      City('Van'),
    ];
  }

  // Diyanet takvimine göre Namaz Vakitleri Alma (Aladhan Diyanet Method = 13)
  Future<Times> fetchPrayerTimesData(String country, String city) async {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final cleanCity = city.isEmpty ? 'Istanbul' : city;
    final cleanCountry = country.isEmpty ? 'Turkey' : country;

    try {
      // Diyanet takvimi hesabı için method=13 kullanılıyor
      final url = 'https://api.aladhan.com/v1/timingsByCity?city=$cleanCity&country=$cleanCountry&method=13';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['data'] != null && jsonData['data']['timings'] != null) {
          final Map<String, dynamic> timings = jsonData['data']['timings'];

          // [İmsak, Güneş, Öğle, İkindi, Akşam, Yatsı]
          final List<String> prayerTimes = [
            _cleanTime(timings['Fajr']),
            _cleanTime(timings['Sunrise']),
            _cleanTime(timings['Dhuhr']),
            _cleanTime(timings['Asr']),
            _cleanTime(timings['Maghrib']),
            _cleanTime(timings['Isha']),
          ];

          Map<String, List<String>> timesByDate = {};
          timesByDate[todayStr] = prayerTimes;

          return Times(timesByDate: timesByDate);
        }
      }
    } catch (e) {
      debugPrint("Diyanet Namaz Vakti API hatası: $e");
    }

    // İnternet olmaması durumunda güvenli Diyanet ortalama vakitleri fallback
    debugPrint("Fallback varsayılan vakitler kullanılıyor.");
    Map<String, List<String>> fallbackTimes = {
      todayStr: ["04:15", "05:52", "13:12", "16:58", "20:21", "21:51"]
    };
    return Times(timesByDate: fallbackTimes);
  }

  String _cleanTime(dynamic timeStr) {
    if (timeStr == null) return "00:00";
    String s = timeStr.toString().trim();
    if (s.contains(' ')) {
      s = s.split(' ')[0];
    }
    return s;
  }

  // Diyanet Meal Resmi Ayet API (Al-Quran Cloud Diyanet Meali)
  Future<Map<String, String>?> fetchDiyanetAyet([int? ayahNumber]) async {
    try {
      final now = DateTime.now();
      final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
      final targetAyah = ayahNumber ?? ((dayOfYear * 17) % 6236 + 1);

      final url = 'https://api.alquran.cloud/v1/ayah/$targetAyah/editions/quran-uthmani,tr.diyanet';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

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
}