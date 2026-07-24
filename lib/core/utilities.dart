import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kuranvenamaz/core/notificationservice.dart';
import 'package:kuranvenamaz/core/widget_service.dart';
import 'package:kuranvenamaz/entity/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../entity/namazvakitleri.dart';
import 'httpcontroller.dart';

class Utilities {
  var width = Get.width;
  var height = Get.height;
}

class PrayerUtilities {
  late SharedPreferences prefs;

  String? country;
  String? city;

  Future<List<String>> getCityAndCountry() async {
    prefs = await SharedPreferences.getInstance();
    country = prefs.getString("country") ?? "";
    city = prefs.getString("city") ?? "";
    return [city!, country!];
  }

  List<String> namazSaatleri = [];
  Times? _fetchedTimes;

  Future<void> initializeData() async {
    try {
      prefs = await SharedPreferences.getInstance();
      country = prefs.getString("country") ?? "Turkey";
      city = prefs.getString("city") ?? "Istanbul";
      
      _fetchedTimes = await HttpController()
          .fetchPrayerTimesData(country.toString(), city.toString());
      final times = _fetchedTimes?.timesByDate ?? {};
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (times.containsKey(todayStr)) {
        namazSaatleri = times[todayStr]!;
      } else if (times.isNotEmpty) {
        namazSaatleri = times.values.first;
      } else {
        namazSaatleri = ["04:15", "05:52", "13:12", "16:58", "20:21", "21:51"];
      }

      if (_fetchedTimes != null) {
        NotificationService().reschedulePrayerNotifications(_fetchedTimes!).catchError((err) {
          debugPrint("Notification reschedule hatasi: $err");
        });
      }
    } catch (e) {
      debugPrint("initializeData hatası: $e");
      if (namazSaatleri.isEmpty) {
        namazSaatleri = ["04:15", "05:52", "13:12", "16:58", "20:21", "21:51"];
      }
    }
  }

  Future<List<NamazVakitleri>> getNamazVakitleri() async {
    List<String> namazVakitIsmi = [
      "İmsak",
      "Güneş",
      "Öğle",
      "İkindi",
      "Akşam",
      "Yatsı"
    ];
    List<NamazVakitleri> namazVakitleri = [];
    await initializeData();

    if (namazSaatleri.isEmpty) {
      namazSaatleri = ["04:15", "05:52", "13:12", "16:58", "20:21", "21:51"];
    }

    for (int i = 0; i < namazVakitIsmi.length && i < namazSaatleri.length; i++) {
      namazVakitleri.add(
        NamazVakitleri(
          namazSaati: namazSaatleri[i],
          vakitIsmi: namazVakitIsmi[i],
        ),
      );
    }

    try {
      final kalan = kalanZamanHesapla(namazVakitleri, Duration.zero);
      final sonraki = getSonrakiVakitIsmi(namazVakitleri);
      WidgetService.updateWidgetData(
        cityName: city ?? "Istanbul",
        countryName: country ?? "Turkey",
        vakitler: namazVakitleri,
        sonrakiVakitIsmi: sonraki,
        kalanSure: kalan,
      );
    } catch (e) {
      debugPrint("Widget senkronizasyon hatası: $e");
    }

    return namazVakitleri;
  }

  String getSonrakiVakitIsmi(List<NamazVakitleri> vakitler) {
    if (vakitler.isEmpty) return "Vakit";
    final now = DateTime.now();
    final currentSeconds = now.hour * 3600 + now.minute * 60 + now.second;

    for (var vakit in vakitler) {
      final parts = vakit.namazSaati.split(':').map((e) => int.tryParse(e) ?? 0).toList();
      if (parts.length < 2) continue;
      final vakitSeconds = parts[0] * 3600 + parts[1] * 60;
      if (vakitSeconds > currentSeconds) {
        return vakit.vakitIsmi;
      }
    }
    return vakitler.first.vakitIsmi;
  }

  Duration kalanZamanHesapla(
      List<NamazVakitleri> saatler, Duration kalanSure) {
    if (saatler.isEmpty) {
      return const Duration(seconds: 0);
    }

    final suankiZaman = DateTime.now();
    final suankiSaat = suankiZaman.hour * 3600 +
        suankiZaman.minute * 60 +
        suankiZaman.second;

    double enKucukFark = double.infinity;
    String enKucukSaat = "";

    for (final saat in saatler) {
      final saatDegerleri =
          saat.namazSaati.split(':').map((e) => int.tryParse(e) ?? 0).toList();
      if (saatDegerleri.length < 2) continue;

      final saatSaat = saatDegerleri[0] * 3600 + saatDegerleri[1] * 60;
      final fark = saatSaat - suankiSaat;

      if (fark >= 0 && fark < enKucukFark) {
        enKucukFark = fark.toDouble();
        enKucukSaat = saat.namazSaati;
      }
    }

    if (enKucukSaat.isNotEmpty) {
      final saatDegerleri =
          enKucukSaat.split(':').map((e) => int.tryParse(e) ?? 0).toList();
      final saatSaat = saatDegerleri[0] * 3600 + saatDegerleri[1] * 60;
      kalanSure = Duration(seconds: (saatSaat - suankiSaat).toInt());
      return kalanSure;
    } else {
      try {
        final ilkVakit = saatler.first.namazSaati.split(':').map((e) => int.tryParse(e) ?? 0).toList();
        final ertesiGuneSaniye = (24 * 3600 - suankiSaat) + (ilkVakit[0] * 3600 + ilkVakit[1] * 60);
        return Duration(seconds: ertesiGuneSaniye);
      } catch (_) {
        return const Duration(seconds: 0);
      }
    }
  }
}