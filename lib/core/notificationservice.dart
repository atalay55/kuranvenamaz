import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  if (notificationResponse.id != null) {
    FlutterLocalNotificationsPlugin().cancel(notificationResponse.id!);
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String ezanChannelId = 'namaz_vakitleri_ezan_v6';
  static const String hatirlatmaChannelId = 'namaz_vakitleri_hatirlatma_v2';
  static const String standartChannelId = 'namaz_vakitleri_standart_v2';
  static const MethodChannel _deviceChannel =
      MethodChannel('com.fatihatalay.kuranvenamaz/device_settings');

  static bool get _isAndroidNative =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static String resolveChannelType(String soundType) {
    if (soundType == 'standart' || soundType == 'notification') {
      return 'standart';
    }
    return 'ezan';
  }

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  Future<int>? _activeReschedule;

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
        AndroidInitializationSettings('@drawable/ic_notification');

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
        if (response.id != null) {
          await notificationsPlugin.cancel(response.id!);
        }
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

        // 1. Ezan Kanali (v6 - Alarm Akışı ve Ses Önceliği)
        const AndroidNotificationChannel ezanChannel = AndroidNotificationChannel(
          'namaz_vakitleri_ezan_v6',
          'Ezan Vakti Bildirimleri',
          description: 'Namaz vakitlerinde ezan sesi ile yüksek sesli hatırlatma.',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('ezan'),
          audioAttributesUsage: AudioAttributesUsage.alarm,
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
      return NotificationDetails(
        android: AndroidNotificationDetails(
          'namaz_vakitleri_ezan_v6',
          'Ezan Vakti Bildirimleri',
          channelDescription: 'Namaz vakitlerinde ezan sesi ile yüksek sesli hatırlatma.',
          icon: '@drawable/ic_notification',
          color: const Color(0xFF0D5C3A),
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('ezan'),
          audioAttributesUsage: AudioAttributesUsage.alarm,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          enableVibration: true,
          showWhen: true,
          autoCancel: true,
        ),
        iOS: const DarwinNotificationDetails(
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
          icon: '@drawable/ic_notification',
          color: Color(0xFF0D5C3A),
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
          icon: '@drawable/ic_notification',
          color: Color(0xFF0D5C3A),
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
    final channelType = resolveChannelType(settings.soundType);
    final isEzan = channelType == 'ezan';
    final timing = settings.notificationTimingMinutes;
    final title = isEzan ? "🕌 Ezan Vakti Bildirim Testi" : "🔔 Namaz Vakti Bildirim Testi";
    final body =
        "Bildirim tercihiniz: ${settings.preNotificationEnabled ? '$timing dk önce hatırlatma +' : ''} ${settings.ezanEnabled ? 'vaktinde ezan' : ''}.";

    if (isEzan && _isAndroidNative) {
      await _deviceChannel.invokeMethod('playForegroundAlarm', {
        'title': title,
        'body': body,
      });
      return;
    }

    await notificationsPlugin.show(
      999,
      title,
      body,
      _getNotificationDetails(channelType),
    );
  }

  /// Seçilen ses tipini anında önizleme/dinleme (Ayarlar modalında dinlemek için)
  Future<void> playPreviewSound(String soundType) async {
    await stopPreviewSound();
    if ((soundType == 'ezan' || soundType == 'alarm') && _isAndroidNative) {
      await _deviceChannel.invokeMethod('playForegroundAlarm', {
        'title': soundType == 'ezan' ? "🕌 Ezan Sesi Önizleme" : "⏰ Çalar Saat Tonu Önizleme",
        'body': "Dinlemeyi durdurmak için 'Ezanı Durdur'a veya ses tuşuna basın.",
      });
      return;
    }
    if (soundType == 'ezan' || soundType == 'alarm') {
      await notificationsPlugin.show(
        888,
        soundType == 'ezan' ? "🕌 Ezan Sesi Önizleme" : "⏰ Çalar Saat Tonu Önizleme",
        "Ezan sesi çalınıyor...",
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
    if (_isAndroidNative) {
      try {
        await _deviceChannel.invokeMethod('stopForegroundAlarm');
      } catch (_) {}
    }
    await notificationsPlugin.cancel(888);
  }

  /// Gelecekteki X saniye sonrasına zamanlanmış test ezanı/bildirimi kurma (Uygulama kapalıyken test etmek için)
  Future<void> scheduleTestNotificationInSeconds(int seconds) async {
    if (!_isInitialized) {
      await initNotification();
    }
    final settings = SettingsService();
    await settings.initSettings();
    final channelType = resolveChannelType(settings.soundType);
    final isEzan = channelType == 'ezan';
    final targetDate = DateTime.now().add(Duration(seconds: seconds));
    final title = isEzan ? "🕌 Ezan Alarmı Testi ($seconds Sn)" : "🔔 Bildirim Testi ($seconds Sn)";
    const body = "Uygulama kapalıyken zamanlanmış ezan ve bildirim testi başarıyla çalıştı!";

    if (isEzan && _isAndroidNative) {
      await _deviceChannel.invokeMethod('scheduleNativeAlarm', {
        'id': 998,
        'triggerAtMillis': targetDate.millisecondsSinceEpoch,
        'title': title,
        'body': body,
      });
      debugPrint("✅ Native ezan test alarmı kuruldu: $seconds sn sonra ($targetDate)");
      return;
    }

    final targetTz = tz.TZDateTime.from(targetDate, tz.local);
    final details = _getNotificationDetails(channelType);

    try {
      await notificationsPlugin.zonedSchedule(
        998,
        title,
        body,
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
          title,
          body,
          targetTz,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
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
    if (!_isInitialized) {
      await initNotification();
    }
    final now = DateTime.now();
    if (!scheduledDate.isAfter(now)) {
      debugPrint("Geçmiş zamanlı bildirim atlandı: $title ($scheduledDate)");
      return;
    }

    // Android'de ezan/alarm seçiliyse doğrudan native AlarmManager + MediaPlayer (USAGE_ALARM) + Üst Bildirim kullan
    if (channelType == 'ezan' && _isAndroidNative) {
      try {
        await _deviceChannel.invokeMethod('scheduleNativeAlarm', {
          'id': id,
          'triggerAtMillis': scheduledDate.millisecondsSinceEpoch,
          'title': title,
          'body': body,
        });
        debugPrint("✅ Native ezan alarmı kuruldu: $title - $scheduledDate (ID: $id)");
        return;
      } catch (e) {
        debugPrint("⚠️ Native alarm kurulamadı, local_notifications yedeğine düşülüyor: $e");
      }
    }

    final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);
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

  /// Hangi vakitlerin zamanlanacağını hesaplar (birim testlerde de doğrudan doğrulanabilir)
  static List<Map<String, dynamic>> buildSevenDaySchedulePlan({
    required Times times,
    required SettingsService settings,
    required DateTime now,
  }) {
    if (!settings.notificationsEnabled) return const [];

    final List<Map<String, dynamic>> plan = [];
    const names = ["İmsak", "Güneş", "Öğle", "İkindi", "Akşam", "Yatsı"];
    final timingMinutes = settings.notificationTimingMinutes;
    final firstChannelType = resolveChannelType(settings.soundType);
    final secondChannelType = resolveChannelType(settings.secondAlarmSoundType);

    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final targetDay = now.add(Duration(days: dayOffset));
      final weekday = targetDay.weekday;
      final enabledFirstForDay = settings.getPrayersForDay(weekday);
      final enabledSecondForDay = settings.getSecondPrayersForDay(weekday);

      if (enabledFirstForDay.isEmpty && enabledSecondForDay.isEmpty) {
        continue;
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(targetDay);
      final dayList = times.timesByDate[dateStr] ??
          (times.timesByDate.isNotEmpty ? times.timesByDate.values.first : null);
      if (dayList == null || dayList.length < 6) continue;

      for (int i = 0; i < names.length; i++) {
        final isFirstSelected = enabledFirstForDay.contains(i);
        final isSecondSelected = enabledSecondForDay.contains(i);
        if (!isFirstSelected && !isSecondSelected) continue;

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

        // 1. Ana Namaz Vakti Bildirimi / Ezan Alarmı (1000 + ID)
        if (isFirstSelected) {
          final firstMinutes = settings.getFirstAlarmMinutes(prayerIndex: i);
          final firstAlarmTime =
              exactPrayerTime.subtract(Duration(minutes: firstMinutes.abs()));
          if (settings.ezanEnabled && firstAlarmTime.isAfter(now)) {
            final String title;
            final String body;
            if (firstMinutes == 0) {
              title = "🕌 $vakitName Vakti Girdi";
              body = "$vakitName vakti girdi (${dayList[i]}). Haydi namaza!";
            } else {
              final m = firstMinutes.abs();
              title = "🔔 $vakitName Vaktine $m Dakika Kaldı";
              body = "$vakitName vakti saati: ${dayList[i]}. Hazırlık yapmayı unutmayın.";
            }
            plan.add({
              'id': 1000 + (dayOffset * 10) + i,
              'title': title,
              'body': body,
              'scheduledDate': firstAlarmTime,
              'channelType': firstChannelType,
            });
          }

          // 2. Vaktinden Önce Hatırlatma Bildirimi (2000 + ID)
          if (settings.preNotificationEnabled && timingMinutes > 0) {
            final preTime =
                exactPrayerTime.subtract(Duration(minutes: timingMinutes));
            if (preTime.isAfter(now)) {
              plan.add({
                'id': 2000 + (dayOffset * 10) + i,
                'title': "🔔 $vakitName Namazına $timingMinutes Dakika Kaldı!",
                'body': "$vakitName vakti saati: ${dayList[i]}. Hazırlık yapmayı unutmayın.",
                'scheduledDate': preTime,
                'channelType': 'hatirlatma',
              });
            }
          }
        }

        // 3. İkinci Alarm Bildirimi (3000 + ID) — 1. alarm kapalı olsa bile bağımsız çalışır!
        if (isSecondSelected) {
          final secondMinutes = settings.getSecondAlarmMinutes(prayerIndex: i);
          final secondAlarmTime =
              exactPrayerTime.subtract(Duration(minutes: secondMinutes.abs()));
          if (secondAlarmTime.isAfter(now)) {
            final String title;
            final String body;
            if (secondMinutes == 0) {
              title = "⏰ 2. Alarm: $vakitName Namazı Vakti Geldi";
              body = "$vakitName vakti girdi (${dayList[i]}). Haydi namaza!";
            } else {
              final m = secondMinutes.abs();
              title = "⏰ 2. Alarm: $vakitName Vaktine $m Dakika Kaldı";
              body = "$vakitName vakti saati: ${dayList[i]}. Hazırlık yapmayı unutmayın.";
            }
            plan.add({
              'id': 3000 + (dayOffset * 10) + i,
              'title': title,
              'body': body,
              'scheduledDate': secondAlarmTime,
              'channelType': secondChannelType,
            });
          }
        }
      }
    }
    return plan;
  }

  /// Çok Günlük Namaz Vakitlerini Otomatik Zamanlama (Önümüzdeki 7 gün)
  Future<int> reschedulePrayerNotifications(Times times) async {
    // Eşzamanlı çağrılarda cancelAllNotifications çakışmasını önle
    while (_activeReschedule != null) {
      try {
        await _activeReschedule;
      } catch (_) {}
    }
    final future = _doReschedulePrayerNotifications(times);
    _activeReschedule = future;
    try {
      return await future;
    } finally {
      if (identical(_activeReschedule, future)) {
        _activeReschedule = null;
      }
    }
  }

  Future<int> _doReschedulePrayerNotifications(Times times) async {
    int totalScheduled = 0;
    try {
      if (!_isInitialized) {
        await initNotification();
      }
      await cancelAllNotifications();

      final settings = SettingsService();
      await settings.initSettings();

      if (!settings.notificationsEnabled) {
        debugPrint("Bildirimler kapalı, zamanlama yapılmadı.");
        return 0;
      }

      final plan = buildSevenDaySchedulePlan(
        times: times,
        settings: settings,
        now: DateTime.now(),
      );

      for (final item in plan) {
        await schedulePrayerNotification(
          id: item['id'] as int,
          title: item['title'] as String,
          body: item['body'] as String,
          scheduledDate: item['scheduledDate'] as DateTime,
          channelType: item['channelType'] as String,
        );
        totalScheduled++;
      }

      debugPrint("Toplam $totalScheduled adet namaz vakti bildirimi zamanlandı (7 günlük).");
    } catch (e) {
      debugPrint("reschedulePrayerNotifications hatası: $e");
    }
    return totalScheduled;
  }

  Future<void> cancelAllNotifications() async {
    if (_isAndroidNative) {
      try {
        await _deviceChannel.invokeMethod('cancelAllNativeAlarms');
      } catch (_) {}
    }
    await notificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }
}