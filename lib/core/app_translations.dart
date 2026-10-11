import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTranslations extends Translations {
  static const String keyAppLocale = 'app_language_code';

  static const Locale defaultLocale = Locale('tr');
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
  ];

  static final ValueNotifier<String> currentLocaleNotifier = ValueNotifier<String>('tr');

  static Future<Locale> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(keyAppLocale);
    if (savedCode != null && savedCode.isNotEmpty) {
      currentLocaleNotifier.value = savedCode;
      return Locale(savedCode);
    }
    final deviceLocale = Get.deviceLocale?.languageCode ?? 'tr';
    if (['tr', 'en', 'de', 'ar'].contains(deviceLocale)) {
      currentLocaleNotifier.value = deviceLocale;
      return Locale(deviceLocale);
    }
    currentLocaleNotifier.value = 'tr';
    return defaultLocale;
  }

  static void init() {
    try {
      Get.addTranslations(AppTranslations().keys);
    } catch (_) {}
  }

  static String translate(String key, {String? fallback}) {
    try {
      final val = key.tr;
      if (val != key) return val;

      final code = Get.locale?.languageCode ?? 'tr';
      final map = AppTranslations().keys[code] ?? AppTranslations().keys['tr'];
      if (map != null && map.containsKey(key)) {
        return map[key]!;
      }
    } catch (_) {}
    return fallback ?? key;
  }

  static String get currentLanguageCode => Get.locale?.languageCode ?? 'tr';

  static String get quranEditionIdentifier {
    final code = currentLanguageCode;
    switch (code) {
      case 'de':
        return 'de.bubenheim';
      case 'en':
        return 'en.sahih';
      case 'ar':
        return 'ar.muyassar';
      default:
        return 'tr.diyanet';
    }
  }

  static String get hadithLanguageCode {
    final code = currentLanguageCode;
    if (['tr', 'en', 'de', 'ar'].contains(code)) return code;
    return 'tr';
  }

  static Future<void> changeLocale(String languageCode) async {
    final locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyAppLocale, languageCode);
    currentLocaleNotifier.value = languageCode;
    init();
    await Get.updateLocale(locale);
  }

  @override
  Map<String, Map<String, String>> get keys => {
        'tr': {
          'app_title': "Namaz ve Kur'an",
          'peace_guide': 'Huzur rehberiniz',
          'home': 'Ana Sayfa',
          'quran': "Kur'an-ı Kerim",
          'hadiths': 'Hadis-i Şerifler',
          'dhikr': 'Zikirmatik',
          'qibla': 'Kıble Pusulası',
          'hijri_calendar': 'Hicri Takvim',
          'settings_adhan': 'Ayarlar & Ezan',
          'settings': 'Ayarlar',
          'app_settings': 'Uygulama Ayarları',
          'app_language': 'Uygulama Dili',
          'prayer_notifications_title': 'Namaz Vakti Bildirimleri',
          'prayer_notifications_desc': 'Namaz vakitlerinde ezan okunması ve vakit öncesi hatırlatmalar.',
          'enable_prayer_notifications': 'Namaz Bildirimlerini Aç',
          'enable_prayer_notifications_desc': 'Tüm ezan ve hatırlatma bildirimlerini aktif/pasif yapın.',
          'refresh': 'Yenile',
          'verse_of_day': 'Günün Ayeti',
          'hadith_of_day': 'Günün Hadisi',
          'prayer_of_day': 'Günün Duası',
          'copy': 'Kopyala',
          'copied': 'Kopyalandı',
          'copied_desc': '@title panoya kopyalandı.',
          'source': 'Kaynak',
          'allow': 'İzin Ver',
          'close': 'Kapat',
          'oem_banner_text': 'Ezan bildirimlerinin aksamaması için izin verin.',
          'change': 'Değiştir',
          'remaining_to': '@vakit Vaktine Kalan Süre',
          'hours': 'Saat',
          'minutes': 'Dakika',
          'seconds': 'Saniye',
          'imsak': 'İmsak',
          'gunes': 'Güneş',
          'ogle': 'Öğle',
          'ikindi': 'İkindi',
          'aksam': 'Akşam',
          'yatsi': 'Yatsı',
          'retry': 'Yeniden Dene',
          'failed_prayer_times': 'Namaz vakitleri alınamadı.',
          'vakit': 'Vakit',
          'language': 'Dil / Language',
          'select_language': 'Uygulama Dilini Seçin',
          'select_country': 'Ülke Seç',
          'select_city': 'Şehir Seç',
          'change_location': 'Şehir / Ülke Değiştir',
          'about': 'Hakkında',
          'arabic_and_translation': 'Arapça+Meal',
          'arabic': 'Arapça',
          'translation': 'Meal',
          'text_size': 'Metin Boyutu',
          'all': 'Tümü',
          'favorites': 'Favorilerim',
          'select_date_convert_hijri': 'Tarih Seç ve Hicriye Çevir',
          'important_religious_days': 'Önemli Dini Gün ve Geceler',
          'unlimited': 'Sınırsız',
          'round': 'Tur',
          'total_dhikr': 'Toplam Zikir',
          'tap': 'DOKUN',
          'reset_dhikr_title': 'Zikri Sıfırla',
          'reset_dhikr_desc': 'Zikir sayacını sıfırlamak istediğinize emin misiniz?',
          'cancel': 'İptal',
          'reset': 'Sıfırla',
          'vibration': 'Titreşim',
          'facing_qibla': 'KIBLE YÖNÜNDESİNİZ ✓',
          'qibla_angle': 'Kıble Açısı',
          'device_heading': 'Cihaz Yönü',
          'distance': 'Mesafe',
          'distance_to_kaaba': "Kâbe'ye Uzaklık",
          'daily_weekly_alarms_title': 'GÜNLÜK VE HAFTALIK VAKİT ALARMLARI',
          'alarm_schedule_title': 'Günlük Alarm ve Ezan Planı',
          'alarm_schedule_desc': 'Günü seçin; aşağıdaki 1. Ana Alarm (Vakit Girişi) ve 2. Yedek Alarm ayarlarını dilediğiniz gibi özelleştirin:',
          'prayer_count_badge': '@count Vakit',
          'alarms_off': 'Alarmlar Kapalı',
          'editing_day': 'Düzenlenen Gün: @day',
          'apply_all_days': 'Tüm Günlere Uygula',
          'apply_weekdays': 'Hafta İçi Uygula',
          'apply_weekends': 'Hafta Sonu Uygula',
          'turn_on_all_first': 'Tüm 1. Vakitleri Aç',
          'turn_on_all_second': 'Tüm 2. Alarmları Aç',
          'turn_off_all': 'Tümünü Kapat',
          'applied_all_days_msg': '@day alarmları (1. ve 2. Alarmlar) tüm 7 güne uygulandı!',
          'applied_weekdays_msg': '@day alarmları Hafta İçi (Pzt-Cum) günlerine uygulandı!',
          'applied_weekends_msg': '@day alarmları Hafta Sonu (Cmt-Paz) günlerine uygulandı!',
          'first_alarm': '1. Alarm',
          'second_alarm_backup': '2. Alarm (Yedek)',
          'exact_time': 'Tam Vakit',
          'first_alarm_saved_msg': '✅ 1. Alarm: @time (@sound) kaydedildi!',
          'second_alarm_saved_msg': '✅ 2. Alarm: @time (@sound) kaydedildi!',
          'device_custom_sounds_title': 'Telefondaki Kendi Alarm Sesleri',
          'device_custom_sounds_desc': 'Telefonunuzdaki hazır alarm ve zil seslerinden seçmek için dokunun.',
          'discard': 'Vazgeç',
          'save': 'Kaydet',
          'alarm_timing_label': 'Alarm Zamanı:',
          'before_prayer_label': 'Vakitten Önce',
          'minutes_before_label': 'Dakika Önce',
          'quick_options': 'Hızlı Seçenekler:',
          'custom_minute': 'Özel Dakika:',
          'minutes_unit': 'dakika',
          'alarm_ringtone_label': 'Alarm Zil Sesi:',
          'second_alarm_sound_type_label': '2. Alarm Ses Türü:',
          'sound_adhan_title': '🕌 Ezan Sesi İle Okunsun',
          'sound_adhan_desc': 'Namaz vaktinde sesli ezan okunur.',
          'sound_notification_title': '🔔 Standart Bildirim Tonu',
          'sound_notification_desc': 'Cihazınızın standart bildirim sesi verilir.',
          'sound_alarm_title': '⏰ Yüksek Sesli Çalar Saat',
          'sound_alarm_title_recommended': '⏰ Yüksek Sesli Çalar Saat (Önerilen)',
          'sound_alarm_desc': 'Uyanmak için kesintisiz çalar saat tonu.',
          'sound_second_adhan_desc': 'İkinci alarmda da ezan sesi çalar.',
          'apply_to_all_prayers': 'Tüm namaz vakitlerine uygula',
          'apply_to_all_first_desc': 'İşaretlenirse bu dakika ve ses ayarı tüm vakitlerin 1. alarmına uygulanır.',
          'apply_to_all_second_desc': 'İşaretlenirse bu dakika ve ses ayarı tüm vakitlerin 2. alarmına uygulanır.',
          'notifications_checking': 'Bildirim ayarları kontrol ediliyor...',
          'notifications_active_ok': 'Bildirimler Aktif ✓',
          'notifications_active_ok_desc': 'Ezan ve namaz vakti bildirimleri sorunsuz çalışacak.',
          'first_alarm_dialog_title': '@name İçin 1. Alarm Ayarları',
          'first_alarm_dialog_title_general': '1. Alarm (Ana Alarm) Ayarları',
          'first_alarm_dialog_desc': 'Alarm saatini (tam vakit veya önce) ve ses tercihinizi belirleyin.',
          'second_alarm_dialog_title': '@name İçin 2. Alarm Ayarları',
          'second_alarm_dialog_desc': 'Alarm saatini (tam vakit veya önce) ve ses tercihinizi belirleyin.',
          'reminder_before_dialog_desc': 'Vakit girmeden önce hatırlatmanın kaç dakika önce yapılacağını belirleyin.',
          'exact_time_info': 'Namaz vakti tam girdiğinde alarm veya ezan çalar (0 dakika).',
        },
        'en': {
          'app_title': 'Prayer & Quran',
          'peace_guide': 'Your guide to tranquility',
          'home': 'Home',
          'quran': 'Holy Quran',
          'hadiths': 'Hadiths',
          'dhikr': 'Tasbih Counter',
          'qibla': 'Qibla Compass',
          'hijri_calendar': 'Hijri Calendar',
          'settings_adhan': 'Settings & Adhan',
          'settings': 'Settings',
          'app_settings': 'App Settings',
          'app_language': 'App Language',
          'prayer_notifications_title': 'Prayer Time Notifications',
          'prayer_notifications_desc': 'Adhan audio and reminders before prayer times.',
          'enable_prayer_notifications': 'Enable Prayer Notifications',
          'enable_prayer_notifications_desc': 'Toggle all adhan and reminder notifications.',
          'refresh': 'Refresh',
          'verse_of_day': 'Verse of the Day',
          'hadith_of_day': 'Hadith of the Day',
          'prayer_of_day': 'Supplication of the Day',
          'copy': 'Copy',
          'copied': 'Copied',
          'copied_desc': '@title copied to clipboard.',
          'source': 'Source',
          'allow': 'Allow',
          'close': 'Close',
          'oem_banner_text': 'Allow background permissions for uninterrupted Adhan alarms.',
          'change': 'Change',
          'remaining_to': 'Time Remaining to @vakit',
          'hours': 'Hours',
          'minutes': 'Minutes',
          'seconds': 'Seconds',
          'imsak': 'Fajr',
          'gunes': 'Sunrise',
          'ogle': 'Dhuhr',
          'ikindi': 'Asr',
          'aksam': 'Maghrib',
          'yatsi': 'Isha',
          'retry': 'Retry',
          'failed_prayer_times': 'Could not load prayer times.',
          'vakit': 'Prayer',
          'language': 'Language',
          'select_language': 'Select App Language',
          'select_country': 'Select Country',
          'select_city': 'Select City',
          'change_location': 'Change City / Country',
          'about': 'About',
          'arabic_and_translation': 'Arabic+Translation',
          'arabic': 'Arabic',
          'translation': 'Translation',
          'text_size': 'Text Size',
          'all': 'All',
          'favorites': 'Favorites',
          'select_date_convert_hijri': 'Select Date & Convert to Hijri',
          'important_religious_days': 'Important Islamic Days & Nights',
          'unlimited': 'Infinite',
          'round': 'Round',
          'total_dhikr': 'Total Dhikr',
          'tap': 'TAP',
          'reset_dhikr_title': 'Reset Counter',
          'reset_dhikr_desc': 'Are you sure you want to reset the tasbih counter?',
          'cancel': 'Cancel',
          'reset': 'Reset',
          'vibration': 'Vibration',
          'facing_qibla': 'FACING QIBLA ✓',
          'qibla_angle': 'Qibla Angle',
          'device_heading': 'Heading',
          'distance': 'Distance',
          'distance_to_kaaba': 'Distance to Kaaba',
          'daily_weekly_alarms_title': 'DAILY & WEEKLY PRAYER ALARMS',
          'alarm_schedule_title': 'Daily Alarm & Adhan Schedule',
          'alarm_schedule_desc': 'Select a day; customize the 1st Main Alarm (Prayer Time) and 2nd Backup Alarm below:',
          'prayer_count_badge': '@count Prayers',
          'alarms_off': 'Alarms Off',
          'editing_day': 'Editing Day: @day',
          'apply_all_days': 'Apply to All Days',
          'apply_weekdays': 'Apply to Weekdays',
          'apply_weekends': 'Apply to Weekends',
          'turn_on_all_first': 'Turn On All 1st Alarms',
          'turn_on_all_second': 'Turn On All 2nd Alarms',
          'turn_off_all': 'Turn All Off',
          'applied_all_days_msg': '@day alarms (1st & 2nd) applied to all 7 days!',
          'applied_weekdays_msg': '@day alarms applied to weekdays (Mon-Fri)!',
          'applied_weekends_msg': '@day alarms applied to weekends (Sat-Sun)!',
          'first_alarm': '1st Alarm',
          'second_alarm_backup': '2nd Alarm (Backup)',
          'exact_time': 'Exact Time',
          'first_alarm_saved_msg': '✅ 1st Alarm: @time (@sound) saved!',
          'second_alarm_saved_msg': '✅ 2nd Alarm: @time (@sound) saved!',
          'device_custom_sounds_title': 'Device Alarm Sounds',
          'device_custom_sounds_desc': 'Tap to select from built-in device alarm and ringtones.',
          'discard': 'Cancel',
          'save': 'Save',
          'alarm_timing_label': 'Alarm Timing:',
          'before_prayer_label': 'Before Prayer',
          'minutes_before_label': 'Minutes Before',
          'quick_options': 'Quick Options:',
          'custom_minute': 'Custom Minutes:',
          'minutes_unit': 'minutes',
          'alarm_ringtone_label': 'Alarm Ringtone:',
          'second_alarm_sound_type_label': '2nd Alarm Sound Type:',
          'sound_adhan_title': '🕌 Play Adhan Audio',
          'sound_adhan_desc': 'Audible adhan recites at prayer time.',
          'sound_notification_title': '🔔 Standard Notification Tone',
          'sound_notification_desc': 'Your device standard notification sound is played.',
          'sound_alarm_title': '⏰ Loud Alarm Ringtone',
          'sound_alarm_title_recommended': '⏰ Loud Alarm Ringtone (Recommended)',
          'sound_alarm_desc': 'Continuous loud alarm tone to wake up.',
          'sound_second_adhan_desc': 'Adhan sound also plays on the second alarm.',
          'apply_to_all_prayers': 'Apply to all prayer times',
          'apply_to_all_first_desc': 'If checked, this minute and sound setting will apply to 1st alarm of all prayers.',
          'apply_to_all_second_desc': 'If checked, this minute and sound setting will apply to 2nd alarm of all prayers.',
          'notifications_checking': 'Checking notification settings...',
          'notifications_active_ok': 'Notifications Active ✓',
          'notifications_active_ok_desc': 'Adhan and prayer time alarms will work reliably.',
          'first_alarm_dialog_title': '1st Alarm Settings for @name',
          'first_alarm_dialog_title_general': '1st Alarm (Main Alarm) Settings',
          'first_alarm_dialog_desc': 'Set the alarm timing (exact or before) and sound preference.',
          'second_alarm_dialog_title': '2nd Alarm Settings for @name',
          'second_alarm_dialog_desc': 'Set the alarm timing (exact or before) and sound preference.',
          'reminder_before_dialog_desc': 'Set how many minutes before prayer time the reminder will trigger.',
          'exact_time_info': 'Alarm or adhan plays exactly at prayer time (0 minutes).',
        },
        'de': {
          'app_title': 'Gebet & Koran',
          'peace_guide': 'Ihr Leitfaden zur Ruhe',
          'home': 'Startseite',
          'quran': 'Heiliger Koran',
          'hadiths': 'Hadithe',
          'dhikr': 'Tasbih Zähler',
          'qibla': 'Qibla-Kompass',
          'hijri_calendar': 'Hidschri-Kalender',
          'settings_adhan': 'Einstellungen & Gebetsruf',
          'settings': 'Einstellungen',
          'app_settings': 'App-Einstellungen',
          'app_language': 'App-Sprache',
          'prayer_notifications_title': 'Gebetszeit-Benachrichtigungen',
          'prayer_notifications_desc': 'Gebetsruf-Audio und Erinnerungen vor den Gebetszeiten.',
          'enable_prayer_notifications': 'Gebetsbenachrichtigungen aktivieren',
          'enable_prayer_notifications_desc': 'Alle Gebetsruf- und Erinnerungsbenachrichtigungen ein-/ausschalten.',
          'refresh': 'Aktualisieren',
          'verse_of_day': 'Vers des Tages',
          'hadith_of_day': 'Hadith des Tages',
          'prayer_of_day': 'Bittgebet des Tages',
          'copy': 'Kopieren',
          'copied': 'Kopiert',
          'copied_desc': '@title in Zwischenablage kopiert.',
          'source': 'Quelle',
          'allow': 'Erlauben',
          'close': 'Schließen',
          'oem_banner_text': 'Berechtigungen erteilen, damit Gebetsrufe zuverlässig funktionieren.',
          'change': 'Ändern',
          'remaining_to': 'Verbleibende Zeit bis @vakit',
          'hours': 'Std',
          'minutes': 'Min',
          'seconds': 'Sek',
          'imsak': 'Fadschr',
          'gunes': 'Sonnenaufgang',
          'ogle': 'Zuhr',
          'ikindi': 'Asr',
          'aksam': 'Maghrib',
          'yatsi': 'Ischa',
          'retry': 'Wiederholen',
          'failed_prayer_times': 'Gebetszeiten konnten nicht geladen werden.',
          'vakit': 'Gebet',
          'language': 'Sprache',
          'select_language': 'App-Sprache wählen',
          'select_country': 'Land wählen',
          'select_city': 'Stadt wählen',
          'change_location': 'Stadt / Land ändern',
          'about': 'Über',
          'arabic_and_translation': 'Arabisch+Übersetzung',
          'arabic': 'Arabisch',
          'translation': 'Übersetzung',
          'text_size': 'Textgröße',
          'all': 'Alle',
          'favorites': 'Favoriten',
          'select_date_convert_hijri': 'Datum wählen & in Hidschri umrechnen',
          'important_religious_days': 'Wichtige islamische Fest- & Feiertage',
          'unlimited': 'Endlos',
          'round': 'Runde',
          'total_dhikr': 'Gesamt-Dhikr',
          'tap': 'TIPPEN',
          'reset_dhikr_title': 'Zähler zurücksetzen',
          'reset_dhikr_desc': 'Möchten Sie den Tasbih-Zähler wirklich zurücksetzen?',
          'cancel': 'Abbrechen',
          'reset': 'Zurücksetzen',
          'vibration': 'Vibration',
          'facing_qibla': 'IN QIBLA-RICHTUNG ✓',
          'qibla_angle': 'Qibla-Winkel',
          'device_heading': 'Geräterichtung',
          'distance': 'Distanz',
          'distance_to_kaaba': 'Entfernung zur Kaaba',
          'daily_weekly_alarms_title': 'TÄGLICHE & WÖCHENTLICHE GEBETSALARME',
          'alarm_schedule_title': 'Täglicher Alarm- & Gebetsrufplan',
          'alarm_schedule_desc': 'Wählen Sie einen Tag; passen Sie den 1. Hauptalarm (Gebetszeit) und den 2. Ersatzalarm nach Bedarf an:',
          'prayer_count_badge': '@count Zeiten',
          'alarms_off': 'Alarme aus',
          'editing_day': 'Bearbeiteter Tag: @day',
          'apply_all_days': 'Auf alle Tage anwenden',
          'apply_weekdays': 'Auf Wochentage anwenden',
          'apply_weekends': 'Auf Wochenende anwenden',
          'turn_on_all_first': 'Alle 1. Alarme an',
          'turn_on_all_second': 'Alle 2. Alarme an',
          'turn_off_all': 'Alle ausschalten',
          'applied_all_days_msg': '@day-Alarme (1. & 2.) auf alle 7 Tage angewendet!',
          'applied_weekdays_msg': '@day-Alarme auf Wochentage (Mo-Fr) angewendet!',
          'applied_weekends_msg': '@day-Alarme auf das Wochenende (Sa-So) angewendet!',
          'first_alarm': '1. Alarm',
          'second_alarm_backup': '2. Alarm (Ersatz)',
          'exact_time': 'Pünktlich',
          'first_alarm_saved_msg': '✅ 1. Alarm: @time (@sound) gespeichert!',
          'second_alarm_saved_msg': '✅ 2. Alarm: @time (@sound) gespeichert!',
          'device_custom_sounds_title': 'Eigene Wecktöne des Geräts',
          'device_custom_sounds_desc': 'Tippen Sie hier, um Systemtöne und Wecktöne auszuwählen.',
          'discard': 'Abbrechen',
          'save': 'Speichern',
          'alarm_timing_label': 'Alarm-Zeitpunkt:',
          'before_prayer_label': 'Vor Gebetszeit',
          'minutes_before_label': 'Minuten vorher',
          'quick_options': 'Schnelloptionen:',
          'custom_minute': 'Benutzerdefiniert:',
          'minutes_unit': 'Minuten',
          'alarm_ringtone_label': 'Alarm-Klingelton:',
          'second_alarm_sound_type_label': '2. Alarm Tonart:',
          'sound_adhan_title': '🕌 Gebetsruf (Adhan) abspielen',
          'sound_adhan_desc': 'Hörbarer Gebetsruf ertönt zur Gebetszeit.',
          'sound_notification_title': '🔔 Standard-Benachrichtigungston',
          'sound_notification_desc': 'Der Standardton Ihres Geräts wird abgespielt.',
          'sound_alarm_title': '⏰ Lauter Weckerton',
          'sound_alarm_title_recommended': '⏰ Lauter Weckerton (Empfohlen)',
          'sound_alarm_desc': 'Durchgehender Alarmton zum Aufwachen.',
          'sound_second_adhan_desc': 'Gebetsruf ertönt auch beim zweiten Alarm.',
          'apply_to_all_prayers': 'Auf alle Gebetszeiten anwenden',
          'apply_to_all_first_desc': 'Wenn aktiviert, gilt diese Einstellung für den 1. Alarm aller Gebete.',
          'apply_to_all_second_desc': 'Wenn aktiviert, gilt diese Einstellung für den 2. Alarm aller Gebete.',
          'notifications_checking': 'Benachrichtigungseinstellungen werden geprüft...',
          'notifications_active_ok': 'Benachrichtigungen aktiv ✓',
          'notifications_active_ok_desc': 'Gebetsruf und Benachrichtigungen funktionieren zuverlässig.',
          'first_alarm_dialog_title': '1. Alarm-Einstellungen für @name',
          'first_alarm_dialog_title_general': '1. Alarm (Hauptalarm) Einstellungen',
          'first_alarm_dialog_desc': 'Legen Sie den Alarmzeitpunkt (pünktlich oder vorher) und den Ton fest.',
          'second_alarm_dialog_title': '2. Alarm-Einstellungen für @name',
          'second_alarm_dialog_desc': 'Legen Sie den Alarmzeitpunkt (pünktlich oder vorher) und den Ton fest.',
          'reminder_before_dialog_desc': 'Legen Sie fest, wie viele Minuten vor Gebetszeit die Erinnerung ertönen soll.',
          'exact_time_info': 'Alarm oder Gebetsruf ertönt genau zur Gebetszeit (0 Minuten).',
        },
        'ar': {
          'app_title': 'الصلاة والقرآن',
          'peace_guide': 'دليلك إلى الطمأنينة',
          'home': 'الرئيسية',
          'quran': 'القرآن الكريم',
          'hadiths': 'الأحاديث الشريفة',
          'dhikr': 'المسبحة الإلكترونية',
          'qibla': 'بوصلة القبلة',
          'hijri_calendar': 'التقويم الهجري',
          'settings_adhan': 'الإعدادات والأذان',
          'settings': 'الإعدادات',
          'app_settings': 'إعدادات التطبيق',
          'app_language': 'لغة التطبيق',
          'prayer_notifications_title': 'تنبيهات أوقات الصلاة',
          'prayer_notifications_desc': 'الأذان والتنبيهات قبل دخول أوقات الصلاة.',
          'enable_prayer_notifications': 'تفعيل تنبيهات الصلاة',
          'enable_prayer_notifications_desc': 'تفعيل أو تعطيل جميع تنبيهات الأذان والتذكير.',
          'refresh': 'تحديث',
          'verse_of_day': 'آية اليوم',
          'hadith_of_day': 'حديث اليوم',
          'prayer_of_day': 'دعاء اليوم',
          'copy': 'نسخ',
          'copied': 'تم النسخ',
          'copied_desc': 'تم نسخ @title إلى الحافظة.',
          'source': 'المصدر',
          'allow': 'السماح',
          'close': 'إغلاق',
          'oem_banner_text': 'يرجى تفعيل أذونات الخلفية لضمان عمل تنبيهات الأذان بانتظام.',
          'change': 'تغيير',
          'remaining_to': 'الوقت المتبقي لـ @vakit',
          'hours': 'ساعة',
          'minutes': 'دقيقة',
          'seconds': 'ثانية',
          'imsak': 'الفجر',
          'gunes': 'الشروق',
          'ogle': 'الظهر',
          'ikindi': 'العصر',
          'aksam': 'المغرب',
          'yatsi': 'العشاء',
          'retry': 'إعادة المحاولة',
          'failed_prayer_times': 'تعذر تحميل أوقات الصلاة.',
          'vakit': 'الصلاة',
          'language': 'اللغة',
          'select_language': 'اختر لغة التطبيق',
          'select_country': 'اختر الدولة',
          'select_city': 'اختر المدينة',
          'change_location': 'تغيير المدينة / الدولة',
          'about': 'عن التطبيق',
          'arabic_and_translation': 'العربية + الترجمة',
          'arabic': 'العربية',
          'translation': 'الترجمة',
          'text_size': 'حجم الخط',
          'all': 'الكل',
          'favorites': 'المفضلة',
          'select_date_convert_hijri': 'اختر التاريخ وتحويله إلى الهجري',
          'important_religious_days': 'المناسبات الدينية الهامة',
          'unlimited': 'بلا حدود',
          'round': 'جولة',
          'total_dhikr': 'إجمالي الأذكار',
          'tap': 'اضغط',
          'reset_dhikr_title': 'إعادة ضبط العداد',
          'reset_dhikr_desc': 'هل أنت متأكد من رغبتك في إعادة ضبط عداد التسبيح؟',
          'cancel': 'إلغاء',
          'reset': 'إعادة ضبط',
          'vibration': 'الاهتزاز',
          'facing_qibla': 'أنت باتجاه القبلة ✓',
          'qibla_angle': 'زاوية القبلة',
          'device_heading': 'اتجاه الجهاز',
          'distance': 'المسافة',
          'distance_to_kaaba': 'المسافة إلى الكعبة',
          'daily_weekly_alarms_title': 'تنبيهات الصلاة اليومية والأسبوعية',
          'alarm_schedule_title': 'جدول الأذان والتنبيهات اليومي',
          'alarm_schedule_desc': 'اختر اليوم؛ خصص التنبيه الأول (وقت الصلاة) والتنبيه الاحتياطي الثاني حسب رغبتك:',
          'prayer_count_badge': '@count صلوات',
          'alarms_off': 'التنبيهات معطلة',
          'editing_day': 'اليوم المحدد: @day',
          'apply_all_days': 'تطبيق على جميع الأيام',
          'apply_weekdays': 'تطبيق على أيام العمل',
          'apply_weekends': 'تطبيق على عطلة نهاية الأسبوع',
          'turn_on_all_first': 'تفعيل كل التنبيهات الأولى',
          'turn_on_all_second': 'تفعيل كل التنبيهات الثانية',
          'turn_off_all': 'إيقاف الكل',
          'applied_all_days_msg': 'تم تطبيق تنبيهات @day على جميع الأيام السبعة!',
          'applied_weekdays_msg': 'تم تطبيق تنبيهات @day على أيام العمل!',
          'applied_weekends_msg': 'تم تطبيق تنبيهات @day على عطلة نهاية الأسبوع!',
          'first_alarm': 'التنبيه 1',
          'second_alarm_backup': 'التنبيه 2 (احتياطي)',
          'exact_time': 'في الوقت المحدد',
          'first_alarm_saved_msg': '✅ تم حفظ التنبيه 1: @time (@sound)!',
          'second_alarm_saved_msg': '✅ تم حفظ التنبيه 2: @time (@sound)!',
          'device_custom_sounds_title': 'نغمات تنبيه الهاتف',
          'device_custom_sounds_desc': 'اضغط لاختيار نغمات التنبيه من الهاتف.',
          'discard': 'إلغاء',
          'save': 'حفظ',
          'alarm_timing_label': 'وقت التنبيه:',
          'before_prayer_label': 'قبل الوقت',
          'minutes_before_label': 'دقائق قبل',
          'quick_options': 'خيارات سريعة:',
          'custom_minute': 'دقائق مخصصة:',
          'minutes_unit': 'دقيقة',
          'alarm_ringtone_label': 'نغمة التنبيه:',
          'second_alarm_sound_type_label': 'نوع صوت التنبيه الثاني:',
          'sound_adhan_title': '🕌 تشغيل صوت الأذان',
          'sound_adhan_desc': 'يرفع الأذان بصوت مسموع عند وقت الصلاة.',
          'sound_notification_title': '🔔 نغمة إشعار عادية',
          'sound_notification_desc': 'يتم تشغيل نغمة الإشعار الافتراضية للجهاز.',
          'sound_alarm_title': '⏰ منبه بصوت عالٍ',
          'sound_alarm_title_recommended': '⏰ منبه بصوت عالٍ (مستحسن)',
          'sound_alarm_desc': 'نغمة منبه متواصلة للاستيقاظ.',
          'sound_second_adhan_desc': 'يرفع صوت الأذان أيضاً في التنبيه الثاني.',
          'apply_to_all_prayers': 'تطبيق على جميع أوقات الصلاة',
          'apply_to_all_first_desc': 'إذا تم التحديد، سيتم تطبيق هذه الإعدادات على التنبيه الأول لجميع الصلوات.',
          'apply_to_all_second_desc': 'إذا تم التحديد، سيتم تطبيق هذه الإعدادات على التنبيه الثاني لجميع الصلوات.',
          'notifications_checking': 'جاري فحص إعدادات التنبيهات...',
          'notifications_active_ok': 'التنبيهات مفعلة ✓',
          'notifications_active_ok_desc': 'ستعمل تنبيهات الأذان والصلوات بشكل منتظم وموثوق.',
          'first_alarm_dialog_title': 'إعدادات التنبيه الأول لـ @name',
          'first_alarm_dialog_title_general': 'إعدادات التنبيه الأول (الرئيسي)',
          'first_alarm_dialog_desc': 'حدد وقت التنبيه (في الوقت أو قبله) وخيار الصوت.',
          'second_alarm_dialog_title': 'إعدادات التنبيه الثاني لـ @name',
          'second_alarm_dialog_desc': 'حدد وقت التنبيه (في الوقت أو قبله) وخيار الصوت.',
          'reminder_before_dialog_desc': 'حدد عدد الدقائق قبل دخول الوقت ليتم التذكير.',
          'exact_time_info': 'يرن المنبه أو يرفع الأذان عند دخول وقت الصلاة تماماً (0 دقيقة).',
        },
      };

  /// Haftanın 7 gününü aktif dile göre döndürür
  static List<Map<String, dynamic>> getWeekDays() {
    final code = currentLanguageCode;
    switch (code) {
      case 'de':
        return const [
          {'id': 1, 'short': 'Mo', 'full': 'Montag'},
          {'id': 2, 'short': 'Di', 'full': 'Dienstag'},
          {'id': 3, 'short': 'Mi', 'full': 'Mittwoch'},
          {'id': 4, 'short': 'Do', 'full': 'Donnerstag'},
          {'id': 5, 'short': 'Fr', 'full': 'Freitag'},
          {'id': 6, 'short': 'Sa', 'full': 'Samstag'},
          {'id': 7, 'short': 'So', 'full': 'Sonntag'},
        ];
      case 'en':
        return const [
          {'id': 1, 'short': 'Mon', 'full': 'Monday'},
          {'id': 2, 'short': 'Tue', 'full': 'Tuesday'},
          {'id': 3, 'short': 'Wed', 'full': 'Wednesday'},
          {'id': 4, 'short': 'Thu', 'full': 'Thursday'},
          {'id': 5, 'short': 'Fri', 'full': 'Friday'},
          {'id': 6, 'short': 'Sat', 'full': 'Saturday'},
          {'id': 7, 'short': 'Sun', 'full': 'Sunday'},
        ];
      case 'ar':
        return const [
          {'id': 1, 'short': 'اثن', 'full': 'الإثنين'},
          {'id': 2, 'short': 'ثلا', 'full': 'الثلاثاء'},
          {'id': 3, 'short': 'أرب', 'full': 'الأربعاء'},
          {'id': 4, 'short': 'خمي', 'full': 'الخميس'},
          {'id': 5, 'short': 'جمع', 'full': 'الجمعة'},
          {'id': 6, 'short': 'سبت', 'full': 'السبت'},
          {'id': 7, 'short': 'أحد', 'full': 'الأحد'},
        ];
      default:
        return const [
          {'id': 1, 'short': 'Pzt', 'full': 'Pazartesi'},
          {'id': 2, 'short': 'Sal', 'full': 'Salı'},
          {'id': 3, 'short': 'Çar', 'full': 'Çarşamba'},
          {'id': 4, 'short': 'Per', 'full': 'Perşembe'},
          {'id': 5, 'short': 'Cum', 'full': 'Cuma'},
          {'id': 6, 'short': 'Cmt', 'full': 'Cumartesi'},
          {'id': 7, 'short': 'Paz', 'full': 'Pazar'},
        ];
    }
  }

  /// Alarm planındaki 6 vaktin localized ismini döndürür
  static String getPrayerScheduleName(int index, {String? defaultName}) {
    final code = currentLanguageCode;
    switch (index) {
      case 0:
        if (code == 'de') return 'Fadschr (Morgengebet)';
        if (code == 'en') return 'Fajr (Dawn)';
        if (code == 'ar') return 'الفجر';
        return 'İmsak (Sabah)';
      case 1:
        if (code == 'de') return 'Sonnenaufgang';
        if (code == 'en') return 'Sunrise';
        if (code == 'ar') return 'الشروق';
        return 'Güneş';
      case 2:
        if (code == 'de') return 'Zuhr';
        if (code == 'en') return 'Dhuhr';
        if (code == 'ar') return 'الظهر';
        return 'Öğle';
      case 3:
        if (code == 'de') return 'Asr';
        if (code == 'en') return 'Asr';
        if (code == 'ar') return 'العصر';
        return 'İkindi';
      case 4:
        if (code == 'de') return 'Maghrib';
        if (code == 'en') return 'Maghrib';
        if (code == 'ar') return 'المغرب';
        return 'Akşam';
      case 5:
        if (code == 'de') return 'Ischa';
        if (code == 'en') return 'Isha';
        if (code == 'ar') return 'العشاء';
        return 'Yatsı';
      default:
        return defaultName ?? 'Vakit';
    }
  }

  /// Ses türünün etiketini dile göre döndürür
  static String getSoundTypeLabel(String type) {
    final code = currentLanguageCode;
    if (type == 'ezan') {
      if (code == 'de') return '🕌 Gebetsruf';
      if (code == 'en') return '🕌 Adhan';
      if (code == 'ar') return '🕌 أذان';
      return '🕌 Ezan';
    }
    if (type == 'alarm') {
      if (code == 'ar') return '⏰ منبه';
      return '⏰ Alarm';
    }
    if (code == 'de') return '🔔 Benachrichtigung';
    if (code == 'en') return '🔔 Notification';
    if (code == 'ar') return '🔔 إشعار';
    return '🔔 Bildirim';
  }

  /// Alarm zaman bilgisini (15 dk önce, Tam Vakit vs.) dile göre döndürür
  static String getTimingLabel(int minutes) {
    final code = currentLanguageCode;
    if (minutes == 0) {
      if (code == 'de') return 'Pünktlich';
      if (code == 'en') return 'Exact Time';
      if (code == 'ar') return 'في الوقت المحدد';
      return 'Tam Vakit';
    }
    final abs = minutes.abs();
    if (code == 'de') return '$abs Min vorher';
    if (code == 'en') return '$abs min before';
    if (code == 'ar') return 'قبل $abs دقيقة';
    return '$abs dk önce';
  }

  /// Vakit ismini aktif dile göre çevirir
  static String getLocalizedPrayerName(String rawVakit) {
    final lower = rawVakit.toLowerCase().trim();
    if (lower.contains('imsak') || lower.contains('fajr')) return 'imsak'.tr;
    if (lower.contains('güneş') || lower.contains('gunes') || lower.contains('sunrise')) return 'gunes'.tr;
    if (lower.contains('öğle') || lower.contains('ogle') || lower.contains('dhuhr') || lower.contains('zuhr')) return 'ogle'.tr;
    if (lower.contains('ikindi') || lower.contains('asr')) return 'ikindi'.tr;
    if (lower.contains('akşam') || lower.contains('aksam') || lower.contains('maghrib')) return 'aksam'.tr;
    if (lower.contains('yatsı') || lower.contains('yatsi') || lower.contains('isha')) return 'yatsi'.tr;
    return rawVakit;
  }

  /// Günün Ayeti / Hadisi / Duası kart başlıklarını çevirir
  static String getLocalizedCardTitle(String rawTitle) {
    final lower = rawTitle.toLowerCase();
    if (lower.contains('ayet')) return 'verse_of_day'.tr;
    if (lower.contains('hadis')) return 'hadith_of_day'.tr;
    if (lower.contains('dua')) return 'prayer_of_day'.tr;
    return rawTitle;
  }

  /// Ülke adını dile göre sadeleştirip güzelleştirir (Almanya (Germany) -> Almanya / Germany / Deutschland)
  static String getLocalizedCountryName(String rawCountry) {
    if (!rawCountry.contains('(') || !rawCountry.contains(')')) {
      return rawCountry;
    }

    final match = RegExp(r'^(.*?)\s*\((.*?)\)').firstMatch(rawCountry);
    if (match == null) return rawCountry;

    final trName = match.group(1)?.trim() ?? rawCountry;
    final enName = match.group(2)?.trim() ?? rawCountry;
    final code = Get.locale?.languageCode ?? 'tr';

    if (code == 'en') return enName;
    if (code == 'de') {
      if (enName.toLowerCase().contains('germany') || trName.toLowerCase().contains('almanya')) {
        return 'Deutschland';
      }
      if (enName.toLowerCase().contains('turkey') || trName.toLowerCase().contains('türkiye')) {
        return 'Türkei';
      }
      if (enName.toLowerCase().contains('france') || trName.toLowerCase().contains('fransa')) {
        return 'Frankreich';
      }
      if (enName.toLowerCase().contains('austria') || trName.toLowerCase().contains('avusturya')) {
        return 'Österreich';
      }
      if (enName.toLowerCase().contains('switzerland') || trName.toLowerCase().contains('isviçre')) {
        return 'Schweiz';
      }
      if (enName.toLowerCase().contains('netherlands') || trName.toLowerCase().contains('hollanda')) {
        return 'Niederlande';
      }
      return enName;
    }
    if (code == 'ar') {
      if (enName.toLowerCase().contains('germany') || trName.toLowerCase().contains('almanya')) {
        return 'ألمانيا';
      }
      if (enName.toLowerCase().contains('turkey') || trName.toLowerCase().contains('türkiye')) {
        return 'تركيا';
      }
      if (enName.toLowerCase().contains('france') || trName.toLowerCase().contains('fransa')) {
        return 'فرنسا';
      }
      if (enName.toLowerCase().contains('saudi') || trName.toLowerCase().contains('suudi')) {
        return 'المملكة العربية السعودية';
      }
      return enName;
    }
    return trName;
  }
}
