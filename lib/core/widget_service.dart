import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import '../entity/namazvakitleri.dart';

class WidgetService {
  static const String androidWidgetProvider = 'NamazWidgetProvider';
  static const String iosWidgetName = 'NamazWidget';

  /// Ana ekran widget'ına verileri gönderir ve günceller
  static Future<void> updateWidgetData({
    required String cityName,
    required String countryName,
    required List<NamazVakitleri> vakitler,
    required String sonrakiVakitIsmi,
    required Duration kalanSure,
  }) async {
    try {
      // Şehir ve ülke bilgisi
      await HomeWidget.saveWidgetData<String>('city_name', cityName);
      await HomeWidget.saveWidgetData<String>('country_name', countryName);

      // Sıradaki vakit ve kalan süre
      await HomeWidget.saveWidgetData<String>('next_prayer_name', sonrakiVakitIsmi);
      
      final hours = kalanSure.inHours.toString().padLeft(2, '0');
      final minutes = (kalanSure.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (kalanSure.inSeconds % 60).toString().padLeft(2, '0');
      final remainingStr = "$hours:$minutes:$seconds";
      final remainingShortStr = "${hours}s ${minutes}dk";

      await HomeWidget.saveWidgetData<String>('remaining_time', remainingStr);
      await HomeWidget.saveWidgetData<String>('remaining_short', remainingShortStr);

      // 6 Namaz vakti saatleri
      String nextPrayerTime = "";
      for (final vakit in vakitler) {
        String key = _getVakitKey(vakit.vakitIsmi);
        if (key.isNotEmpty) {
          await HomeWidget.saveWidgetData<String>(key, vakit.namazSaati);
        }
        if (vakit.vakitIsmi == sonrakiVakitIsmi) {
          nextPrayerTime = vakit.namazSaati;
        }
      }
      await HomeWidget.saveWidgetData<String>('next_prayer_time', nextPrayerTime);

      // Widget'ı yenile
      await HomeWidget.updateWidget(
        androidName: androidWidgetProvider,
        iOSName: iosWidgetName,
      );

      // Üst bildirim çekmecesindeki kalıcı bildirimi namaz vakitleriyle güncelle
      try {
        const platform = MethodChannel('com.fatihatalay.kuranvenamaz/device_settings');
        final timesMap = <String, String>{};
        for (final v in vakitler) {
          timesMap[v.vakitIsmi.toLowerCase()] = v.namazSaati;
        }

        final hours = kalanSure.inHours.toString().padLeft(2, '0');
        final minutes = (kalanSure.inMinutes % 60).toString().padLeft(2, '0');
        final countdownFormatted = "$hours:$minutes";

        await platform.invokeMethod('updateForegroundNotification', {
          'city': cityName,
          'nextPrayer': sonrakiVakitIsmi,
          'nextPrayerTime': nextPrayerTime,
          'remaining': countdownFormatted,
          'imsak': timesMap['imsak'] ?? '',
          'gunes': timesMap['güneş'] ?? timesMap['gunes'] ?? '',
          'ogle': timesMap['öğle'] ?? timesMap['ogle'] ?? '',
          'ikindi': timesMap['ikindi'] ?? '',
          'aksam': timesMap['akşam'] ?? timesMap['aksam'] ?? '',
          'yatsi': timesMap['yatsı'] ?? timesMap['yatsi'] ?? '',
        });
      } catch (_) {}
    } catch (e) {
      debugPrint("WidgetService updateWidgetData hatası: $e");
    }
  }

  static String _getVakitKey(String vakitIsmi) {
    switch (vakitIsmi.toLowerCase()) {
      case 'imsak':
        return 'vakit_imsak';
      case 'güneş':
      case 'gunes':
        return 'vakit_gunes';
      case 'öğle':
      case 'ogle':
        return 'vakit_ogle';
      case 'ikindi':
        return 'vakit_ikindi';
      case 'akşam':
      case 'aksam':
        return 'vakit_aksam';
      case 'yatsı':
      case 'yatsi':
        return 'vakit_yatsi';
      default:
        return '';
    }
  }
}
