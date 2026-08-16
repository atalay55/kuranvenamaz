import 'dart:io';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Cihazın bildirim izin durumunu tutan model.
/// Paket + native channel verilerini birleştirir.
class NotificationPermissionStatus {
  final bool notificationsEnabled;
  final bool batteryOptimizationIgnored;
  final bool exactAlarmAllowed;
  final String manufacturer;
  final String model;
  final int androidVersion;

  const NotificationPermissionStatus({
    required this.notificationsEnabled,
    required this.batteryOptimizationIgnored,
    required this.exactAlarmAllowed,
    required this.manufacturer,
    required this.model,
    required this.androidVersion,
  });

  /// Tüm kritik izinler tamam mı?
  bool get isFullyConfigured =>
      notificationsEnabled && batteryOptimizationIgnored && exactAlarmAllowed;

  /// Xiaomi / Redmi / POCO ailesi mi?
  bool get isXiaomi {
    final m = manufacturer.toLowerCase();
    return m.contains('xiaomi') || m.contains('redmi') || m.contains('poco');
  }

  /// Agresif pil yönetimi olan OEM mi?
  bool get isRestrictiveOEM {
    final m = manufacturer.toLowerCase();
    return m.contains('xiaomi') ||
        m.contains('redmi') ||
        m.contains('poco') ||
        m.contains('huawei') ||
        m.contains('honor') ||
        m.contains('oppo') ||
        m.contains('vivo') ||
        m.contains('realme') ||
        m.contains('oneplus') ||
        m.contains('samsung');
  }
}

class DeviceSettingsService {
  /// Sadece native channel üzerinden ulaşabileceğimiz bilgiler için
  static const MethodChannel _channel =
      MethodChannel('com.fatihatalay.kuranvenamaz/device_settings');

  // ─── İzin Durumu Kontrolü ───────────────────────────────────────────────

  /// Tüm bildirim izinlerinin durumunu tek seferde kontrol et.
  /// Pil optimizasyonu için `disable_battery_optimization` paketini kullanır.
  static Future<NotificationPermissionStatus?> checkNotificationPermissions() async {
    if (!Platform.isAndroid) return null;
    try {
      // 1. disable_battery_optimization paketi ile pil durumu
      final bool batteryOk =
          await DisableBatteryOptimization.isBatteryOptimizationDisabled ?? true;

      // 2. Native channel üzerinden diğer bilgiler
      final Map<dynamic, dynamic> result =
          await _channel.invokeMethod('checkNotificationPermissions');

      return NotificationPermissionStatus(
        notificationsEnabled: result['notificationsEnabled'] as bool? ?? true,
        batteryOptimizationIgnored: batteryOk,
        exactAlarmAllowed: result['exactAlarmAllowed'] as bool? ?? true,
        manufacturer: result['manufacturer'] as String? ?? 'Unknown',
        model: result['model'] as String? ?? 'Unknown',
        androidVersion: result['androidVersion'] as int? ?? 0,
      );
    } catch (e) {
      debugPrint("checkNotificationPermissions error: $e");
      return null;
    }
  }

  static Future<String> getDeviceManufacturer() async {
    try {
      final String manufacturer =
          await _channel.invokeMethod('getDeviceManufacturer');
      return manufacturer;
    } catch (e) {
      debugPrint("getDeviceManufacturer error: $e");
      return "Unknown";
    }
  }

  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      return await DisableBatteryOptimization.isBatteryOptimizationDisabled ??
          true;
    } catch (e) {
      debugPrint("isIgnoringBatteryOptimizations error: $e");
      return true;
    }
  }

  // ─── Ayarlar Açma ───────────────────────────────────────────────────────

  /// Xiaomi / OEM otomatik başlatma ayarları.
  /// disable_battery_optimization paketi kendi dialog + intent zincirini kullanır.
  static Future<void> openAutostartSettings() async {
    try {
      await DisableBatteryOptimization.showEnableAutoStartSettings(
        "Otomatik Başlatma",
        "Kuran ve Namaz uygulamasının arka planda çalışabilmesi için bu ayarı açmanız gerekiyor.",
      );
    } catch (e) {
      debugPrint("openAutostartSettings error: $e");
      // Fallback: native channel üzerinden dene
      try {
        await _channel.invokeMethod('openAutostartSettings');
      } catch (_) {}
    }
  }

  /// Pil optimizasyonunu kapat.
  /// Standart Android sistem dialogunu açar (kullanıcı sadece "İzin Ver" der).
  static Future<void> openBatteryOptimizationSettings() async {
    try {
      await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
    } catch (e) {
      debugPrint("openBatteryOptimizationSettings error: $e");
      try {
        await _channel.invokeMethod('openBatteryOptimizationSettings');
      } catch (_) {}
    }
  }

  /// OEM'e özel ek pil kısıtlama ayarları (Xiaomi → Güvenlik Uygulaması vb.)
  static Future<void> openManufacturerBatterySettings() async {
    try {
      await DisableBatteryOptimization
          .showDisableManufacturerBatteryOptimizationSettings(
        "Pil Kısıtlaması",
        "Ezanın vaktinde çalabilmesi için cihazınızın ek pil kısıtlamasını kaldırın.",
      );
    } catch (e) {
      debugPrint("openManufacturerBatterySettings error: $e");
    }
  }

  /// Tüm pil optimizasyonlarını (standart + OEM) tek seferde göster.
  static Future<void> showDisableAllOptimizations() async {
    try {
      await DisableBatteryOptimization.showDisableAllOptimizationsSettings(
        "Tüm Pil Kısıtlamalarını Kaldır",
        "Ezanın tam vaktinde çalabilmesi için aşağıdaki adımları tamamlayın.",
        "Pil Optimizasyonu",
        "Sistem pil optimizasyonunu devre dışı bırakın.",
      );
    } catch (e) {
      debugPrint("showDisableAllOptimizations error: $e");
    }
  }

  /// Tam alarm izni ayarları (Android 12+)
  static Future<bool> openExactAlarmSettings() async {
    try {
      final bool result =
          await _channel.invokeMethod('openExactAlarmSettings');
      return result;
    } catch (e) {
      debugPrint("openExactAlarmSettings error: $e");
      return false;
    }
  }

  /// Bildirim izni ayarları
  static Future<bool> openNotificationSettings() async {
    try {
      final bool result =
          await _channel.invokeMethod('openNotificationSettings');
      return result;
    } catch (e) {
      debugPrint("openNotificationSettings error: $e");
      return false;
    }
  }
}
