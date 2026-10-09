import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String keyNotificationsEnabled = 'settings_notifications_enabled';
  static const String keyEzanEnabled = 'settings_ezan_enabled';
  static const String keyPreNotificationEnabled = 'settings_pre_notification_enabled';
  static const String keyNotificationTiming = 'settings_notification_timing'; // minutes before prayer time
  static const String keySoundType = 'settings_sound_type'; // 'ezan' or 'notification'
  static const String keyAskedPrompt = 'settings_asked_notification_prompt';
  static const String keyOemBannerDismissed = 'settings_oem_banner_dismissed';
  static const String keyDayPrayers = 'settings_day_prayers'; // json string: {"1":[0,2,3,4,5], ...}
  static const String keyFirstAlarmMinutes = 'settings_first_alarm_minutes'; // Default 0: Tam vakit (negatif: önce, pozitif: sonra)
  static const String keyPrayerFirstAlarmMinutes = 'settings_prayer_first_alarm_minutes'; // json string: {"0": -15, "2": 0, ...}
  static const String keySecondAlarmEnabled = 'settings_second_alarm_enabled';
  static const String keySecondAlarmMinutes = 'settings_second_alarm_minutes';
  static const String keySecondAlarmSoundType = 'settings_second_alarm_sound_type';
  static const String keyDaySecondPrayers = 'settings_day_second_prayers'; // json string: {"1":[0], ...}
  static const String keyPrayerSecondAlarmMinutes = 'settings_prayer_second_alarm_minutes'; // json string: {"0": 20, "2": 15, ...}

  bool _notificationsEnabled = true;
  bool _ezanEnabled = true; // Tam namaz vaktinde bildirim/ezan çalma
  bool _preNotificationEnabled = true; // Vaktinden önce hatırlatma bildirimi
  int _notificationTimingMinutes = 15; // Default 15 dakika önce hatırlatma
  int _firstAlarmMinutes = 0; // Default 0: Tam vakit girişi (negatif: önce, pozitif: sonra)
  Map<int, int> _prayerFirstAlarmMinutes = {}; // Vakit bazlı 1. alarm dakikaları
  String _soundType = 'ezan'; // Default Ezan
  bool _askedPrompt = false;
  bool _oemBannerDismissed = false;

  // 2. Alarm (Yedek / Erteleme / Uyanma Güvencesi)
  bool _secondAlarmEnabled = true;
  int _secondAlarmMinutes = 15; // Genel / Varsayılan: Vakitten 15 dakika sonra çalar
  String _secondAlarmSoundType = 'alarm'; // 'alarm' (sesli zil) veya 'ezan'
  Map<int, int> _prayerSecondAlarmMinutes = {}; // Vakit bazlı özel dakikalar (0: İmsak, ...)

  // Her günün (1:Pzt ... 7:Paz) kendi aktif 1. namaz vakitleri (0:İmsak, 1:Güneş, 2:Öğle, 3:İkindi, 4:Akşam, 5:Yatsı)
  Map<int, Set<int>> _dayPrayers = {
    1: {0, 2, 3, 4, 5},
    2: {0, 2, 3, 4, 5},
    3: {0, 2, 3, 4, 5},
    4: {0, 2, 3, 4, 5},
    5: {0, 2, 3, 4, 5},
    6: {0, 2, 3, 4, 5},
    7: {0, 2, 3, 4, 5},
  };

  // Her günün (1:Pzt ... 7:Paz) kendi aktif 2. alarm vakitleri (Varsayılan: Sabah namazında 2. alarm açık)
  Map<int, Set<int>> _daySecondPrayers = {
    1: {0},
    2: {0},
    3: {0},
    4: {0},
    5: {0},
    6: {0},
    7: {0},
  };

  bool get notificationsEnabled => _notificationsEnabled;
  bool get ezanEnabled => _ezanEnabled;
  bool get preNotificationEnabled => _preNotificationEnabled;
  int get notificationTimingMinutes => _notificationTimingMinutes;
  int get firstAlarmMinutes => _firstAlarmMinutes;
  Map<int, int> get prayerFirstAlarmMinutes => Map.unmodifiable(_prayerFirstAlarmMinutes);
  String get soundType => _soundType;
  bool get askedPrompt => _askedPrompt;
  bool get oemBannerDismissed => _oemBannerDismissed;
  Map<int, Set<int>> get dayPrayers => Map.unmodifiable(_dayPrayers);

  int getFirstAlarmMinutes({int? prayerIndex}) {
    if (prayerIndex != null && _prayerFirstAlarmMinutes.containsKey(prayerIndex)) {
      return _prayerFirstAlarmMinutes[prayerIndex]!;
    }
    return _firstAlarmMinutes;
  }

  bool get secondAlarmEnabled => _secondAlarmEnabled;
  int get secondAlarmMinutes => _secondAlarmMinutes;
  String get secondAlarmSoundType => _secondAlarmSoundType;
  Map<int, Set<int>> get daySecondPrayers => Map.unmodifiable(_daySecondPrayers);
  Map<int, int> get prayerSecondAlarmMinutes => Map.unmodifiable(_prayerSecondAlarmMinutes);

  int getSecondAlarmMinutes({int? prayerIndex}) {
    if (prayerIndex != null && _prayerSecondAlarmMinutes.containsKey(prayerIndex)) {
      return _prayerSecondAlarmMinutes[prayerIndex]!;
    }
    return _secondAlarmMinutes;
  }

  Set<int> getPrayersForDay(int weekday) {
    return Set.from(_dayPrayers[weekday] ?? {0, 2, 3, 4, 5});
  }

  bool isPrayerEnabledForDay(int weekday, int prayerIndex) {
    return _dayPrayers[weekday]?.contains(prayerIndex) ?? false;
  }

  Set<int> getSecondPrayersForDay(int weekday) {
    return Set.from(_daySecondPrayers[weekday] ?? {0});
  }

  bool isSecondPrayerEnabledForDay(int weekday, int prayerIndex) {
    return _daySecondPrayers[weekday]?.contains(prayerIndex) ?? false;
  }

  Future<void> initSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(keyNotificationsEnabled) ?? true;
    _ezanEnabled = prefs.getBool(keyEzanEnabled) ?? true;
    _preNotificationEnabled = prefs.getBool(keyPreNotificationEnabled) ?? true;
    _notificationTimingMinutes = prefs.getInt(keyNotificationTiming) ?? 15;
    _soundType = prefs.getString(keySoundType) ?? 'ezan';
    _askedPrompt = prefs.getBool(keyAskedPrompt) ?? false;
    _oemBannerDismissed = prefs.getBool(keyOemBannerDismissed) ?? false;

    final dayPrayersJson = prefs.getString(keyDayPrayers);
    if (dayPrayersJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(dayPrayersJson);
        _dayPrayers = {};
        for (int d = 1; d <= 7; d++) {
          final list = decoded[d.toString()];
          if (list is List) {
            _dayPrayers[d] = list.map((e) => (e as num).toInt()).toSet();
          } else {
            _dayPrayers[d] = {0, 2, 3, 4, 5};
          }
        }
      } catch (e) {
        debugPrint("dayPrayers parse hatası: $e");
      }
    }

    _secondAlarmEnabled = prefs.getBool(keySecondAlarmEnabled) ?? true;
    _secondAlarmMinutes = prefs.getInt(keySecondAlarmMinutes) ?? 15;
    _secondAlarmSoundType = prefs.getString(keySecondAlarmSoundType) ?? 'alarm';

    final daySecondPrayersJson = prefs.getString(keyDaySecondPrayers);
    if (daySecondPrayersJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(daySecondPrayersJson);
        _daySecondPrayers = {};
        for (int d = 1; d <= 7; d++) {
          final list = decoded[d.toString()];
          if (list is List) {
            _daySecondPrayers[d] = list.map((e) => (e as num).toInt()).toSet();
          } else {
            _daySecondPrayers[d] = {0};
          }
        }
      } catch (e) {
        debugPrint("daySecondPrayers parse hatası: $e");
      }
    }

    final prayerSecondMinutesJson = prefs.getString(keyPrayerSecondAlarmMinutes);
    if (prayerSecondMinutesJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(prayerSecondMinutesJson);
        _prayerSecondAlarmMinutes = {};
        decoded.forEach((k, v) {
          final pIdx = int.tryParse(k);
          final m = (v as num).toInt();
          if (pIdx != null && m > 0) {
            _prayerSecondAlarmMinutes[pIdx] = m;
          }
        });
      } catch (e) {
        debugPrint("prayerSecondAlarmMinutes parse hatası: $e");
      }
    }

    _firstAlarmMinutes = prefs.getInt(keyFirstAlarmMinutes) ?? 0;
    final prayerFirstMinutesJson = prefs.getString(keyPrayerFirstAlarmMinutes);
    if (prayerFirstMinutesJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(prayerFirstMinutesJson);
        _prayerFirstAlarmMinutes = {};
        decoded.forEach((k, v) {
          final pIdx = int.tryParse(k);
          final m = (v as num).toInt();
          if (pIdx != null) {
            _prayerFirstAlarmMinutes[pIdx] = m;
          }
        });
      } catch (e) {
        debugPrint("prayerFirstAlarmMinutes parse hatası: $e");
      }
    }

    debugPrint("Settings initialized: enabled=$_notificationsEnabled, ezan=$_ezanEnabled (firstAlarm=$_firstAlarmMinutes dk, perPrayer=$_prayerFirstAlarmMinutes), preNotif=$_preNotificationEnabled, secondAlarm=$_secondAlarmEnabled (default +$_secondAlarmMinutes dk, perPrayer=$_prayerSecondAlarmMinutes), dayPrayers=$_dayPrayers, daySecondPrayers=$_daySecondPrayers");
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyNotificationsEnabled, enabled);
  }

  Future<void> setEzanEnabled(bool enabled) async {
    _ezanEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyEzanEnabled, enabled);
  }

  Future<void> setPreNotificationEnabled(bool enabled) async {
    _preNotificationEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyPreNotificationEnabled, enabled);
  }

  Future<void> setNotificationTiming(int minutes) async {
    _notificationTimingMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyNotificationTiming, minutes);
  }

  Future<void> setFirstAlarmMinutes(int minutes) async {
    _firstAlarmMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyFirstAlarmMinutes, minutes);
  }

  Future<void> setPrayerFirstAlarmMinutes(int prayerIndex, int minutes) async {
    _prayerFirstAlarmMinutes[prayerIndex] = minutes;
    final prefs = await SharedPreferences.getInstance();
    final Map<String, int> mapToSave = {};
    _prayerFirstAlarmMinutes.forEach((k, v) => mapToSave[k.toString()] = v);
    await prefs.setString(keyPrayerFirstAlarmMinutes, jsonEncode(mapToSave));
  }

  Future<void> setAllPrayersFirstAlarmMinutes(int minutes) async {
    _firstAlarmMinutes = minutes;
    _prayerFirstAlarmMinutes.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyFirstAlarmMinutes, minutes);
    await prefs.remove(keyPrayerFirstAlarmMinutes);
  }

  Future<void> setSoundType(String soundType) async {
    _soundType = soundType;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keySoundType, soundType);
  }

  Future<void> setSecondAlarmEnabled(bool enabled) async {
    _secondAlarmEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keySecondAlarmEnabled, enabled);
  }

  Future<void> setSecondAlarmMinutes(int minutes) async {
    _secondAlarmMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keySecondAlarmMinutes, minutes);
  }

  Future<void> setPrayerSecondAlarmMinutes(int prayerIndex, int minutes) async {
    _prayerSecondAlarmMinutes[prayerIndex] = minutes;
    final prefs = await SharedPreferences.getInstance();
    final Map<String, int> mapToSave = {};
    _prayerSecondAlarmMinutes.forEach((k, v) => mapToSave[k.toString()] = v);
    await prefs.setString(keyPrayerSecondAlarmMinutes, jsonEncode(mapToSave));
  }

  Future<void> setAllPrayersSecondAlarmMinutes(int minutes) async {
    _secondAlarmMinutes = minutes;
    _prayerSecondAlarmMinutes.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keySecondAlarmMinutes, minutes);
    await prefs.remove(keyPrayerSecondAlarmMinutes);
  }

  Future<void> setSecondAlarmSoundType(String soundType) async {
    _secondAlarmSoundType = soundType;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keySecondAlarmSoundType, soundType);
  }

  Future<void> setPrayersForDay(int weekday, Set<int> prayers) async {
    _dayPrayers[weekday] = Set.from(prayers);
    await _saveDayPrayers();
  }

  Future<void> setDayPrayersMap(Map<int, Set<int>> map) async {
    _dayPrayers = Map.from(map);
    await _saveDayPrayers();
  }

  Future<void> setSecondPrayersForDay(int weekday, Set<int> prayers) async {
    _daySecondPrayers[weekday] = Set.from(prayers);
    await _saveDaySecondPrayers();
  }

  Future<void> setDaySecondPrayersMap(Map<int, Set<int>> map) async {
    _daySecondPrayers = Map.from(map);
    await _saveDaySecondPrayers();
  }

  Future<void> copyDayToAll(int sourceWeekday) async {
    final source = _dayPrayers[sourceWeekday] ?? {0, 2, 3, 4, 5};
    final sourceSecond = _daySecondPrayers[sourceWeekday] ?? {0};
    for (int d = 1; d <= 7; d++) {
      _dayPrayers[d] = Set.from(source);
      _daySecondPrayers[d] = Set.from(sourceSecond);
    }
    await _saveDayPrayers();
    await _saveDaySecondPrayers();
  }

  Future<void> copyDayToWeekdays(int sourceWeekday) async {
    final source = _dayPrayers[sourceWeekday] ?? {0, 2, 3, 4, 5};
    final sourceSecond = _daySecondPrayers[sourceWeekday] ?? {0};
    for (int d = 1; d <= 5; d++) {
      _dayPrayers[d] = Set.from(source);
      _daySecondPrayers[d] = Set.from(sourceSecond);
    }
    await _saveDayPrayers();
    await _saveDaySecondPrayers();
  }

  Future<void> copyDayToWeekend(int sourceWeekday) async {
    final source = _dayPrayers[sourceWeekday] ?? {0, 2, 3, 4, 5};
    final sourceSecond = _daySecondPrayers[sourceWeekday] ?? {0};
    _dayPrayers[6] = Set.from(source);
    _dayPrayers[7] = Set.from(source);
    _daySecondPrayers[6] = Set.from(sourceSecond);
    _daySecondPrayers[7] = Set.from(sourceSecond);
    await _saveDayPrayers();
    await _saveDaySecondPrayers();
  }

  Future<void> _saveDayPrayers() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, List<int>> mapToSave = {};
    _dayPrayers.forEach((day, prayers) {
      mapToSave[day.toString()] = prayers.toList();
    });
    await prefs.setString(keyDayPrayers, jsonEncode(mapToSave));
  }

  Future<void> _saveDaySecondPrayers() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, List<int>> mapToSave = {};
    _daySecondPrayers.forEach((day, prayers) {
      mapToSave[day.toString()] = prayers.toList();
    });
    await prefs.setString(keyDaySecondPrayers, jsonEncode(mapToSave));
  }

  Future<void> setAskedPrompt(bool asked) async {
    _askedPrompt = asked;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyAskedPrompt, asked);
  }

  Future<void> setOemBannerDismissed(bool dismissed) async {
    _oemBannerDismissed = dismissed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyOemBannerDismissed, dismissed);
  }
}
