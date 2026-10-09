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

        // 1. Ezan Kanali (v4 - En Yüksek Alarm ve Ses Önceliği)
        const AndroidNotificationChannel ezanChannel = AndroidNotificationChannel(
          'namaz_vakitleri_ezan_v4',
          'Ezan Vakti Bildirimleri',
          description: 'Namaz vakitlerinde ezan sesi ile yüksek sesli hatırlatma.',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('ezan'),
          enableVibration: true,
        );

        // 2. Vakit Öncesi Hatırlatma Kanali (v2)
        const AndroidNotificationChannel hatirlatmaChannel = AndroidNotificationChannel(
          'namaz_vakitleri_hatirlatma_v2',
          'Vakit Öncesi Hatırlatma Bildirimleri',
          description: 'Namaz vaktinden önce gelen hatırlatma bildirimleri.',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        );

        // 3. Standart Bildirim Kanali (v2)
        const AndroidNotificationChannel standartChannel = AndroidNotificationChannel(
          'namaz_vakitleri_standart_v2',
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
          'namaz_vakitleri_ezan_v4',
          'Ezan Vakti Bildirimleri',
          channelDescription: 'Namaz vakitlerinde ezan sesi ile yüksek sesli hatırlatma.',
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
          'namaz_vakitleri_hatirlatma_v2',
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
          'namaz_vakitleri_standart_v2',
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
    await settings.initSettings();
    final isEzan = settings.soundType == 'ezan';
    final timing = settings.notificationTimingMinutes;

    await notificationsPlugin.show(
      999,
      isEzan ? "🕌 Ezan Vakti Bildirim Testi" : "🔔 Namaz Vakti Bildirim Testi",
      "Bildirim tercihiniz: ${settings.preNotificationEnabled ? '$timing dk önce hatırlatma +' : ''} ${settings.ezanEnabled ? 'vaktinde ezan' : ''}. Ses ve bildirimler başarıyla çalışıyor!",
      _getNotificationDetails(isEzan ? 'ezan' : 'standart'),
    );
  }

  /// Seçilen ses tipini anında önizleme/dinleme (Ayarlar modalında dinlemek için)
  Future<void> playPreviewSound(String soundType) async {
    await stopPreviewSound();
    if (soundType == 'ezan') {
      await notificationsPlugin.show(
        888,
        "🕌 Ezan Sesi Önizleme",
        "Ezan sesi çalınıyor... Dinlemeyi durdurmak için 'Durdur'a dokunabilirsiniz.",
        _getNotificationDetails('ezan'),
      );
    } else if (soundType == 'alarm') {
      await notificationsPlugin.show(
        888,
        "⏰ Çalar Saat Tonu Önizleme",
        "Yüksek sesli alarm sesi çalınıyor...",
        _getNotificationDetails('ezan'),
      );
    } else {
      await notificationsPlugin.show(
        888,
        "🔔 Standart Bildirim Tonu Önizleme",
        "Cihazınızın standart bildirim tonu çalındı.",
        _getNotificationDetails('standart'),
      );
    }
  }

  /// Önizleme bildirimini ve sesini durdurma
  Future<void> stopPreviewSound() async {
    await notificationsPlugin.cancel(888);
  }

  /// Gelecekteki X saniye sonrasına zamanlanmış test ezanı/bildirimi kurma (Uygulama kapalıyken test etmek için)
  Future<void> scheduleTestNotificationInSeconds(int seconds) async {
    final settings = SettingsService();
    await settings.initSettings();
    final isEzan = settings.soundType == 'ezan';
    final nowTz = tz.TZDateTime.now(tz.local);
    final targetTz = nowTz.add(Duration(seconds: seconds));

    final details = _getNotificationDetails(isEzan ? 'ezan' : 'standart');

    try {
      await notificationsPlugin.zonedSchedule(
        998,
        isEzan ? "🕌 Ezan Alarmı Testi ($seconds Sn)" : "🔔 Bildirim Testi ($seconds Sn)",
        "Uygulama kapalıyken zamanlanmış ezan ve bildirim testi başarıyla çalıştı!",
        targetTz,
        details,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint("✅ Test alarmı kuruldu (alarmClock): $seconds saniye sonra ($targetTz)");
    } catch (e) {
      debugPrint("⚠️ Test alarmı alarmClock hatası: $e");
      try {
        await notificationsPlugin.zonedSchedule(
          998,
          isEzan ? "🕌 Ezan Alarmı Testi ($seconds Sn)" : "🔔 Bildirim Testi ($seconds Sn)",
          "Uygulama kapalıyken zamanlanmış ezan ve bildirim testi başarıyla çalıştı!",
          targetTz,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint("✅ Test alarmı kuruldu (exactAllowWhileIdle): $seconds saniye sonra ($targetTz)");
      } catch (err) {
        debugPrint("❌ Test alarmı kurulamadı: $err");
      }
    }
  }

  /// Tekil zamanlanmış bildirim ekleme (Saat dilimi sapmasız kesin zaman)
  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String channelType = 'ezan',
  }) async {
    final nowTz = tz.TZDateTime.now(tz.local);
    final scheduledTZ = tz.TZDateTime(
      tz.local,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledDate.hour,
      scheduledDate.minute,
      scheduledDate.second,
    );

    if (scheduledTZ.isBefore(nowTz)) {
      debugPrint("Geçmiş zamanlı bildirim atlandı: $title ($scheduledTZ)");
      return;
    }

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
      debugPrint("✅ Zamanlanmış bildirim kuruldu (alarmClock): $title - $scheduledTZ (ID: $id, Kanal: $channelType)");
    } catch (e) {
      debugPrint("⚠️ alarmClock hatası, exactAllowWhileIdle deneniyor: $e");
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
        debugPrint("✅ Zamanlanmış bildirim kuruldu (exactAllowWhileIdle): $title - $scheduledTZ (ID: $id)");
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
          debugPrint("✅ Zamanlanmış bildirim kuruldu (inexactAllowWhileIdle): $title - $scheduledTZ (ID: $id)");
        } catch (finalErr) {
          debugPrint("❌ Bildirim zamanlama başarısız: $finalErr");
        }
      }
    }
  }

  /// Çok Günlük Namaz Vakitlerini Otomatik Zamanlama (Önümüzdeki 7 gün)
  Future<int> reschedulePrayerNotifications(Times times) async {
    int totalScheduled = 0;
    try {
      await cancelAllNotifications();

      final settings = SettingsService();
      await settings.initSettings();

      if (!settings.notificationsEnabled) {
        debugPrint("Bildirimler kapalı, zamanlama yapılmadı.");
        return 0;
      }

      final now = DateTime.now();
      final names = ["İmsak", "Güneş", "Öğle", "İkindi", "Akşam", "Yatsı"];
      final timingMinutes = settings.notificationTimingMinutes;
      final isEzanSound = settings.soundType == 'ezan';

      // Önümüzdeki 7 gün için bildirimleri kur
      for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
        final targetDay = now.add(Duration(days: dayOffset));
        final weekday = targetDay.weekday; // 1: Pazartesi ... 7: Pazar
        final enabledPrayersForDay = settings.getPrayersForDay(weekday);

        // Bu gün için hiçbir vakit seçilmediyse o günü atla
        if (enabledPrayersForDay.isEmpty) {
          continue;
        }

        final dateStr = DateFormat('yyyy-MM-dd').format(targetDay);
        final dayList = times.timesByDate[dateStr];

        if (dayList == null || dayList.length < 6) continue;

        for (int i = 0; i < names.length; i++) {
          // O güne özel vakit filtresi (Kullanıcının o gün için seçtiği namazlar)
          if (!enabledPrayersForDay.contains(i)) continue;

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

          // 1. Ana Namaz Vakti Alarmı / Ezanı (1000 + ID)
          final firstMinutes = settings.getFirstAlarmMinutes(prayerIndex: i);
          final firstAlarmTime = exactPrayerTime.add(Duration(minutes: firstMinutes));
          if (settings.ezanEnabled && firstAlarmTime.isAfter(now)) {
            String title;
            String body;
            final isAlarmSound = settings.soundType == 'alarm';

            if (firstMinutes == 0) {
              title = isEzanSound
                  ? "🕌 $vakitName Ezanı Okunuyor"
                  : (isAlarmSound
                      ? "⏰ $vakitName Namazı Vakti Geldi"
                      : "🔔 $vakitName Namazı Vakti Geldi");
              body = "$vakitName vakti girdi (${dayList[i]}). Haydi namaza!";
            } else if (firstMinutes < 0) {
              final m = -firstMinutes;
              title = isEzanSound
                  ? "🕌 $vakitName Vaktine $m Dakika Kaldı"
                  : (isAlarmSound
                      ? "⏰ $vakitName Vaktine $m Dakika Kaldı"
                      : "🔔 $vakitName Vaktine $m Dakika Kaldı");
              body = "$vakitName vakti saati: ${dayList[i]}. Hazırlık yapmayı unutmayın.";
            } else {
              title = isAlarmSound
                  ? "⏰ $vakitName Namazı (+$firstMinutes dk)"
                  : (isEzanSound
                      ? "🕌 $vakitName Ezanı (+$firstMinutes dk)"
                      : "🔔 $vakitName Namazı (+$firstMinutes dk)");
              body = "$vakitName vakti gireli $firstMinutes dakika oldu. Namazınızı kılmayı unutmayın!";
            }
            final id = 1000 + (dayOffset * 10) + i;

            await schedulePrayerNotification(
              id: id,
              title: title,
              body: body,
              scheduledDate: firstAlarmTime,
              channelType: isEzanSound ? 'ezan' : (isAlarmSound ? 'ezan' : 'standart'),
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

          // 3. İkinci Alarm (Yedek / Uyanma & Erteleme Güvencesi) (3000 + ID)
          if (settings.isSecondPrayerEnabledForDay(weekday, i)) {
            final secondMinutes = settings.getSecondAlarmMinutes(prayerIndex: i);
            final secondAlarmTime = exactPrayerTime.add(Duration(minutes: secondMinutes));
            if (secondAlarmTime.isAfter(now)) {
              final isSecondEzan = settings.secondAlarmSoundType == 'ezan';
              final title = "⏰ 2. Alarm: $vakitName Namazı!";
              final body = "$vakitName vakti gireli $secondMinutes dakika oldu. Namazınızı kılmayı unutmayın!";
              final id = 3000 + (dayOffset * 10) + i;

              await schedulePrayerNotification(
                id: id,
                title: title,
                body: body,
                scheduledDate: secondAlarmTime,
                channelType: isSecondEzan ? 'ezan' : 'standart',
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
    return totalScheduled;
  }

  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }
}