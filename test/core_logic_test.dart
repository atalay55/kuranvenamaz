import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kuranvenamaz/core/httpcontroller.dart';
import 'package:kuranvenamaz/core/notificationservice.dart';
import 'package:kuranvenamaz/core/settings_service.dart';
import 'package:kuranvenamaz/core/utilities.dart';
import 'package:kuranvenamaz/entity/location.dart';
import 'package:kuranvenamaz/entity/namazvakitleri.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService.resolveChannelType', () {
    test('maps ezan and alarm to ezan channel, standart and legacy notification to standart', () {
      expect(NotificationService.resolveChannelType('ezan'), 'ezan');
      expect(NotificationService.resolveChannelType('alarm'), 'ezan');
      expect(NotificationService.resolveChannelType('standart'), 'standart');
      expect(NotificationService.resolveChannelType('notification'), 'standart');
    });
    test('schedules 2nd alarms even when all 1st alarms are turned off (regression test)', () async {
      SharedPreferences.setMockInitialValues({
        SettingsService.keyNotificationsEnabled: true,
        SettingsService.keySecondAlarmSoundType: 'ezan',
        SettingsService.keyDayPrayers: jsonEncode({
          '1': [], '2': [], '3': [], '4': [], '5': [], '6': [], '7': [],
        }),
        SettingsService.keyDaySecondPrayers: jsonEncode({
          '1': [1], '2': [1], '3': [1], '4': [1], '5': [1], '6': [1], '7': [1],
        }),
        SettingsService.keyPrayerSecondAlarmMinutes: jsonEncode({'1': -20}),
      });

      final settings = SettingsService();
      await settings.initSettings();

      final now = DateTime(2026, 11, 26, 12, 0);
      final times = Times(timesByDate: {
        '2026-11-26': ['05:54', '07:42', '12:12', '14:11', '16:32', '18:15'],
        '2026-11-27': ['05:55', '07:43', '12:13', '14:11', '16:32', '18:14'],
      });

      final plan = NotificationService.buildSevenDaySchedulePlan(
        times: times,
        settings: settings,
        now: now,
      );

      // Today's 07:22 is in the past relative to 12:00, so remaining 6 days (days 1..6) must be scheduled!
      expect(plan.length, 6);
      expect(plan.first['id'], 3011); // 3000 + dayOffset(1)*10 + prayerIndex(1=Güneş)
      expect(plan.first['channelType'], 'ezan');
      expect(plan.first['scheduledDate'], DateTime(2026, 11, 27, 7, 23));
    });
  });

  group('SettingsService', () {
    test('migrates legacy notification soundType to standart and normalizes positive offsets', () async {
      SharedPreferences.setMockInitialValues({
        SettingsService.keySoundType: 'notification',
        SettingsService.keyFirstAlarmMinutes: 10,
        SettingsService.keySecondAlarmMinutes: 20,
        SettingsService.keyCalculationMethod: 'fazilet',
      });

      final settings = SettingsService();
      await settings.initSettings();

      expect(settings.soundType, 'standart');
      expect(settings.calculationMethod, 'fazilet');
      expect(settings.getFirstAlarmMinutes(), -10);
      expect(settings.getSecondAlarmMinutes(), -20);
    });
  });

  group('HttpController', () {
    test('normalizeTurkish converts Turkish characters consistently', () {
      expect(HttpController.normalizeTurkish('İstanbul'), 'Istanbul');
      expect(HttpController.normalizeTurkish('Şanlıurfa'), 'Sanliurfa');
      expect(HttpController.normalizeTurkish('Çanakkale / Ödemiş / Ürgüp'), 'Canakkale / Odemis / Urgup');
    });

    test('parseDiyanetVakitler parses official 30-day Diyanet JSON format', () {
      final parsed = HttpController.parseDiyanetVakitler([
        {
          'MiladiTarihKisa': '21.11.2026',
          'Imsak': '06:21',
          'Gunes': '07:50',
          'Ogle': '12:55',
          'Ikindi': '15:23',
          'Aksam': '17:46',
          'Yatsi': '19:10',
        },
      ]);
      expect(parsed['2026-11-21'], ['06:21', '07:50', '12:55', '15:23', '17:46', '19:10']);
    });

    test('city-specific cache is returned immediately when present', () async {
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final berlinTimes = ['05:00', '06:30', '12:30', '15:30', '18:00', '19:45'];
      final istanbulTimes = ['06:00', '07:30', '13:00', '16:00', '18:30', '20:00'];

      SharedPreferences.setMockInitialValues({
        SettingsService.keyCalculationMethod: 'diyanet',
        'prayer_times_cache_diyanet_turkey_istanbul': jsonEncode({todayStr: istanbulTimes}),
        'prayer_times_cache_diyanet_germany_berlin': jsonEncode({todayStr: berlinTimes}),
        'prayer_times_cache_latest': jsonEncode({todayStr: istanbulTimes}),
      });

      final result = await HttpController().fetchPrayerTimesData('Germany', 'Berlin');
      expect(result.timesByDate[todayStr], berlinTimes);
    });
  });

  group('PrayerUtilities', () {
    test('getSonrakiVakitIsmi and kalanZamanHesapla handle empty and populated lists', () {
      final utils = PrayerUtilities();
      expect(utils.getSonrakiVakitIsmi([]), 'Vakit');
      expect(utils.kalanZamanHesapla([], Duration.zero), Duration.zero);

      final sample = [
        NamazVakitleri(vakitIsmi: 'İmsak', namazSaati: '00:01'),
        NamazVakitleri(vakitIsmi: 'Yatsı', namazSaati: '23:59'),
      ];
      final remaining = utils.kalanZamanHesapla(sample, Duration.zero);
      expect(remaining.inSeconds, greaterThanOrEqualTo(0));
    });
  });
}
