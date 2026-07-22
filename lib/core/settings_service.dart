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

  bool _notificationsEnabled = true;
  bool _ezanEnabled = true; // Tam namaz vaktinde bildirim/ezan çalma
  bool _preNotificationEnabled = true; // Vaktinden önce hatırlatma bildirimi
  int _notificationTimingMinutes = 15; // Default 15 dakika önce hatırlatma
  String _soundType = 'ezan'; // Default Ezan
  bool _askedPrompt = false;
  bool _oemBannerDismissed = false;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get ezanEnabled => _ezanEnabled;
  bool get preNotificationEnabled => _preNotificationEnabled;
  int get notificationTimingMinutes => _notificationTimingMinutes;
  String get soundType => _soundType;
  bool get askedPrompt => _askedPrompt;
  bool get oemBannerDismissed => _oemBannerDismissed;

  Future<void> initSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(keyNotificationsEnabled) ?? true;
    _ezanEnabled = prefs.getBool(keyEzanEnabled) ?? true;
    _preNotificationEnabled = prefs.getBool(keyPreNotificationEnabled) ?? true;
    _notificationTimingMinutes = prefs.getInt(keyNotificationTiming) ?? 15;
    _soundType = prefs.getString(keySoundType) ?? 'ezan';
    _askedPrompt = prefs.getBool(keyAskedPrompt) ?? false;
    _oemBannerDismissed = prefs.getBool(keyOemBannerDismissed) ?? false;
    debugPrint("Settings initialized: enabled=$_notificationsEnabled, ezan=$_ezanEnabled, preNotif=$_preNotificationEnabled, timing=$_notificationTimingMinutes min, sound=$_soundType");
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

  Future<void> setSoundType(String soundType) async {
    _soundType = soundType;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keySoundType, soundType);
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
