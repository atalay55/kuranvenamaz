import 'package:flutter/material.dart';
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
  int _notificationTiming = 1;
  String _soundType = 'ezan';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _notificationsEnabled = _settings.notificationsEnabled;
      _notificationTiming = _settings.notificationTimingMinutes;
      _soundType = _settings.soundType;
    });
  }

  Future<void> _saveSettings() async {
    await _settings.setNotificationsEnabled(_notificationsEnabled);
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
                          "Ezan ve vakit hatırlatmalarını dilediğiniz gibi kişiselleştirin.",
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
            const SizedBox(height: 20),

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
                  "Namaz vakitlerinde ezan veya bildirim sesi alın.",
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
              // Section 2: Sound Type Selection
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  "BİLDİRİM VE EZAN SESİ SEÇİMİ",
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
                    RadioListTile<String>(
                      value: 'ezan',
                      groupValue: _soundType,
                      activeColor: AppTheme.goldAccent,
                      title: const Row(
                        children: [
                          Text("🕌 ", style: TextStyle(fontSize: 18)),
                          Text(
                            "Ezan Sesi İle Hatırlat",
                            style: TextStyle(
                              color: AppTheme.textPrimaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      subtitle: const Text(
                        "Namaz vaktinde otomatik ezan sesi okunsun.",
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
                            "Standart Bildirim Sesi",
                            style: TextStyle(
                              color: AppTheme.textPrimaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      subtitle: const Text(
                        "Kısa bildirim ses tonu ve titreşim verilsin.",
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
                ),
              ),
              const SizedBox(height: 20),

              // Section 3: Notification Timing Offset
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  "BİLDİRİM ZAMANLAMASI",
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
                    RadioListTile<int>(
                      value: 1,
                      groupValue: _notificationTiming,
                      activeColor: AppTheme.goldAccent,
                      title: const Text(
                        "1 Dakika Önce (Önerilen)",
                        style: TextStyle(
                          color: AppTheme.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        "Namaz vaktinden 1 dk önce bildirim verilir.",
                        style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _notificationTiming = val;
                          });
                        }
                      },
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    RadioListTile<int>(
                      value: 0,
                      groupValue: _notificationTiming,
                      activeColor: AppTheme.goldAccent,
                      title: const Text(
                        "Tam Namaz Vaktinde",
                        style: TextStyle(
                          color: AppTheme.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        "Tam vakit girdiğinde bildirim gönderilir.",
                        style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _notificationTiming = val;
                          });
                        }
                      },
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    RadioListTile<int>(
                      value: 5,
                      groupValue: _notificationTiming,
                      activeColor: AppTheme.goldAccent,
                      title: const Text(
                        "5 Dakika Önce",
                        style: TextStyle(
                          color: AppTheme.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        "Hazırlık yapmanız için 5 dk öncesinde hatırlatır.",
                        style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _notificationTiming = val;
                          });
                        }
                      },
                    ),
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
                icon: const Icon(Icons.volume_up_rounded, size: 20),
                label: const Text(
                  "Bildirimi & Ezanı Test Et",
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
