import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:kuranvenamaz/core/settings_service.dart';
import 'package:kuranvenamaz/entity/location.dart';

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

    await SettingsService().initSettings();

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

    // Android 13+ izin talepleri & Kanallar
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        try {
          await androidPlugin.requestNotificationsPermission();
        } catch (e) {
          debugPrint("Notifications permission request failed: $e");
        }
        try {
          await androidPlugin.requestExactAlarmsPermission();
        } catch (e) {
          debugPrint("Exact alarm permission request failed: $e");
        }

        // 1. Ezan Kanali (v2: ses önbelleğini tazelemek için)
        final AndroidNotificationChannel ezanChannel = AndroidNotificationChannel(
          'namaz_vakitleri_ezan_v2',
          'Ezan Vakti Bildirimleri',
          description: 'Namaz vakitlerinde ezan sesi ile hatırlatma.',
          importance: Importance.max,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('ezan'),
          enableVibration: true,
        );
        // 2. Standart Bildirim Kanali
        final AndroidNotificationChannel standartChannel = AndroidNotificationChannel(
          'namaz_vakitleri_standart',
          'Standart Namaz Bildirimleri',
          description: 'Namaz vakitlerinde standart bildirim sesi.',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        );

        await androidPlugin.createNotificationChannel(ezanChannel);
        await androidPlugin.createNotificationChannel(standartChannel);
      }
    }

    _isInitialized = true;
    debugPrint("NotificationService başarıyla başlatıldı.");
  }

  NotificationDetails _getNotificationDetails() {
    final soundType = SettingsService().soundType;
    final isEzan = soundType == 'ezan';

    return NotificationDetails(
      android: AndroidNotificationDetails(
        isEzan ? 'namaz_vakitleri_ezan_v2' : 'namaz_vakitleri_standart',
        isEzan ? 'Ezan Vakti Bildirimleri' : 'Standart Namaz Bildirimleri',
        channelDescription: isEzan
            ? 'Namaz vakitlerinde ezan sesi ile hatırlatma.'
            : 'Namaz vakitlerinde standart bildirim sesi.',
        importance: isEzan ? Importance.max : Importance.high,
        priority: isEzan ? Priority.max : Priority.high,
        playSound: true,
        sound: isEzan ? const RawResourceAndroidNotificationSound('ezan') : null,
        audioAttributesUsage: AudioAttributesUsage.notification,
        enableVibration: true,
        showWhen: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: isEzan ? 'ezan.mp3' : null,
      ),
    );
  }

  /// Anında Test Bildirimi Gönder (Ayarlar sayfasında test etmek için)
  Future<void> showTestNotification() async {
    final isEzan = SettingsService().soundType == 'ezan';
    final timing = SettingsService().notificationTimingMinutes;
    final timingStr = timing == 0 ? "Tam Vaktinde" : "$timing Dakika Önce";

    await notificationsPlugin.show(
      999,
      isEzan ? "🕌 Ezan Vakti Bildirim Testi" : "🔔 Namaz Vakti Bildirim Testi",
      "Bildirim tercihiniz: $timingStr. Bildirimler ve ses başarıyla çalışıyor!",
      _getNotificationDetails(),
    );
  }

  /// Namaz vakti için zamanlanmış bildirim
  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) return;

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
        _getNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint("Zamanlanmış bildirim kuruldu (alarmClock): $title - $scheduledDate (ID: $id)");
    } catch (e) {
      debugPrint("alarmClock hatası, exactAllowWhileIdle deneniyor: $e");
      try {
        await notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTZ,
          _getNotificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint("Zamanlanmış bildirim kuruldu (exactAllowWhileIdle): $title - $scheduledDate (ID: $id)");
      } catch (err) {
        debugPrint("exactAllowWhileIdle hatası, inexactAllowWhileIdle deneniyor: $err");
        try {
          await notificationsPlugin.zonedSchedule(
            id,
            title,
            body,
            scheduledTZ,
            _getNotificationDetails(),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          debugPrint("Zamanlanmış bildirim kuruldu (inexactAllowWhileIdle): $title - $scheduledDate (ID: $id)");
        } catch (finalErr) {
          debugPrint("Bildirim zamanlama başarısız: $finalErr");
        }
      }
    }
  }

  /// Günlük Namaz Vakitlerini Otomatik Zamanlama
  Future<void> reschedulePrayerNotifications(Times times) async {
    await cancelAllNotifications();

    if (!SettingsService().notificationsEnabled) {
      debugPrint("Bildirimler kapalı, zamanlama yapılmadı.");
      return;
    }

    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final todayList = times.timesByDate[todayStr];

    if (todayList == null || todayList.length < 6) return;

    // Namaz vakit isimleri: [İmsak, Güneş, Öğle, İkindi, Akşam, Yatsı]
    final names = ["İmsak", "Güneş", "Öğle", "İkindi", "Akşam", "Yatsı"];
    final timingMinutes = SettingsService().notificationTimingMinutes;
    final isEzan = SettingsService().soundType == 'ezan';

    for (int i = 0; i < names.length; i++) {
      // Güneş vakti hariç diğer vakitlere bildirim kuralım
      if (i == 1) continue; 

      final timeParts = todayList[i].split(':');
      if (timeParts.length < 2) continue;

      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;

      final exactPrayerTime = DateTime(now.year, now.month, now.day, hour, minute);
      final scheduledTime = exactPrayerTime.subtract(Duration(minutes: timingMinutes));

      if (scheduledTime.isAfter(now)) {
        final vakitName = names[i];
        final title = timingMinutes == 0
            ? (isEzan ? "🕌 $vakitName Ezanı Okunuyor" : "🔔 $vakitName Namazı Vakti Geldi")
            : (isEzan
                ? "🕌 $vakitName Namazına $timingMinutes Dakika Kaldı!"
                : "🔔 $vakitName Namazına $timingMinutes Dakika Kaldı!");

        final body = "$vakitName vakti saati: ${todayList[i]}. Haydi namaza!";

        await schedulePrayerNotification(
          id: 100 + i,
          title: title,
          body: body,
          scheduledDate: scheduledTime,
        );
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