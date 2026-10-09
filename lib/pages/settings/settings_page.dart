import 'package:flutter/material.dart';
import 'package:kuranvenamaz/core/device_settings_service.dart';
import 'package:kuranvenamaz/core/settings_service.dart';
import 'package:kuranvenamaz/core/utilities.dart';
import 'package:kuranvenamaz/theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with WidgetsBindingObserver {
  final SettingsService _settings = SettingsService();

  bool _notificationsEnabled = true;
  bool _ezanEnabled = true;
  bool _preNotificationEnabled = true;
  int _notificationTiming = 15;
  String _soundType = 'ezan';

  NotificationPermissionStatus? _permStatus;
  bool _permLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
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

  Future<void> _checkPermissions() async {
    if (!mounted) return;
    setState(() => _permLoading = true);
    final status = await DeviceSettingsService.checkNotificationPermissions();
    if (mounted) {
      setState(() {
        _permStatus = status;
        _permLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    await _settings.setNotificationsEnabled(_notificationsEnabled);
    await _settings.setEzanEnabled(_ezanEnabled);
    await _settings.setPreNotificationEnabled(_preNotificationEnabled);
    await _settings.setNotificationTiming(_notificationTiming);
    await _settings.setSoundType(_soundType);
    await PrayerUtilities().getNamazVakitleri();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Ayarlarınız başarıyla kaydedildi ve ezan bildirimleri güncellendi!"),
          backgroundColor: AppTheme.primaryEmerald,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // ─── İZİN DURUM KARTI ───────────────────────────────────────────────────

  Widget _buildPermissionCard() {
    if (_permLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.goldAccent,
              ),
            ),
            SizedBox(width: 12),
            Text(
              "Bildirim ayarları kontrol ediliyor...",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final status = _permStatus;
    if (status == null) return const SizedBox.shrink();
    if (status.isFullyConfigured) return _buildAllGoodCard();
    if (status.isXiaomi) return _buildXiaomiCard(status);
    if (status.isRestrictiveOEM) return _buildGenericOEMCard(status);
    return _buildStandardPermissionCard(status);
  }

  Widget _buildAllGoodCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4332),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryEmerald, width: 1.5),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded,
              color: AppTheme.primaryEmerald, size: 26),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bildirimler Aktif ✓",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Ezan ve namaz vakti bildirimleri sorunsuz çalışacak.",
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXiaomiCard(NotificationPermissionStatus status) {
    int stepCounter = 1;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3D1A00),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade700, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("⚠️", style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Xiaomi'de Ezan Açılmıyor mu?",
                  style: TextStyle(
                    color: Colors.orange.shade200,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Xiaomi telefonlar uygulamaların arka planda çalışmasını kısıtlar. "
            "Ezanın vaktinde okunması için aşağıdaki adımları yapmanız yeterli:",
            style: TextStyle(
                color: Colors.orange.shade100, fontSize: 12.5, height: 1.5),
          ),
          const SizedBox(height: 14),
          if (!status.notificationsEnabled)
            _buildStepTile(
              step: "${stepCounter++}",
              icon: Icons.notifications_rounded,
              title: "Bildirimlere İzin Ver",
              subtitle: "Butona basın → Açılan ekranda \"İzin Ver\" deyin.",
              onTap: () => DeviceSettingsService.openNotificationSettings(),
            ),
          // Autostart — ön rehber dialog ile açılıyor
          _buildStepTile(
            step: "${stepCounter++}",
            icon: Icons.autorenew_rounded,
            title: "Arka Planda Çalışmaya İzin Ver",
            subtitle:
                "Butona basın → Açılan rehberi takip edin → Kolayca halledersiniz.",
            onTap: () => DeviceSettingsService.openAutostartSettings(),
          ),
          if (!status.batteryOptimizationIgnored)
            _buildStepTile(
              step: "${stepCounter++}",
              icon: Icons.battery_charging_full_rounded,
              title: "Pil Tasarrufundan Çıkar",
              subtitle:
                  "Butona basın → Açılan küçük pencerede 'İzin Ver' deyin.",
              onTap: () =>
                  DeviceSettingsService.openBatteryOptimizationSettings(),
            ),
          if (!status.exactAlarmAllowed)
            _buildStepTile(
              step: "Son",
              icon: Icons.alarm_on_rounded,
              title: "Alarm İzni Ver",
              subtitle: "Butona basın → Uygulamayı bulun → İzin verin.",
              onTap: () => DeviceSettingsService.openExactAlarmSettings(),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Colors.white54, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Adımları tamamladıktan sonra bu sayfayı kapatıp tekrar açın. "
                    "Yeşil onay göreceksiniz.",
                    style: TextStyle(
                        color: Colors.white54, fontSize: 11, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericOEMCard(NotificationPermissionStatus status) {
    int stepCounter = 1;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade900.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade600, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("⚠️", style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "${status.manufacturer} — Bildirim Ayarı Gerekli",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Ezanların vaktinde okunması için aşağıdaki ayarları yapın:",
            style: TextStyle(color: Colors.white70, fontSize: 12.5),
          ),
          const SizedBox(height: 12),
          if (!status.notificationsEnabled)
            _buildStepTile(
              step: "${stepCounter++}",
              icon: Icons.notifications_rounded,
              title: "Bildirimleri Açın",
              subtitle: "Uygulamanın size mesaj gönderebilmesi için gerekli.",
              onTap: () => DeviceSettingsService.openNotificationSettings(),
            ),
          _buildStepTile(
            step: "${stepCounter++}",
            icon: Icons.autorenew_rounded,
            title: "Arka Planda Çalışmaya İzin Ver",
            subtitle:
                "Butona basın → Açılan rehberi takip edin → Kolayca halledersiniz.",
            onTap: () => DeviceSettingsService.openAutostartSettings(),
          ),
          if (!status.batteryOptimizationIgnored)
            _buildStepTile(
              step: "${stepCounter++}",
              icon: Icons.battery_charging_full_rounded,
              title: "Pil Optimizasyonunu Kapat",
              subtitle:
                  "Butona basın → Açılan küçük pencerede 'İzin Ver' deyin.",
              onTap: () =>
                  DeviceSettingsService.openBatteryOptimizationSettings(),
            ),
          if (!status.exactAlarmAllowed)
            _buildStepTile(
              step: "Son",
              icon: Icons.alarm_on_rounded,
              title: "Alarm İzni",
              subtitle:
                  "Ezanın tam vaktinde çalabilmesi için alarm izni gerekli.",
              onTap: () => DeviceSettingsService.openExactAlarmSettings(),
            ),
        ],
      ),
    );
  }

  Widget _buildStandardPermissionCard(NotificationPermissionStatus status) {
    int stepCounter = 1;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade400, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.redAccent, size: 22),
              SizedBox(width: 8),
              Text(
                "Bildirim İzni Gerekli",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!status.notificationsEnabled)
            _buildStepTile(
              step: "${stepCounter++}",
              icon: Icons.notifications_rounded,
              title: "Bildirimleri Açın",
              subtitle: "Ezan ve namaz vakti bildirimlerini almak için gerekli.",
              onTap: () => DeviceSettingsService.openNotificationSettings(),
            ),
          if (!status.exactAlarmAllowed)
            _buildStepTile(
              step: "${stepCounter++}",
              icon: Icons.alarm_on_rounded,
              title: "Alarm İzni Verin",
              subtitle: "Tam saatinde ezan çalması için alarm izni gerekli.",
              onTap: () => DeviceSettingsService.openExactAlarmSettings(),
            ),
        ],
      ),
    );
  }

  Widget _buildStepTile({
    required String step,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.goldAccent.withOpacity(0.85),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    step,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, color: AppTheme.goldAccent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: AppTheme.goldAccent, size: 14),
              ],
            ),
          ),
        ),
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
              child: const Row(
                children: [
                  Icon(Icons.notifications_active_rounded,
                      color: AppTheme.goldAccent, size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

            // ── Akıllı İzin Durumu Kartı ──
            _buildPermissionCard(),
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
                  style:
                      TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
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
              // Section 2: Ezan
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
                decoration:
                    AppTheme.cardDecoration(color: AppTheme.surfaceDark),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.mosque_rounded,
                          color: AppTheme.goldAccent),
                      title: const Text(
                        "Tam Namaz Vaktinde Bildirim / Ezan",
                        style: TextStyle(
                          color: AppTheme.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        "Namaz vakti tam girdiğinde bildirim gönderilsin veya ezan okunsun.",
                        style: TextStyle(
                            color: AppTheme.textSecondaryDark, fontSize: 12),
                      ),
                      value: _ezanEnabled,
                      activeColor: AppTheme.goldAccent,
                      activeTrackColor: AppTheme.primaryEmerald,
                      onChanged: (val) => setState(() => _ezanEnabled = val),
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
                            Text("Ezan Sesi İle Okunsun",
                                style: TextStyle(
                                    color: AppTheme.textPrimaryDark,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        subtitle: const Text("Namaz vaktinde sesli ezan okunur.",
                            style: TextStyle(
                                color: AppTheme.textSecondaryDark,
                                fontSize: 12)),
                        onChanged: (v) {
                          if (v != null) setState(() => _soundType = v);
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
                            Text("Standart Bildirim Tonu",
                                style: TextStyle(
                                    color: AppTheme.textPrimaryDark,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        subtitle: const Text(
                            "Namaz vaktinde kısa bildirim sesi verilir.",
                            style: TextStyle(
                                color: AppTheme.textSecondaryDark,
                                fontSize: 12)),
                        onChanged: (v) {
                          if (v != null) setState(() => _soundType = v);
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 3: Hatırlatma
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
                decoration:
                    AppTheme.cardDecoration(color: AppTheme.surfaceDark),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.alarm_rounded,
                          color: AppTheme.goldAccent),
                      title: const Text(
                        "Vaktinden Önce Hatırlatma Al",
                        style: TextStyle(
                          color: AppTheme.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        "Namaz vakti girmeden önce hazırlık bildirimi gönderilir.",
                        style: TextStyle(
                            color: AppTheme.textSecondaryDark, fontSize: 12),
                      ),
                      value: _preNotificationEnabled,
                      activeColor: AppTheme.goldAccent,
                      activeTrackColor: AppTheme.primaryEmerald,
                      onChanged: (val) =>
                          setState(() => _preNotificationEnabled = val),
                    ),
                    if (_preNotificationEnabled) ...[
                      for (final entry in [
                        [5, "5 Dakika Önce",
                            "Namaz vaktine 5 dakika kala hatırlatılır."],
                        [10, "10 Dakika Önce",
                            "Namaz vaktine 10 dakika kala hatırlatılır."],
                        [15, "15 Dakika Önce (Önerilen)",
                            "Abdest ve hazırlık için 15 dakika öncesinde hatırlatır."],
                        [30, "30 Dakika Önce",
                            "Namaz vaktine 30 dakika kala hatırlatılır."],
                        [45, "45 Dakika Önce",
                            "Namaz vaktine 45 dakika kala hatırlatılır."],
                      ]) ...[
                        const Divider(color: Colors.white12, height: 1),
                        RadioListTile<int>(
                          value: entry[0] as int,
                          groupValue: _notificationTiming,
                          activeColor: AppTheme.goldAccent,
                          title: Text(entry[1] as String,
                              style: const TextStyle(
                                  color: AppTheme.textPrimaryDark,
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(entry[2] as String,
                              style: const TextStyle(
                                  color: AppTheme.textSecondaryDark,
                                  fontSize: 12)),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _notificationTiming = val);
                            }
                          },
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Kaydet butonu
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
                icon:
                    const Icon(Icons.save_rounded, color: AppTheme.goldAccent),
                label: const Text(
                  "Ayarları Kaydet",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _saveSettings,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
