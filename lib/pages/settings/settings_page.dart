import 'package:flutter/material.dart';
import 'package:kuranvenamaz/core/device_settings_service.dart';
import 'package:kuranvenamaz/core/notificationservice.dart';
import 'package:kuranvenamaz/core/settings_service.dart';
import 'package:kuranvenamaz/core/utilities.dart';
import 'package:kuranvenamaz/theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsService _settings = SettingsService();

  bool _notificationsEnabled = true;
  bool _ezanEnabled = true;
  bool _preNotificationEnabled = true;
  int _notificationTiming = 15;
  String _soundType = 'ezan';
  String _manufacturer = 'Unknown';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkDeviceManufacturer();
  }

  void _loadSettings() {
    setState(() {
      _notificationsEnabled = _settings.notificationsEnabled;
      _ezanEnabled = _settings.ezanEnabled;
      _preNotificationEnabled = _settings.preNotificationEnabled;
      _notificationTiming = _settings.notificationTimingMinutes;
      _soundType = _settings.soundType;
    });
  }

  Future<void> _checkDeviceManufacturer() async {
    final manufacturer = await DeviceSettingsService.getDeviceManufacturer();
    if (mounted) {
      setState(() {
        _manufacturer = manufacturer;
      });
    }
  }

  Future<void> _saveSettings() async {
    await _settings.setNotificationsEnabled(_notificationsEnabled);
    await _settings.setEzanEnabled(_ezanEnabled);
    await _settings.setPreNotificationEnabled(_preNotificationEnabled);
    await _settings.setNotificationTiming(_notificationTiming);
    await _settings.setSoundType(_soundType);

    // Namaz vakitleri bildirimlerini yeni ayarlara göre güncelle
    await PrayerUtilities().getNamazVakitleri();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ayarlarınız başarıyla kaydedildi ve ezan bildirimleri güncellendi!"),
          backgroundColor: AppTheme.primaryEmerald,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildOEMPermissionGuideCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade900.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade600, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber.shade400, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Xiaomi / Samsung / $_manufacturer Bildirim Rehberi",
                  style: TextStyle(
                    color: Colors.amber.shade300,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Xiaomi (MIUI/HyperOS), Samsung, Huawei vb. cihazlarda uygulamanız kapalıyken ezanın arka planda tam vaktinde okunabilmesi için sistem kısıtlamalarını kaldırmalısınız:",
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.autorenew_rounded, size: 16, color: AppTheme.goldAccent),
                  label: const Text("1. Otomatik Başlatma", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    await DeviceSettingsService.openAutostartSettings();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.battery_charging_full_rounded, size: 16, color: AppTheme.goldAccent),
                  label: const Text("2. Pil: Kısıtlama Yok", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    await DeviceSettingsService.openBatteryOptimizationSettings();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.amber.shade300,
                side: BorderSide(color: Colors.amber.shade400.withOpacity(0.6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.alarm_on_rounded, size: 16),
              label: const Text("3. Hassas Alarm İzni", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: () async {
                await DeviceSettingsService.openExactAlarmSettings();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Uygulama Ayarları"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.headerGradientDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_rounded,
                      color: AppTheme.goldAccent, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Namaz Vakti Bildirimleri",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Namaz vakitlerinde ezan okunması ve vakit öncesi hatırlatmalar.",
                          style: TextStyle(
                            color: AppTheme.goldLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // OEM Device Permission Guide Card
            _buildOEMPermissionGuideCard(),
            const SizedBox(height: 16),

            // Section 1: Main Notification Switch
            Container(
              decoration: AppTheme.cardDecoration(color: AppTheme.surfaceDark),
              child: SwitchListTile(
                secondary: Icon(
                  _notificationsEnabled
                      ? Icons.notifications_on_rounded
                      : Icons.notifications_off_rounded,
                  color: AppTheme.goldAccent,
                ),
                title: const Text(
                  "Namaz Bildirimlerini Aç",
                  style: TextStyle(
                    color: AppTheme.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  "Tüm ezan ve hatırlatma bildirimlerini aktif/pasif yapın.",
                  style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                ),
                value: _notificationsEnabled,
                activeColor: AppTheme.goldAccent,
                activeTrackColor: AppTheme.primaryEmerald,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            if (_notificationsEnabled) ...[
              // Section 2: Exact Prayer Time Notification & Ezan Sound
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  "TAM NAMAZ VAKTİ VE EZAN AYARLARI",
                  style: TextStyle(
                    color: AppTheme.goldAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                decoration: AppTheme.cardDecoration(color: AppTheme.surfaceDark),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.mosque_rounded, color: AppTheme.goldAccent),
                      title: const Text(
                        "Tam Namaz Vaktinde Bildirim / Ezan",
                        style: TextStyle(
                          color: AppTheme.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        "Namaz vakti tam girdiğinde bildirim gönderilsin veya ezan okunsun.",
                        style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                      ),
                      value: _ezanEnabled,
                      activeColor: AppTheme.goldAccent,
                      activeTrackColor: AppTheme.primaryEmerald,
                      onChanged: (val) {
                        setState(() {
                          _ezanEnabled = val;
                        });
                      },
                    ),
                    if (_ezanEnabled) ...[
                      const Divider(color: Colors.white12, height: 1),
                      RadioListTile<String>(
                        value: 'ezan',
                        groupValue: _soundType,
                        activeColor: AppTheme.goldAccent,
                        title: const Row(
                          children: [
                            Text("🕌 ", style: TextStyle(fontSize: 18)),
                            Text(
                              "Ezan Sesi İle Okunsun",
                              style: TextStyle(
                                color: AppTheme.textPrimaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        subtitle: const Text(
                          "Namaz vaktinde sesli ezan okunur.",
                          style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _soundType = value;
                            });
                          }
                        },
                      ),
                      const Divider(color: Colors.white12, height: 1),
                      RadioListTile<String>(
                        value: 'notification',
                        groupValue: _soundType,
                        activeColor: AppTheme.goldAccent,
                        title: const Row(
                          children: [
                            Text("🔔 ", style: TextStyle(fontSize: 18)),
                            Text(
                              "Standart Bildirim Tonu",
                              style: TextStyle(
                                color: AppTheme.textPrimaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        subtitle: const Text(
                          "Namaz vaktinde kısa bildirim sesi verilir.",
                          style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _soundType = value;
                            });
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 3: Pre-Prayer Reminder Settings
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  "VAKTİNDEN ÖNCE HATIRLATMA BİLDİRİMİ",
                  style: TextStyle(
                    color: AppTheme.goldAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                decoration: AppTheme.cardDecoration(color: AppTheme.surfaceDark),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.alarm_rounded, color: AppTheme.goldAccent),
                      title: const Text(
                        "Vaktinden Önce Hatırlatma Al",
                        style: TextStyle(
                          color: AppTheme.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        "Namaz vakti girmeden önce hazırlık bildirimi gönderilir.",
                        style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                      ),
                      value: _preNotificationEnabled,
                      activeColor: AppTheme.goldAccent,
                      activeTrackColor: AppTheme.primaryEmerald,
                      onChanged: (val) {
                        setState(() {
                          _preNotificationEnabled = val;
                        });
                      },
                    ),
                    if (_preNotificationEnabled) ...[
                      const Divider(color: Colors.white12, height: 1),
                      RadioListTile<int>(
                        value: 5,
                        groupValue: _notificationTiming,
                        activeColor: AppTheme.goldAccent,
                        title: const Text(
                          "5 Dakika Önce",
                          style: TextStyle(color: AppTheme.textPrimaryDark, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          "Namaz vaktine 5 dakika kala hatırlatılır.",
                          style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                        ),
                        onChanged: (val) {
                          if (val != null) setState(() => _notificationTiming = val);
                        },
                      ),
                      const Divider(color: Colors.white12, height: 1),
                      RadioListTile<int>(
                        value: 10,
                        groupValue: _notificationTiming,
                        activeColor: AppTheme.goldAccent,
                        title: const Text(
                          "10 Dakika Önce",
                          style: TextStyle(color: AppTheme.textPrimaryDark, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          "Namaz vaktine 10 dakika kala hatırlatılır.",
                          style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                        ),
                        onChanged: (val) {
                          if (val != null) setState(() => _notificationTiming = val);
                        },
                      ),
                      const Divider(color: Colors.white12, height: 1),
                      RadioListTile<int>(
                        value: 15,
                        groupValue: _notificationTiming,
                        activeColor: AppTheme.goldAccent,
                        title: const Text(
                          "15 Dakika Önce (Önerilen)",
                          style: TextStyle(color: AppTheme.textPrimaryDark, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          "Abdest ve hazırlık için 15 dakika öncesinde hatırlatır.",
                          style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                        ),
                        onChanged: (val) {
                          if (val != null) setState(() => _notificationTiming = val);
                        },
                      ),
                      const Divider(color: Colors.white12, height: 1),
                      RadioListTile<int>(
                        value: 30,
                        groupValue: _notificationTiming,
                        activeColor: AppTheme.goldAccent,
                        title: const Text(
                          "30 Dakika Önce",
                          style: TextStyle(color: AppTheme.textPrimaryDark, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          "Namaz vaktine 30 dakika kala hatırlatılır.",
                          style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                        ),
                        onChanged: (val) {
                          if (val != null) setState(() => _notificationTiming = val);
                        },
                      ),
                      const Divider(color: Colors.white12, height: 1),
                      RadioListTile<int>(
                        value: 45,
                        groupValue: _notificationTiming,
                        activeColor: AppTheme.goldAccent,
                        title: const Text(
                          "45 Dakika Önce",
                          style: TextStyle(color: AppTheme.textPrimaryDark, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          "Namaz vaktine 45 dakika kala hatırlatılır.",
                          style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                        ),
                        onChanged: (val) {
                          if (val != null) setState(() => _notificationTiming = val);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Section 4: Action Buttons (Save Settings & Test Notification)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryEmerald,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppTheme.goldAccent),
                  ),
                ),
                icon: const Icon(Icons.save_rounded, color: AppTheme.goldAccent),
                label: const Text(
                  "Ayarları Kaydet",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _saveSettings,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.goldAccent,
                  side: BorderSide(color: AppTheme.goldAccent.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.timer_rounded, size: 20),
                label: const Text(
                  "⏱️ Kapalıyken Test Et (10 Saniye Sonraya Kur)",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  await NotificationService().scheduleTestNotificationInSeconds(10);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("⏱️ 10 saniye sonraya test ezanı kuruldu! Lütfen uygulamayı hemen kapatıp/arka plana alıp bekleyin."),
                        backgroundColor: AppTheme.primaryEmerald,
                        duration: Duration(seconds: 4),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.goldAccent,
                  side: BorderSide(color: AppTheme.goldAccent.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.volume_up_rounded, size: 20),
                label: const Text(
                  "Anında Bildirimi & Ezanı Test Et",
                  style: TextStyle(fontSize: 14),
                ),
                onPressed: () async {
                  await NotificationService().showTestNotification();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Test bildirimi gönderildi! Lütfen bildirim panelinizi kontrol edin."),
                        backgroundColor: AppTheme.primaryEmerald,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
