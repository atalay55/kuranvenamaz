import 'package:flutter/material.dart';
import 'package:kuranvenamaz/core/app_translations.dart';
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

class _SettingsPageState extends State<SettingsPage>
    with WidgetsBindingObserver {
  final SettingsService _settings = SettingsService();

  bool _notificationsEnabled = true;
  bool _ezanEnabled = true;
  bool _preNotificationEnabled = true;
  int _notificationTiming = 15;
  String _soundType = 'ezan';
  String _secondAlarmSoundType = 'alarm';
  int _selectedWeekday = DateTime.now().weekday;
  Map<int, Set<int>> _dayPrayers = {
    1: {0, 2, 3, 4, 5},
    2: {0, 2, 3, 4, 5},
    3: {0, 2, 3, 4, 5},
    4: {0, 2, 3, 4, 5},
    5: {0, 2, 3, 4, 5},
    6: {0, 2, 3, 4, 5},
    7: {0, 2, 3, 4, 5},
  };
  Map<int, Set<int>> _daySecondPrayers = {
    1: {0},
    2: {0},
    3: {0},
    4: {0},
    5: {0},
    6: {0},
    7: {0},
  };

  NotificationPermissionStatus? _permStatus;
  bool _permLoading = true;

  @override
  void initState() {
    super.initState();
    AppTranslations.currentLocaleNotifier.addListener(_onLocaleChanged);
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
    _checkPermissions();
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppTranslations.currentLocaleNotifier.removeListener(_onLocaleChanged);
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
      _secondAlarmSoundType = _settings.secondAlarmSoundType;
      _selectedWeekday = DateTime.now().weekday;
      _dayPrayers = {};
      _daySecondPrayers = {};
      for (int d = 1; d <= 7; d++) {
        _dayPrayers[d] = _settings.getPrayersForDay(d);
        _daySecondPrayers[d] = _settings.getSecondPrayersForDay(d);
      }
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

  Future<void> _handleRefresh() async {
    await _checkPermissions();
    _loadSettings();
    await PrayerUtilities().getNamazVakitleri();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("Ayarlar ve alarmlar yenilendi!"),
            ],
          ),
          backgroundColor: AppTheme.primaryEmerald,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ─── DİL SEÇİMİ KARTI ───────────────────────────────────────────────────

  Widget _buildLanguageCard() {
    final currentCode = AppTranslations.currentLanguageCode;
    final currentLang = AppTranslations.supportedLanguages.firstWhere(
      (l) => l['code'] == currentCode,
      orElse: () => {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
    );

    return Container(
      decoration: AppTheme.cardDecoration(color: AppTheme.surfaceDark),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.goldAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
          ),
          alignment: Alignment.center,
          child: Text(
            currentLang['flag'] ?? '🌐',
            style: const TextStyle(fontSize: 22),
          ),
        ),
        title: Text(
          AppTranslations.translate('app_language', fallback: 'Uygulama Dili'),
          style: const TextStyle(
            color: AppTheme.textPrimaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          currentLang['name'] ?? 'Türkçe',
          style: const TextStyle(
            color: AppTheme.primaryEmerald,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppTheme.goldAccent,
          size: 16,
        ),
        onTap: () => _showLanguageSelectionSheet(),
      ),
    );
  }

  void _showLanguageSelectionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final currentCode = AppTranslations.currentLanguageCode;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppTranslations.translate('select_language', fallback: 'Uygulama Dilini Seçin'),
                    style: const TextStyle(
                      color: AppTheme.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...AppTranslations.supportedLanguages.map((lang) {
                final isSelected = lang['code'] == currentCode;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isSelected ? AppTheme.goldAccent : AppTheme.goldAccent.withValues(alpha: 0.2),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    tileColor: isSelected
                        ? AppTheme.goldAccent.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.03),
                    leading: Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                    title: Text(
                      lang['name']!,
                      style: TextStyle(
                        color: isSelected ? AppTheme.primaryEmerald : AppTheme.textPrimaryDark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryEmerald)
                        : null,
                    onTap: () async {
                      Navigator.pop(ctx);
                      await AppTranslations.changeLocale(lang['code']!);
                      if (mounted) setState(() {});
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
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
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.goldAccent,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppTranslations.translate('notifications_checking', fallback: "Bildirim ayarları kontrol ediliyor..."),
              style: const TextStyle(color: Colors.white70, fontSize: 13),
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
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppTheme.primaryEmerald, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.translate('notifications_active_ok', fallback: "Bildirimler Aktif ✓"),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppTranslations.translate('notifications_active_ok_desc', fallback: "Ezan ve namaz vakti bildirimleri sorunsuz çalışacak."),
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
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
              subtitle:
                  "Ezan ve namaz vakti bildirimlerini almak için gerekli.",
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

  Widget _buildSoundChoiceTile({
    required String type,
    required String title,
    required String subtitle,
    required String groupValue,
    required String? playingSoundType,
    required void Function(String) onSelect,
    required Future<void> Function(String) onTogglePlay,
  }) {
    final isSelected = groupValue == type;
    final isPlaying = playingSoundType == type;

    return InkWell(
      onTap: () => onSelect(type),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Radio<String>(
              value: type,
              groupValue: groupValue,
              activeColor: AppTheme.goldAccent,
              onChanged: (v) {
                if (v != null) onSelect(v);
              },
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textPrimaryDark,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textSecondaryDark,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(
                  color: isPlaying ? Colors.redAccent : AppTheme.primaryEmerald,
                  width: 1,
                ),
                backgroundColor: isPlaying
                    ? Colors.redAccent.withValues(alpha: 0.15)
                    : AppTheme.primaryEmerald.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(
                isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                size: 15,
                color: isPlaying ? Colors.redAccent : AppTheme.primaryEmerald,
              ),
              label: Text(
                isPlaying ? "Durdur" : "Dinle",
                style: TextStyle(
                  color: isPlaying ? Colors.redAccent : AppTheme.primaryEmerald,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => onTogglePlay(type),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCustomSoundBanner({
    required String channelId,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.goldAccent.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.goldAccent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.phone_android_rounded,
              color: AppTheme.goldAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.translate('device_custom_sounds_title', fallback: "Telefondaki Kendi Alarm Sesleri"),
                  style: const TextStyle(
                    color: AppTheme.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppTranslations.translate('device_custom_sounds_desc', fallback: "Telefonunuzdaki hazır alarm ve zil seslerinden seçmek için dokunun."),
                  style: const TextStyle(
                    color: AppTheme.textSecondaryDark,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              AppTranslations.translate('change', fallback: "Seç"),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              await DeviceSettingsService.openChannelNotificationSettings(
                  channelId);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showAlarmDialog({
    required int alarmNumber,
    int? prayerIndex,
    String? prayerName,
  }) async {
    final bool isFirst = alarmNumber == 1;
    final int currentMinutes = isFirst
        ? _settings.getFirstAlarmMinutes(prayerIndex: prayerIndex)
        : _settings.getSecondAlarmMinutes(prayerIndex: prayerIndex);

    // 0: Tam Vakit, -1: Vakitten Önce
    int timingMode = currentMinutes == 0 ? 0 : -1;
    int offsetMinutes = currentMinutes == 0 ? 15 : currentMinutes.abs();
    String selectedSoundType = isFirst ? _soundType : _secondAlarmSoundType;
    bool applyToAll = prayerIndex == null;
    final TextEditingController textController =
        TextEditingController(text: offsetMinutes.toString());
    String? playingSoundType;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (ctx) {
        bool isClosed = false;
        void safePop() {
          if (!isClosed && Navigator.of(ctx).canPop()) {
            isClosed = true;
            Navigator.of(ctx).pop();
          }
        }

        return StatefulBuilder(
          builder: (context, setModalState) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgDark,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.goldAccent.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ÜST PANEL (Flutter BottomSheet sürükleme hareketini doğrudan yönetir)
                    Container(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 12,
                        top: 12,
                        bottom: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 44,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: AppTheme.textSecondaryDark
                                      .withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: AppTheme.goldAccent
                                        .withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.alarm_rounded,
                                    color: AppTheme.primaryEmerald,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    isFirst
                                        ? (prayerIndex != null
                                            ? AppTranslations.translate('first_alarm_dialog_title', fallback: "@name İçin 1. Alarm Ayarları").replaceAll('@name', prayerName ?? '')
                                            : AppTranslations.translate('first_alarm_dialog_title_general', fallback: "1. Alarm (Ana Alarm) Ayarları"))
                                        : (prayerIndex != null
                                            ? AppTranslations.translate('second_alarm_dialog_title', fallback: "@name İçin 2. Alarm Ayarları").replaceAll('@name', prayerName ?? '')
                                            : AppTranslations.translate('second_alarm_dialog_title_general', fallback: "2. Alarm Ayarları")),
                                    style: const TextStyle(
                                      color: AppTheme.textPrimaryDark,
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: AppTheme.textSecondaryDark,
                                    size: 24,
                                  ),
                                  onPressed: safePop,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(right: 32),
                              child: Text(
                                isFirst
                                    ? AppTranslations.translate('first_alarm_dialog_desc', fallback: "Alarm saatini (tam vakit veya önce) ve ses tercihinizi belirleyin.")
                                    : AppTranslations.translate('second_alarm_dialog_desc', fallback: "Alarm saatini (tam vakit veya önce) ve ses tercihinizi belirleyin."),
                                style: const TextStyle(
                                    color: AppTheme.textSecondaryDark, fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: AppTheme.textSecondaryDark.withValues(alpha: 0.15),
                    ),
                    Flexible(
                      child: NotificationListener<ScrollEndNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.pixels < -35) {
                            safePop();
                            return true;
                          }
                          return false;
                        },
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 14,
                            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                    // Zamanlama Modu
                    Text(
                      AppTranslations.translate('alarm_timing_label', fallback: "Alarm Zamanı:"),
                      style: const TextStyle(
                        color: AppTheme.textPrimaryDark,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                timingMode = 0;
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: timingMode == 0
                                    ? AppTheme.primaryEmerald
                                    : AppTheme.cardDark,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: timingMode == 0
                                      ? AppTheme.goldAccent
                                      : AppTheme.goldAccent
                                          .withValues(alpha: 0.25),
                                  width: timingMode == 0 ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.access_time_filled_rounded,
                                    size: 18,
                                    color: timingMode == 0
                                        ? Colors.white
                                        : AppTheme.goldAccent,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppTranslations.translate('exact_time', fallback: "Tam Vakit"),
                                    style: TextStyle(
                                      color: timingMode == 0
                                          ? Colors.white
                                          : AppTheme.textPrimaryDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                  Text(
                                    "(0 ${AppTranslations.translate('minutes_unit', fallback: 'dk')})",
                                    style: TextStyle(
                                      color: timingMode == 0
                                          ? Colors.white70
                                          : AppTheme.textSecondaryDark,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                timingMode = -1;
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: timingMode == -1
                                    ? AppTheme.primaryEmerald
                                    : AppTheme.cardDark,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: timingMode == -1
                                      ? AppTheme.goldAccent
                                      : AppTheme.goldAccent
                                          .withValues(alpha: 0.25),
                                  width: timingMode == -1 ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.hourglass_top_rounded,
                                    size: 18,
                                    color: timingMode == -1
                                        ? Colors.white
                                        : AppTheme.goldAccent,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppTranslations.translate('before_prayer_label', fallback: "Vakitten Önce"),
                                    style: TextStyle(
                                      color: timingMode == -1
                                          ? Colors.white
                                          : AppTheme.textPrimaryDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                  Text(
                                    "(-$offsetMinutes ${AppTranslations.translate('minutes_unit', fallback: 'dk')})",
                                    style: TextStyle(
                                      color: timingMode == -1
                                          ? Colors.white70
                                          : AppTheme.textSecondaryDark,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (timingMode == 0) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.goldAccent.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline_rounded,
                                color: AppTheme.primaryEmerald, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                AppTranslations.translate('exact_time_info', fallback: "Namaz vakti tam girdiğinde alarm veya ezan çalar (0 dakika)."),
                                style: const TextStyle(
                                  color: AppTheme.textPrimaryDark,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Gösterge Kartı
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.goldAccent.withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: AppTheme.primaryEmerald, size: 30),
                              onPressed: () {
                                if (offsetMinutes > 1) {
                                  setModalState(() {
                                    offsetMinutes--;
                                    textController.text =
                                        offsetMinutes.toString();
                                  });
                                }
                              },
                            ),
                            Column(
                              children: [
                                Text(
                                  "$offsetMinutes",
                                  style: const TextStyle(
                                    color: AppTheme.primaryEmerald,
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  AppTranslations.translate('minutes_before_label', fallback: "Dakika Önce"),
                                  style: const TextStyle(
                                    color: AppTheme.textSecondaryDark,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  color: AppTheme.primaryEmerald, size: 30),
                              onPressed: () {
                                if (offsetMinutes < 120) {
                                  setModalState(() {
                                    offsetMinutes++;
                                    textController.text =
                                        offsetMinutes.toString();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Slider
                      Slider(
                        value: offsetMinutes.clamp(1, 60).toDouble(),
                        min: 1,
                        max: 60,
                        divisions: 59,
                        activeColor: AppTheme.primaryEmerald,
                        inactiveColor:
                            AppTheme.goldAccent.withValues(alpha: 0.25),
                        label: "$offsetMinutes dk",
                        onChanged: (val) {
                          setModalState(() {
                            offsetMinutes = val.round();
                            textController.text = offsetMinutes.toString();
                          });
                        },
                      ),
                      const SizedBox(height: 6),

                      // Hızlı Seçim Butonları
                      Text(
                        AppTranslations.translate('quick_options', fallback: "Hızlı Seçenekler:"),
                        style: const TextStyle(
                          color: AppTheme.textPrimaryDark,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [5, 10, 15, 20, 25, 30, 45, 60].map((m) {
                          final isSelected = offsetMinutes == m;
                          return ChoiceChip(
                            label: Text("$m ${AppTranslations.translate('minutes_unit', fallback: 'dk')}"),
                            selected: isSelected,
                            selectedColor: AppTheme.primaryEmerald,
                            backgroundColor: AppTheme.cardDark,
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.primaryEmerald
                                  : AppTheme.goldAccent.withValues(alpha: 0.35),
                              width: 1,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textPrimaryDark,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 11.5,
                            ),
                            onSelected: (_) {
                              setModalState(() {
                                offsetMinutes = m;
                                textController.text = m.toString();
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),

                      // Elle Dakika Girişi
                      Row(
                        children: [
                          Text(
                            AppTranslations.translate('custom_minute', fallback: "Özel Dakika:"),
                            style: const TextStyle(
                              color: AppTheme.textPrimaryDark,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 75,
                            child: TextField(
                              controller: textController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppTheme.textPrimaryDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 6),
                                filled: true,
                                fillColor: AppTheme.cardDark,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppTheme.goldAccent
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppTheme.goldAccent
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppTheme.primaryEmerald,
                                    width: 1.5,
                                  ),
                                ),
                                hintText: AppTranslations.translate('minutes_unit', fallback: "Dk"),
                                hintStyle: TextStyle(
                                    color: AppTheme.textSecondaryDark
                                        .withValues(alpha: 0.5)),
                              ),
                              onChanged: (val) {
                                final numVal = int.tryParse(val);
                                if (numVal != null &&
                                    numVal >= 1 &&
                                    numVal <= 180) {
                                  setModalState(() {
                                    offsetMinutes = numVal;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppTranslations.translate('minutes_unit', fallback: "dakika"),
                            style: const TextStyle(
                                color: AppTheme.textSecondaryDark, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 18),

                    // Ses Seçimi
                    Text(
                      AppTranslations.translate('alarm_ringtone_label', fallback: "Alarm Zil Sesi:"),
                      style: const TextStyle(
                        color: AppTheme.textPrimaryDark,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.goldAccent.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildSoundChoiceTile(
                            type: 'ezan',
                            title: AppTranslations.translate('sound_adhan_title', fallback: "🕌 Ezan Sesi İle Okunsun"),
                            subtitle: AppTranslations.translate('sound_adhan_desc', fallback: "Namaz vaktinde sesli ezan okunur."),
                            groupValue: selectedSoundType,
                            playingSoundType: playingSoundType,
                            onSelect: (v) =>
                                setModalState(() => selectedSoundType = v),
                            onTogglePlay: (type) async {
                              if (playingSoundType == type) {
                                await NotificationService().stopPreviewSound();
                                setModalState(() => playingSoundType = null);
                              } else {
                                setModalState(() => playingSoundType = type);
                                await NotificationService()
                                    .playPreviewSound(type);
                              }
                            },
                          ),
                          Divider(
                            height: 1,
                            color: AppTheme.goldAccent.withValues(alpha: 0.2),
                          ),
                          _buildSoundChoiceTile(
                            type: 'standart',
                            title: AppTranslations.translate('sound_notification_title', fallback: "🔔 Standart Bildirim Tonu"),
                            subtitle:
                                AppTranslations.translate('sound_notification_desc', fallback: "Cihazınızın standart bildirim sesi verilir."),
                            groupValue: selectedSoundType,
                            playingSoundType: playingSoundType,
                            onSelect: (v) =>
                                setModalState(() => selectedSoundType = v),
                            onTogglePlay: (type) async {
                              if (playingSoundType == type) {
                                await NotificationService().stopPreviewSound();
                                setModalState(() => playingSoundType = null);
                              } else {
                                setModalState(() => playingSoundType = type);
                                await NotificationService()
                                    .playPreviewSound(type);
                              }
                            },
                          ),
                          Divider(
                            height: 1,
                            color: AppTheme.goldAccent.withValues(alpha: 0.2),
                          ),
                          _buildSoundChoiceTile(
                            type: 'alarm',
                            title: AppTranslations.translate('sound_alarm_title', fallback: "⏰ Yüksek Sesli Çalar Saat"),
                            subtitle:
                                AppTranslations.translate('sound_alarm_desc', fallback: "Uyanmak için kesintisiz çalar saat tonu."),
                            groupValue: selectedSoundType,
                            playingSoundType: playingSoundType,
                            onSelect: (v) =>
                                setModalState(() => selectedSoundType = v),
                            onTogglePlay: (type) async {
                              if (playingSoundType == type) {
                                await NotificationService().stopPreviewSound();
                                setModalState(() => playingSoundType = null);
                              } else {
                                setModalState(() => playingSoundType = type);
                                await NotificationService()
                                    .playPreviewSound(type);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    _buildDeviceCustomSoundBanner(
                      channelId: selectedSoundType == 'ezan'
                          ? 'namaz_vakitleri_ezan_v4'
                          : 'namaz_vakitleri_standart_v2',
                    ),

                    if (prayerIndex != null) ...[
                      const SizedBox(height: 14),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: applyToAll,
                        activeColor: AppTheme.primaryEmerald,
                        checkColor: Colors.white,
                        title: Text(
                          AppTranslations.translate('apply_to_all_prayers', fallback: "Tüm namaz vakitlerine uygula"),
                          style: const TextStyle(
                            color: AppTheme.textPrimaryDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          isFirst
                              ? AppTranslations.translate('apply_to_all_first_desc', fallback: "İşaretlenirse bu dakika ve ses ayarı tüm vakitlerin 1. alarmına uygulanır.")
                              : AppTranslations.translate('apply_to_all_second_desc', fallback: "İşaretlenirse bu dakika ve ses ayarı tüm vakitlerin 2. alarmına uygulanır."),
                          style: const TextStyle(
                              color: AppTheme.textSecondaryDark, fontSize: 11),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            applyToAll = val ?? false;
                          });
                        },
                      ),
                    ],

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.textSecondaryDark,
                              side: BorderSide(
                                  color: AppTheme.textSecondaryDark
                                      .withValues(alpha: 0.35)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(AppTranslations.translate('discard', fallback: "Vazgeç")),
                            onPressed: () async {
                              await NotificationService().stopPreviewSound();
                              safePop();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryEmerald,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              AppTranslations.translate('save', fallback: "Kaydet"),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              await NotificationService().stopPreviewSound();
                              safePop();

                              final finalMinutes = timingMode == 0
                                  ? 0
                                  : -offsetMinutes;

                              if (isFirst) {
                                if (prayerIndex != null && !applyToAll) {
                                  await _settings.setPrayerFirstAlarmMinutes(
                                      prayerIndex, finalMinutes);
                                } else {
                                  await _settings.setAllPrayersFirstAlarmMinutes(
                                      finalMinutes);
                                }

                                await _settings.setSoundType(selectedSoundType);
                                setState(() {
                                  _soundType = selectedSoundType;
                                });
                              } else {
                                if (prayerIndex != null && !applyToAll) {
                                  await _settings.setPrayerSecondAlarmMinutes(
                                      prayerIndex, finalMinutes);
                                } else {
                                  await _settings.setAllPrayersSecondAlarmMinutes(
                                      finalMinutes);
                                }

                                await _settings.setSecondAlarmSoundType(selectedSoundType);
                                setState(() {
                                  _secondAlarmSoundType = selectedSoundType;
                                });
                              }

                              await PrayerUtilities().getNamazVakitleri();

                              String timeInfo = AppTranslations.getTimingLabel(finalMinutes);
                              String soundInfo = AppTranslations.getSoundTypeLabel(selectedSoundType);

                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isFirst
                                        ? AppTranslations.translate('first_alarm_saved_msg', fallback: "✅ 1. Alarm: @time (@sound) kaydedildi!")
                                            .replaceAll('@time', timeInfo)
                                            .replaceAll('@sound', soundInfo)
                                        : AppTranslations.translate('second_alarm_saved_msg', fallback: "✅ 2. Alarm: @time (@sound) kaydedildi!")
                                            .replaceAll('@time', timeInfo)
                                            .replaceAll('@sound', soundInfo),
                                  ),
                                  backgroundColor: AppTheme.primaryEmerald,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
          },
        );
      },
    ).whenComplete(() => NotificationService().stopPreviewSound());
  }

  Future<void> _showFirstAlarmDialog({int? prayerIndex, String? prayerName}) =>
      _showAlarmDialog(alarmNumber: 1, prayerIndex: prayerIndex, prayerName: prayerName);

  Future<void> _showSecondAlarmDialog({int? prayerIndex, String? prayerName}) =>
      _showAlarmDialog(alarmNumber: 2, prayerIndex: prayerIndex, prayerName: prayerName);

  static const List<Map<String, dynamic>> _prayersData = [
    {
      'index': 0,
      'name': 'İmsak (Sabah)',
      'desc': 'Sabah namazı vakti girdiğinde ezan/bildirim çalar',
      'icon': Icons.nights_stay_rounded,
    },
    {
      'index': 1,
      'name': 'Güneş',
      'desc': 'Güneş doğuş vakti girdiğinde hatırlatır (isteğe bağlı)',
      'icon': Icons.wb_twilight_rounded,
    },
    {
      'index': 2,
      'name': 'Öğle',
      'desc': 'Öğle namazı vakti girdiğinde ezan/bildirim çalar',
      'icon': Icons.wb_sunny_rounded,
    },
    {
      'index': 3,
      'name': 'İkindi',
      'desc': 'İkindi namazı vakti girdiğinde ezan/bildirim çalar',
      'icon': Icons.cloud_queue_rounded,
    },
    {
      'index': 4,
      'name': 'Akşam',
      'desc': 'Akşam namazı vakti girdiğinde ezan/bildirim çalar',
      'icon': Icons.brightness_medium_rounded,
    },
    {
      'index': 5,
      'name': 'Yatsı',
      'desc': 'Yatsı namazı vakti girdiğinde ezan/bildirim çalar',
      'icon': Icons.bedtime_rounded,
    },
  ];

  Widget _buildWeeklyPrayerScheduleSection() {
    final daysData = AppTranslations.getWeekDays();
    final activeDayData = daysData.firstWhere(
      (d) => d['id'] == _selectedWeekday,
      orElse: () => daysData.first,
    );
    final activeDayName = activeDayData['full'] as String;
    final activePrayers = _dayPrayers[_selectedWeekday] ?? <int>{};
    final activeSecondPrayers = _daySecondPrayers[_selectedWeekday] ?? <int>{};

    return Container(
      decoration: AppTheme.cardDecoration(color: AppTheme.surfaceDark),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded,
                  color: AppTheme.goldAccent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppTranslations.translate('alarm_schedule_title', fallback: "Günlük Alarm ve Ezan Planı"),
                  style: const TextStyle(
                    color: AppTheme.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: activePrayers.isNotEmpty
                      ? AppTheme.primaryEmerald.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: activePrayers.isNotEmpty
                        ? AppTheme.primaryEmerald.withValues(alpha: 0.3)
                        : Colors.black26,
                  ),
                ),
                child: Text(
                  activePrayers.isNotEmpty
                      ? AppTranslations.translate('prayer_count_badge', fallback: "@count Vakit")
                          .replaceAll('@count', "${activePrayers.length}")
                      : AppTranslations.translate('alarms_off', fallback: "Alarmlar Kapalı"),
                  style: TextStyle(
                    color: activePrayers.isNotEmpty
                        ? AppTheme.primaryEmerald
                        : AppTheme.textSecondaryDark,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppTranslations.translate(
              'alarm_schedule_desc',
              fallback: "Günü seçin; aşağıdaki 1. Ana Alarm (Vakit Girişi) ve 2. Yedek Alarm (+15 dk uyanma güvencesi) ayarlarını dilediğiniz gibi özelleştirin:",
            ),
            style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
          ),
          const SizedBox(height: 14),

          // ─── 7 GÜN SEÇİCİ TABLAR ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: daysData.map((day) {
              final id = day['id'] as int;
              final short = day['short'] as String;
              final isCurrentTab = id == _selectedWeekday;
              final dayCount = _dayPrayers[id]?.length ?? 0;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedWeekday = id;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 54,
                  decoration: BoxDecoration(
                    color: isCurrentTab
                        ? AppTheme.primaryEmerald
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          isCurrentTab ? AppTheme.goldAccent : Colors.black12,
                      width: isCurrentTab ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        short,
                        style: TextStyle(
                          color: isCurrentTab
                              ? Colors.white
                              : AppTheme.textPrimaryDark,
                          fontWeight:
                              isCurrentTab ? FontWeight.bold : FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: isCurrentTab
                              ? AppTheme.goldAccent
                              : (dayCount > 0
                                  ? AppTheme.primaryEmerald
                                      .withValues(alpha: 0.2)
                                  : Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "$dayCount",
                              style: TextStyle(
                                color: isCurrentTab
                                    ? Colors.black
                                    : (dayCount > 0
                                        ? AppTheme.primaryEmerald
                                        : Colors.black45),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // ─── SEÇİLİ GÜN BİLGİSİ & HIZLI EYLEMLER ───
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryEmerald.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_calendar_rounded,
                        color: AppTheme.primaryEmerald, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      AppTranslations.translate('editing_day', fallback: "Düzenlenen Gün: @day")
                          .replaceAll('@day', activeDayName),
                      style: const TextStyle(
                        color: AppTheme.textPrimaryDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.copy_rounded,
                          size: 14, color: AppTheme.textPrimaryDark),
                      label: Text(AppTranslations.translate('apply_all_days', fallback: "Tüm Günlere Uygula")),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                          color:
                              AppTheme.primaryEmerald.withValues(alpha: 0.3)),
                      labelStyle: const TextStyle(
                        color: AppTheme.textPrimaryDark,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      onPressed: () async {
                        final current =
                            Set<int>.from(_dayPrayers[_selectedWeekday] ?? {});
                        final currentSecond = Set<int>.from(
                            _daySecondPrayers[_selectedWeekday] ?? {});
                        setState(() {
                          for (int d = 1; d <= 7; d++) {
                            _dayPrayers[d] = Set.from(current);
                            _daySecondPrayers[d] = Set.from(currentSecond);
                          }
                        });
                        await _settings.setDayPrayersMap(_dayPrayers);
                        await _settings
                            .setDaySecondPrayersMap(_daySecondPrayers);
                        await PrayerUtilities().getNamazVakitleri();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppTranslations.translate('applied_all_days_msg', fallback: "@day alarmları (1. ve 2. Alarmlar) tüm 7 güne uygulandı!")
                                    .replaceAll('@day', activeDayName),
                              ),
                              backgroundColor: AppTheme.primaryEmerald,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.date_range_rounded,
                          size: 14, color: AppTheme.textPrimaryDark),
                      label: Text(AppTranslations.translate('apply_weekdays', fallback: "Hafta İçi Uygula")),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                          color:
                              AppTheme.primaryEmerald.withValues(alpha: 0.3)),
                      labelStyle: const TextStyle(
                        color: AppTheme.textPrimaryDark,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      onPressed: () async {
                        final current =
                            Set<int>.from(_dayPrayers[_selectedWeekday] ?? {});
                        final currentSecond = Set<int>.from(
                            _daySecondPrayers[_selectedWeekday] ?? {});
                        setState(() {
                          for (int d = 1; d <= 5; d++) {
                            _dayPrayers[d] = Set.from(current);
                            _daySecondPrayers[d] = Set.from(currentSecond);
                          }
                        });
                        await _settings.setDayPrayersMap(_dayPrayers);
                        await _settings
                            .setDaySecondPrayersMap(_daySecondPrayers);
                        await PrayerUtilities().getNamazVakitleri();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppTranslations.translate('applied_weekdays_msg', fallback: "@day alarmları Hafta İçi günlerine uygulandı!")
                                    .replaceAll('@day', activeDayName),
                              ),
                              backgroundColor: AppTheme.primaryEmerald,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.weekend_rounded,
                          size: 14, color: AppTheme.textPrimaryDark),
                      label: Text(AppTranslations.translate('apply_weekends', fallback: "Hafta Sonu Uygula")),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                          color:
                              AppTheme.primaryEmerald.withValues(alpha: 0.3)),
                      labelStyle: const TextStyle(
                        color: AppTheme.textPrimaryDark,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      onPressed: () async {
                        final current =
                            Set<int>.from(_dayPrayers[_selectedWeekday] ?? {});
                        final currentSecond = Set<int>.from(
                            _daySecondPrayers[_selectedWeekday] ?? {});
                        setState(() {
                          _dayPrayers[6] = Set.from(current);
                          _dayPrayers[7] = Set.from(current);
                          _daySecondPrayers[6] = Set.from(currentSecond);
                          _daySecondPrayers[7] = Set.from(currentSecond);
                        });
                        await _settings.setDayPrayersMap(_dayPrayers);
                        await _settings
                            .setDaySecondPrayersMap(_daySecondPrayers);
                        await PrayerUtilities().getNamazVakitleri();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppTranslations.translate('applied_weekends_msg', fallback: "@day alarmları Hafta Sonu günlerine uygulandı!")
                                    .replaceAll('@day', activeDayName),
                              ),
                              backgroundColor: AppTheme.primaryEmerald,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                    ActionChip(
                      label: Text(AppTranslations.translate('turn_on_all_first', fallback: "Tüm 1. Vakitleri Aç")),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                          color:
                              AppTheme.primaryEmerald.withValues(alpha: 0.3)),
                      labelStyle: const TextStyle(
                        color: AppTheme.textPrimaryDark,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      onPressed: () async {
                        final all = {0, 2, 3, 4, 5};
                        setState(() {
                          _dayPrayers[_selectedWeekday] = all;
                        });
                        await _settings.setPrayersForDay(_selectedWeekday, all);
                        await PrayerUtilities().getNamazVakitleri();
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.alarm_on_rounded,
                          size: 14, color: AppTheme.goldAccent),
                      label: Text(AppTranslations.translate('turn_on_all_second', fallback: "Tüm 2. Alarmları Aç")),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                          color: AppTheme.goldAccent.withValues(alpha: 0.5)),
                      labelStyle: const TextStyle(
                        color: AppTheme.textPrimaryDark,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      onPressed: () async {
                        final all = {0, 2, 3, 4, 5};
                        setState(() {
                          _daySecondPrayers[_selectedWeekday] = all;
                        });
                        await _settings.setSecondPrayersForDay(
                            _selectedWeekday, all);
                        await PrayerUtilities().getNamazVakitleri();
                      },
                    ),
                    ActionChip(
                      label: Text(AppTranslations.translate('turn_off_all', fallback: "Tümünü Kapat")),
                      backgroundColor: Colors.white,
                      side:
                          BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                      labelStyle: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      onPressed: () async {
                        final empty = <int>{};
                        setState(() {
                          _dayPrayers[_selectedWeekday] = empty;
                          _daySecondPrayers[_selectedWeekday] = empty;
                        });
                        await _settings.setPrayersForDay(
                            _selectedWeekday, empty);
                        await _settings.setSecondPrayersForDay(
                            _selectedWeekday, empty);
                        await PrayerUtilities().getNamazVakitleri();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ─── 6 VAKİT LİSTESİ (ÇİFT ALARM KARTLARI) ───
          ..._prayersData.map((prayer) {
            final index = prayer['index'] as int;
            final name = AppTranslations.getPrayerScheduleName(index,
                defaultName: prayer['name'] as String);
            final icon = prayer['icon'] as IconData;
            final isFirstSelected = activePrayers.contains(index);
            final isSecondSelected = activeSecondPrayers.contains(index);

            return Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: (isFirstSelected || isSecondSelected)
                      ? AppTheme.primaryEmerald.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isFirstSelected
                        ? AppTheme.primaryEmerald.withValues(alpha: 0.5)
                        : (isSecondSelected
                            ? AppTheme.goldAccent.withValues(alpha: 0.5)
                            : Colors.black12),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    // 1. Ana Alarm (Vakit Girişi)
                    SwitchListTile(
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isFirstSelected
                              ? AppTheme.primaryEmerald.withValues(alpha: 0.15)
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                        child: Icon(
                          icon,
                          color: isFirstSelected
                              ? AppTheme.primaryEmerald
                              : AppTheme.textSecondaryDark,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          color: AppTheme.textPrimaryDark,
                          fontWeight: isFirstSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          fontSize: 14.5,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _showFirstAlarmDialog(
                            prayerIndex: index,
                            prayerName: name,
                          ),
                          // borderRadius: BorderRadius.circular(6),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 5,
                            runSpacing: 2,
                            children: [
                              Text(
                                AppTranslations.translate('first_alarm', fallback: "1. Alarm"),
                                style: TextStyle(
                                  color: isFirstSelected
                                      ? AppTheme.textSecondaryDark
                                      : AppTheme.textSecondaryDark
                                          .withValues(alpha: 0.8),
                                  fontSize: 11,
                                ),
                              ),
                              Builder(
                                builder: (_) {
                                  final firstMin = _settings
                                      .getFirstAlarmMinutes(prayerIndex: index);
                                  final firstTimingText =
                                      AppTranslations.getTimingLabel(firstMin);
                                  final firstSoundText =
                                      AppTranslations.getSoundTypeLabel(_soundType);

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.goldAccent
                                          .withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppTheme.goldAccent
                                            .withValues(alpha: 0.45),
                                        width: 0.7,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.timer_outlined,
                                            size: 10,
                                            color: AppTheme.goldAccent),
                                        const SizedBox(width: 3),
                                        Text(
                                          "$firstTimingText • $firstSoundText",
                                          style: const TextStyle(
                                            color: AppTheme.goldAccent,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        const Icon(Icons.edit_rounded,
                                            size: 9,
                                            color: AppTheme.goldAccent),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      value: isFirstSelected,
                      activeColor: AppTheme.primaryEmerald,
                      activeTrackColor:
                          AppTheme.goldAccent.withValues(alpha: 0.5),
                      onChanged: (val) async {
                        final current =
                            Set<int>.from(_dayPrayers[_selectedWeekday] ?? {});
                        if (val) {
                          current.add(index);
                        } else {
                          current.remove(index);
                        }
                        setState(() {
                          _dayPrayers[_selectedWeekday] = current;
                        });
                        await _settings.setPrayersForDay(
                            _selectedWeekday, current);
                        await PrayerUtilities().getNamazVakitleri();
                      },
                    ),

                    // 2. Yedek Alarm (Erteleme / Uyanma Güvencesi)
                    Container(
                      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSecondSelected
                            ? AppTheme.goldAccent.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSecondSelected
                              ? AppTheme.goldAccent.withValues(alpha: 0.6)
                              : Colors.black12,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.alarm_on_rounded,
                            color: isSecondSelected
                                ? AppTheme.goldAccent
                                : AppTheme.textSecondaryDark,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () => _showSecondAlarmDialog(
                                prayerIndex: index,
                                prayerName: name,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppTranslations.translate('second_alarm_backup', fallback: "2. Alarm (Yedek)"),
                                        style: TextStyle(
                                          color: AppTheme.textPrimaryDark,
                                          fontWeight: isSecondSelected
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.edit_rounded,
                                          size: 10, color: AppTheme.goldAccent),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.goldAccent
                                          .withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppTheme.goldAccent
                                            .withValues(alpha: 0.45),
                                        width: 0.7,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.timer_outlined,
                                            size: 10,
                                            color: AppTheme.goldAccent),
                                        const SizedBox(width: 3),
                                        Text(
                                          "${AppTranslations.getTimingLabel(_settings.getSecondAlarmMinutes(prayerIndex: index))} • ${AppTranslations.getSoundTypeLabel(_secondAlarmSoundType)}",
                                          style: const TextStyle(
                                            color: AppTheme.goldAccent,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Switch(
                            value: isSecondSelected,
                            activeColor: AppTheme.goldAccent,
                            activeTrackColor:
                                AppTheme.primaryEmerald.withValues(alpha: 0.4),
                            onChanged: (val) async {
                              final currentSecond = Set<int>.from(
                                  _daySecondPrayers[_selectedWeekday] ?? {});
                              if (val) {
                                currentSecond.add(index);
                              } else {
                                currentSecond.remove(index);
                              }
                              setState(() {
                                _daySecondPrayers[_selectedWeekday] =
                                    currentSecond;
                              });
                              await _settings.setSecondPrayersForDay(
                                  _selectedWeekday, currentSecond);
                              await PrayerUtilities().getNamazVakitleri();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.translate('app_settings', fallback: "Uygulama Ayarları")),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryEmerald,
        backgroundColor: Colors.white,
        strokeWidth: 2.5,
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dil Seçimi Kartı
              _buildLanguageCard(),
              const SizedBox(height: 16),

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
                        children: [
                          Text(
                            AppTranslations.translate('prayer_notifications_title', fallback: "Namaz Vakti Bildirimleri"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppTranslations.translate('prayer_notifications_desc', fallback: "Namaz vakitlerinde ezan okunması ve vakit öncesi hatırlatmalar."),
                            style: const TextStyle(
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
                decoration:
                    AppTheme.cardDecoration(color: AppTheme.surfaceDark),
                child: SwitchListTile(
                  secondary: Icon(
                    _notificationsEnabled
                        ? Icons.notifications_on_rounded
                        : Icons.notifications_off_rounded,
                    color: AppTheme.goldAccent,
                  ),
                  title: Text(
                    AppTranslations.translate('enable_prayer_notifications', fallback: "Namaz Bildirimlerini Aç"),
                    style: const TextStyle(
                      color: AppTheme.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    AppTranslations.translate('enable_prayer_notifications_desc', fallback: "Tüm ezan ve hatırlatma bildirimlerini aktif/pasif yapın."),
                    style: const TextStyle(
                        color: AppTheme.textSecondaryDark, fontSize: 12),
                  ),
                  value: _notificationsEnabled,
                  activeColor: AppTheme.goldAccent,
                  activeTrackColor: AppTheme.primaryEmerald,
                  onChanged: (bool value) async {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    await _settings.setNotificationsEnabled(value);
                    await PrayerUtilities().getNamazVakitleri();
                  },
                ),
              ),
              const SizedBox(height: 20),

              if (_notificationsEnabled) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    AppTranslations.translate(
                      'daily_weekly_alarms_title',
                      fallback: "GÜNLÜK VE HAFTALIK VAKİT ALARMLARI",
                    ),
                    style: const TextStyle(
                      color: AppTheme.goldAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                _buildWeeklyPrayerScheduleSection(),
                const SizedBox(height: 20),

                // Section 2: Ezan & Ses Tercihi
                // const Padding(
                //   padding: EdgeInsets.only(left: 4, bottom: 8),
                //   child: Text(
                //     "TAM NAMAZ VAKTİ VE EZAN AYARLARI",
                //     style: TextStyle(
                //       color: AppTheme.goldAccent,
                //       fontSize: 12,
                //       fontWeight: FontWeight.bold,
                //       letterSpacing: 0.8,
                //     ),
                //   ),
                // ),
                // Container(
                //   decoration:
                //       AppTheme.cardDecoration(color: AppTheme.surfaceDark),
                //   child: Column(
                //     children: [
                //       SwitchListTile(
                //         secondary: const Icon(Icons.mosque_rounded,
                //             color: AppTheme.goldAccent),
                //         title: const Text(
                //           "Tam Namaz Vaktinde Bildirim / Ezan",
                //           style: TextStyle(
                //             color: AppTheme.textPrimaryDark,
                //             fontWeight: FontWeight.w600,
                //           ),
                //         ),
                //         subtitle: const Text(
                //           "Namaz vakti tam girdiğinde bildirim gönderilsin veya ezan okunsun.",
                //           style: TextStyle(
                //               color: AppTheme.textSecondaryDark, fontSize: 12),
                //         ),
                //         value: _ezanEnabled,
                //         activeColor: AppTheme.goldAccent,
                //         activeTrackColor: AppTheme.primaryEmerald,
                //         onChanged: (val) async {
                //           setState(() => _ezanEnabled = val);
                //           await _settings.setEzanEnabled(val);
                //           await PrayerUtilities().getNamazVakitleri();
                //         },
                //       ),
                //       if (_ezanEnabled) ...[
                //         const Divider(color: Colors.white12, height: 1),
                //         ListTile(
                //           leading: Icon(
                //             _soundType == 'ezan'
                //                 ? Icons.mosque_rounded
                //                 : (_soundType == 'alarm'
                //                     ? Icons.alarm_rounded
                //                     : Icons.notifications_active_rounded),
                //             color: AppTheme.goldAccent,
                //           ),
                //           title: Text(
                //             () {
                //               final min = _settings.firstAlarmMinutes;
                //               final timeStr = min == 0
                //                   ? "Tam Vakit"
                //                   : (min < 0
                //                       ? "${-min} dk önce"
                //                       : "+$min dk sonra");
                //               final soundStr = _soundType == 'ezan'
                //                   ? "Ezan"
                //                   : (_soundType == 'alarm'
                //                       ? "Çalar Saat"
                //                       : "Bildirim");
                //               return "1. Alarm: $timeStr • $soundStr";
                //             }(),
                //             style: const TextStyle(
                //               color: AppTheme.textPrimaryDark,
                //               fontWeight: FontWeight.w600,
                //               fontSize: 13.5,
                //             ),
                //           ),
                //           subtitle: const Text(
                //             "Alarm zamanını ve zil sesini değiştirmek için dokunun",
                //             style: TextStyle(
                //               color: AppTheme.textSecondaryDark,
                //               fontSize: 11.5,
                //             ),
                //           ),
                //           trailing: Container(
                //             padding: const EdgeInsets.symmetric(
                //                 horizontal: 10, vertical: 4),
                //             decoration: BoxDecoration(
                //               color:
                //                   AppTheme.goldAccent.withValues(alpha: 0.18),
                //               borderRadius: BorderRadius.circular(8),
                //               border: Border.all(
                //                 color:
                //                     AppTheme.goldAccent.withValues(alpha: 0.5),
                //                 width: 1,
                //               ),
                //             ),
                //             child: const Row(
                //               mainAxisSize: MainAxisSize.min,
                //               children: [
                //                 Text(
                //                   "Değiştir",
                //                   style: TextStyle(
                //                     color: AppTheme.goldAccent,
                //                     fontSize: 12,
                //                     fontWeight: FontWeight.bold,
                //                   ),
                //                 ),
                //                 SizedBox(width: 4),
                //                 Icon(Icons.edit_rounded,
                //                     color: AppTheme.goldAccent, size: 12),
                //               ],
                //             ),
                //           ),
                //           onTap: () => _showFirstAlarmDialog(),
                //         ),
                //       ],
                //     ],
                //   ),
                // ),
                // const SizedBox(height: 20),

                // // Section 3: Hatırlatma
                // const Padding(
                //   padding: EdgeInsets.only(left: 4, bottom: 8),
                //   child: Text(
                //     "VAKTİNDEN ÖNCE HATIRLATMA BİLDİRİMİ",
                //     style: TextStyle(
                //       color: AppTheme.goldAccent,
                //       fontSize: 12,
                //       fontWeight: FontWeight.bold,
                //       letterSpacing: 0.8,
                //     ),
                //   ),
                // ),
                // Container(
                //   decoration:
                //       AppTheme.cardDecoration(color: AppTheme.surfaceDark),
                //   child: Column(
                //     children: [
                //       SwitchListTile(
                //         secondary: const Icon(Icons.alarm_rounded,
                //             color: AppTheme.goldAccent),
                //         title: const Text(
                //           "Vaktinden Önce Hatırlatma Al",
                //           style: TextStyle(
                //             color: AppTheme.textPrimaryDark,
                //             fontWeight: FontWeight.w600,
                //           ),
                //         ),
                //         subtitle: Text(
                //           _preNotificationEnabled
                //               ? "Namaz vaktine $_notificationTiming dakika kala hatırlatılır."
                //               : "Namaz vakti girmeden önce hatırlatma kapalı.",
                //           style: const TextStyle(
                //               color: AppTheme.textSecondaryDark, fontSize: 12),
                //         ),
                //         value: _preNotificationEnabled,
                //         activeColor: AppTheme.goldAccent,
                //         activeTrackColor: AppTheme.primaryEmerald,
                //         onChanged: (val) async {
                //           setState(() => _preNotificationEnabled = val);
                //           await _settings.setPreNotificationEnabled(val);
                //           await PrayerUtilities().getNamazVakitleri();
                //         },
                //       ),
                //       if (_preNotificationEnabled) ...[
                //         const Divider(color: Colors.white12, height: 1),
                //         ListTile(
                //           leading: const Icon(Icons.timer_outlined,
                //               color: AppTheme.goldAccent),
                //           title: Text(
                //             "Hatırlatma Süresi: $_notificationTiming dk önce",
                //             style: const TextStyle(
                //               color: AppTheme.textPrimaryDark,
                //               fontWeight: FontWeight.w600,
                //               fontSize: 13.5,
                //             ),
                //           ),
                //           subtitle: const Text(
                //             "Hatırlatma dakikasını değiştirmek için dokunun",
                //             style: TextStyle(
                //                 color: AppTheme.textSecondaryDark,
                //                 fontSize: 11.5),
                //           ),
                //           trailing: Container(
                //             padding: const EdgeInsets.symmetric(
                //                 horizontal: 10, vertical: 4),
                //             decoration: BoxDecoration(
                //               color:
                //                   AppTheme.goldAccent.withValues(alpha: 0.18),
                //               borderRadius: BorderRadius.circular(8),
                //               border: Border.all(
                //                 color:
                //                     AppTheme.goldAccent.withValues(alpha: 0.5),
                //                 width: 1,
                //               ),
                //             ),
                //             child: const Row(
                //               mainAxisSize: MainAxisSize.min,
                //               children: [
                //                 Text(
                //                   "Değiştir",
                //                   style: TextStyle(
                //                     color: AppTheme.goldAccent,
                //                     fontSize: 12,
                //                     fontWeight: FontWeight.bold,
                //                   ),
                //                 ),
                //                 SizedBox(width: 4),
                //                 Icon(Icons.edit_rounded,
                //                     color: AppTheme.goldAccent, size: 12),
                //               ],
                //             ),
                //           ),
                //           onTap: () => _showMinutePickerDialog(
                //             title: "Vaktinden Önce Hatırlatma Süresi",
                //             initialMinutes: _notificationTiming,
                //             isSecondAlarm: false,
                //           ),
                //         ),
                //       ],
                //     ],
                //   ),
                // ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
