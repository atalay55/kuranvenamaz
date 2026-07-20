import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint("Background notification tapped: ${notificationResponse.id}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initNotification() async {
    if (_isInitialized) return;

    // Timezone baslatma
    tz.initializeTimeZones();
    try {
      if (!kIsWeb) {
        final String timeZoneName = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint("Timezone ayarlandi: $timeZoneName");
      }
    } catch (e) {
      debugPrint("Timezone hatasi: $e");
      try {
        tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
      } catch (_) {}
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        debugPrint("Notification clicked: ${response.id}");
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Android 13+ izin talepleri
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        try {
          await androidPlugin.requestExactAlarmsPermission();
        } catch (e) {
          debugPrint("Exact alarm permission request failed: $e");
        }

        // Namaz vakitleri kanali olusturma
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'namaz_vakitleri_channel',
          'Namaz Vakti Bildirimleri',
          description: 'Namaz vakitlerinde ezan ve uyarı bildirimleri.',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        );
        await androidPlugin.createNotificationChannel(channel);
      }
    }

    _isInitialized = true;
    debugPrint("NotificationService başarıyla başlatıldı.");
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'namaz_vakitleri_channel',
        'Namaz Vakti Bildirimleri',
        channelDescription: 'Namaz vakitlerinde ezan ve uyarı bildirimleri.',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        showWhen: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payLoad,
  }) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      _notificationDetails(),
      payload: payLoad,
    );
  }

  /// Namaz vakti için tam vaktinde zannedilmiş (zoned) bildirim zamanlama
  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) {
      return; // Geçmiş vakitler için zamanlama yapma
    }

    final scheduledTZ = tz.TZDateTime.fromMillisecondsSinceEpoch(
      tz.local,
      scheduledDate.millisecondsSinceEpoch,
    );

    try {
      await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint("Zamanlanmış bildirim kuruldu: $title - $scheduledDate (ID: $id)");
    } catch (e) {
      debugPrint("alarmClock hatası, inexact zamanlamaya geçiliyor: $e");
      try {
        await notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTZ,
          _notificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (err) {
        debugPrint("Bildirim zamanlama başarısız: $err");
      }
    }
  }

  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }
}