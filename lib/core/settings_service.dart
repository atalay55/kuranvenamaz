import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String keyNotificationsEnabled = 'settings_notifications_enabled';
  static const String keyNotificationTiming = 'settings_notification_timing'; // minutes before prayer time
  static const String keySoundType = 'settings_sound_type'; // 'ezan' or 'notification'
  static const String keyAskedPrompt = 'settings_asked_notification_prompt';

  bool _notificationsEnabled = true;
  int _notificationTimingMinutes = 1; // Default 1 minute before prayer as requested
  String _soundType = 'ezan'; // Default Ezan
  bool _askedPrompt = false;

  bool get notificationsEnabled => _notificationsEnabled;
  int get notificationTimingMinutes => _notificationTimingMinutes;
  String get soundType => _soundType;
  bool get askedPrompt => _askedPrompt;

  Future<void> initSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(keyNotificationsEnabled) ?? true;
    _notificationTimingMinutes = prefs.getInt(keyNotificationTiming) ?? 1;
    _soundType = prefs.getString(keySoundType) ?? 'ezan';
    _askedPrompt = prefs.getBool(keyAskedPrompt) ?? false;
    debugPrint("Settings initialized: enabled=$_notificationsEnabled, timing=$_notificationTimingMinutes min, sound=$_soundType, askedPrompt=$_askedPrompt");
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyNotificationsEnabled, enabled);
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
}
