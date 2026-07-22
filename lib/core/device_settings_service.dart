import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DeviceSettingsService {
  static const MethodChannel _channel =
      MethodChannel('com.fatihatalay.kuranvenamaz/device_settings');

  static Future<String> getDeviceManufacturer() async {
    try {
      final String manufacturer = await _channel.invokeMethod('getDeviceManufacturer');
      return manufacturer;
    } catch (e) {
      debugPrint("getDeviceManufacturer error: $e");
      return "Unknown";
    }
  }

  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final bool result = await _channel.invokeMethod('isIgnoringBatteryOptimizations');
      return result;
    } catch (e) {
      debugPrint("isIgnoringBatteryOptimizations error: $e");
      return true;
    }
  }

  static Future<bool> openAutostartSettings() async {
    try {
      final bool result = await _channel.invokeMethod('openAutostartSettings');
      return result;
    } catch (e) {
      debugPrint("openAutostartSettings error: $e");
      return false;
    }
  }

  static Future<bool> openBatteryOptimizationSettings() async {
    try {
      final bool result = await _channel.invokeMethod('openBatteryOptimizationSettings');
      return result;
    } catch (e) {
      debugPrint("openBatteryOptimizationSettings error: $e");
      return false;
    }
  }

  static Future<bool> openExactAlarmSettings() async {
    try {
      final bool result = await _channel.invokeMethod('openExactAlarmSettings');
      return result;
    } catch (e) {
      debugPrint("openExactAlarmSettings error: $e");
      return false;
    }
  }
}
