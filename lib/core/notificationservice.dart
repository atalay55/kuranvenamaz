import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
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

        // 1. Ezan Kanali (v3)
        final AndroidNotificationChannel ezanChannel = AndroidNotificationChannel(
          'namaz_vakitleri_ezan_v3',
          'Ezan Vakti Bildirimleri',
          description: 'Namaz vakitlerinde ezan sesi ile hatırlatma.',
          importance: Importance.max,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('ezan'),
          enableVibration: true,
        );

        // 2. Vakit Öncesi Hatırlatma Kanali
        final AndroidNotificationChannel hatirlatmaChannel = AndroidNotificationChannel(
          'namaz_vakitleri_hatirlatma',
          'Vakit Öncesi Hatırlatma Bildirimleri',
          description: 'Namaz vaktinden önce gelen hatırlatma bildirimleri.',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        );

        // 3. Standart Bildirim Kanali
        final AndroidNotificationChannel standartChannel = AndroidNotificationChannel(
          'namaz_vakitleri_standart',
          'Standart Namaz Bildirimleri',
          description: 'Namaz vakitlerinde standart bildirim sesi.',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        );

        await androidPlugin.createNotificationChannel(ezanChannel);
        await androidPlugin.createNotificationChannel(hatirlatmaChannel);
        await androidPlugin.createNotificationChannel(standartChannel);
      }
    }

    _isInitialized = true;
    debugPrint("NotificationService başarıyla başlatıldı.");
  }

  NotificationDetails _getNotificationDetails(String channelType) {
    if (channelType == 'ezan') {
      return const NotificationDetails(
        android: AndroidNotificationDetails(
          'namaz_vakitleri_ezan_v3',
          'Ezan Vakti Bildirimleri',
          channelDescription: 'Namaz vakitlerinde ezan sesi ile hatırlatma.',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('ezan'),
          audioAttributesUsage: AudioAttributesUsage.alarm,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          enableVibration: true,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'ezan.mp3',
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      );
    } else if (channelType == 'hatirlatma') {
      return const NotificationDetails(
        android: AndroidNotificationDetails(
          'namaz_vakitleri_hatirlatma',
          'Vakit Öncesi Hatırlatma Bildirimleri',
          channelDescription: 'Namaz vaktinden önce gelen hatırlatma bildirimleri.',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.notification,
          category: AndroidNotificationCategory.reminder,
          visibility: NotificationVisibility.public,
          enableVibration: true,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      );
    } else {
      return const NotificationDetails(
        android: AndroidNotificationDetails(
          'namaz_vakitleri_standart',
          'Standart Namaz Bildirimleri',
          channelDescription: 'Namaz vakitlerinde standart bildirim sesi.',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.notification,
          category: AndroidNotificationCategory.event,
          visibility: NotificationVisibility.public,
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
  }

  /// Anında Test Bildirimi Gönder (Ayarlar sayfasında test etmek için)
  Future<void> showTestNotification() async {
    final settings = SettingsService();
    final isEzan = settings.soundType == 'ezan';
    final timing = settings.notificationTimingMinutes;

    await notificationsPlugin.show(
      999,
      isEzan ? "🕌 Ezan Vakti Bildirim Testi" : "🔔 Namaz Vakti Bildirim Testi",
      "Bildirim tercihiniz: ${settings.preNotificationEnabled ? '$timing dk önce hatırlatma +' : ''} ${settings.ezanEnabled ? 'vaktinde ezan' : ''}. Ses ve bildirimler başarıyla çalışıyor!",
      _getNotificationDetails(isEzan ? 'ezan' : 'standart'),
    );
  }

  /// Gelecekteki X saniye sonrasına zamanlanmış test ezanı/bildirimi kurma (Uygulama kapalıyken test etmek için)
  Future<void> scheduleTestNotificationInSeconds(int seconds) async {
    final settings = SettingsService();
    final isEzan = settings.soundType == 'ezan';
    final scheduledDate = DateTime.now().add(Duration(seconds: seconds));

    await schedulePrayerNotification(
      id: 998,
      title: isEzan ? "🕌 Ezan Testi ($seconds Saniye Sonra)" : "🔔 Bildirim Testi ($seconds Saniye Sonra)",
      body: "Uygulama kapalıyken zamanlanmış ezan ve bildirim testi başarıyla çalıştı!",
      scheduledDate: scheduledDate,
      channelType: isEzan ? 'ezan' : 'standart',
    );
  }

  /// Tekil zamanlanmış bildirim ekleme
  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String channelType = 'ezan',
  }) async {
    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) return;

    final scheduledTZ = tz.TZDateTime.fromMillisecondsSinceEpoch(
      tz.local,
      scheduledDate.millisecondsSinceEpoch,
    );

    final details = _getNotificationDetails(channelType);

    try {
      await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        details,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint("Zamanlanmış bildirim kuruldu (alarmClock): $title - $scheduledDate (ID: $id, Kanal: $channelType)");
    } catch (e) {
      debugPrint("alarmClock hatası, exactAllowWhileIdle deneniyor: $e");
      try {
        await notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTZ,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint("Zamanlanmış bildirim kuruldu (exactAllowWhileIdle): $title - $scheduledDate (ID: $id)");
      } catch (err) {
        try {
          await notificationsPlugin.zonedSchedule(
            id,
            title,
            body,
            scheduledTZ,
            details,
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

  /// Çok Günlük Namaz Vakitlerini Otomatik Zamanlama (Önümüzdeki 7 gün)
  Future<void> reschedulePrayerNotifications(Times times) async {
    try {
      await cancelAllNotifications();

      final settings = SettingsService();
      await settings.initSettings();

      if (!settings.notificationsEnabled) {
        debugPrint("Bildirimler kapalı, zamanlama yapılmadı.");
        return;
      }

      final now = DateTime.now();
      final names = ["İmsak", "Güneş", "Öğle", "İkindi", "Akşam", "Yatsı"];
      final timingMinutes = settings.notificationTimingMinutes;
      final isEzanSound = settings.soundType == 'ezan';

      int totalScheduled = 0;

      // Önümüzdeki 7 gün için bildirimleri kur
      for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
        final targetDay = now.add(Duration(days: dayOffset));
        final dateStr = DateFormat('yyyy-MM-dd').format(targetDay);
        final dayList = times.timesByDate[dateStr];

        if (dayList == null || dayList.length < 6) continue;

        for (int i = 0; i < names.length; i++) {
          // Güneş vakti hariç (0: İmsak, 2: Öğle, 3: İkindi, 4: Akşam, 5: Yatsı)
        if (i == 1) continue;

        final vakitName = names[i];
        final timeParts = dayList[i].split(':');
        if (timeParts.length < 2) continue;

        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = int.tryParse(timeParts[1]) ?? 0;

        final exactPrayerTime = DateTime(
          targetDay.year,
          targetDay.month,
          targetDay.day,
          hour,
          minute,
        );

        // 1. Tam Namaz Vakti Ezanı / Bildirimi (1000 + ID)
        if (settings.ezanEnabled && exactPrayerTime.isAfter(now)) {
          final title = isEzanSound
              ? "🕌 $vakitName Ezanı Okunuyor"
              : "🔔 $vakitName Namazı Vakti Geldi";
          final body = "$vakitName vakti girdi (${dayList[i]}). Haydi namaza!";
          final id = 1000 + (dayOffset * 10) + i;

          await schedulePrayerNotification(
            id: id,
            title: title,
            body: body,
            scheduledDate: exactPrayerTime,
            channelType: isEzanSound ? 'ezan' : 'standart',
          );
          totalScheduled++;
        }

        // 2. Vaktinden Önce Hatırlatma Bildirimi (2000 + ID)
        if (settings.preNotificationEnabled && timingMinutes > 0) {
          final preTime = exactPrayerTime.subtract(Duration(minutes: timingMinutes));
          if (preTime.isAfter(now)) {
            final title = "🔔 $vakitName Namazına $timingMinutes Dakika Kaldı!";
            final body = "$vakitName vakti saati: ${dayList[i]}. Hazırlık yapmayı unutmayın.";
            final id = 2000 + (dayOffset * 10) + i;

            await schedulePrayerNotification(
              id: id,
              title: title,
              body: body,
              scheduledDate: preTime,
              channelType: 'hatirlatma',
            );
            totalScheduled++;
          }
        }
      }
    }

    debugPrint("Toplam $totalScheduled adet namaz vakti bildirimi zamanlandı (7 günlük).");
    } catch (e) {
      debugPrint("reschedulePrayerNotifications hatası: $e");
    }
  }

  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }
}