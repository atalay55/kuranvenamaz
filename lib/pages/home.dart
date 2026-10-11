import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/core/device_settings_service.dart';
import 'package:kuranvenamaz/core/content_data.dart';
import 'package:kuranvenamaz/core/settings_service.dart';
import 'package:kuranvenamaz/hijricalendar/hijricalendar.dart';
import 'package:kuranvenamaz/pages/compass_pages/qiblah_screen.dart';
import 'package:kuranvenamaz/pages/hadith/hadith_list_page.dart';
import 'package:kuranvenamaz/pages/prayertime/mainprayerclockwidget.dart';
import 'package:kuranvenamaz/pages/quran/surah_list_page.dart';
import 'package:kuranvenamaz/pages/selectablepage/countryselect.dart';
import 'package:kuranvenamaz/pages/settings/settings_page.dart';
import 'package:kuranvenamaz/pages/zikirmatik_pages/zikirmatik.dart';
import 'package:kuranvenamaz/theme/app_theme.dart';
import 'package:kuranvenamaz/theme/ayetduahadistheme.dart';
import 'package:kuranvenamaz/core/app_translations.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  ContentItem currentAyet = ContentData.getRandomAyet();
  ContentItem currentHadis = ContentData.getRandomHadis();
  ContentItem currentDua = ContentData.getRandomDua();
  bool _showOEMWarningBanner = false;

  @override
  void initState() {
    super.initState();
    AppTranslations.init();
    AppTranslations.currentLocaleNotifier.addListener(_onLocaleChanged);
    WidgetsBinding.instance.addObserver(this);
    _refreshContent();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeNotificationPrompt();
      _checkOEMBatteryOptimization();
    });
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {});
      _refreshContent();
    }
  }

  @override
  void dispose() {
    AppTranslations.currentLocaleNotifier.removeListener(_onLocaleChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    if (mounted) {
      _refreshContent();
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkOEMBatteryOptimization();
    }
  }

  Future<void> _checkOEMBatteryOptimization() async {
    try {
      final settings = SettingsService();
      await settings.initSettings();
      if (settings.oemBannerDismissed) {
        if (mounted) {
          setState(() {
            _showOEMWarningBanner = false;
          });
        }
        return;
      }

      final manufacturer =
          (await DeviceSettingsService.getDeviceManufacturer()).toLowerCase();
      final isIgnoring =
          await DeviceSettingsService.isIgnoringBatteryOptimizations();

      final isOEM = manufacturer.contains("xiaomi") ||
          manufacturer.contains("redmi") ||
          manufacturer.contains("poco") ||
          manufacturer.contains("samsung") ||
          manufacturer.contains("huawei") ||
          manufacturer.contains("oppo") ||
          manufacturer.contains("vivo");

      if (mounted) {
        setState(() {
          _showOEMWarningBanner = isOEM && !isIgnoring;
        });
      }
    } catch (e) {
      debugPrint("OEM check error: $e");
    }
  }

  void _refreshContent() async {
    final results = await Future.wait([
      ContentData.fetchLiveAyet(),
      ContentData.fetchLiveHadis(),
    ]);
    if (mounted) {
      setState(() {
        currentAyet = results[0];
        currentHadis = results[1];
        currentDua = ContentData.getRandomDua();
      });
    }
  }

  Future<void> _checkFirstTimeNotificationPrompt() async {
    final settings = SettingsService();
    await settings.initSettings();
    if (!settings.askedPrompt) {
      if (!mounted) return;
      _showNotificationOnboardingDialog(context);
    }
  }

  void _showNotificationOnboardingDialog([BuildContext? contextParam]) {
    final targetContext = (contextParam != null && contextParam.mounted)
        ? contextParam
        : (Get.context ?? context);
    if (!targetContext.mounted) return;

    showDialog(
      context: targetContext,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.goldAccent, width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.mosque_rounded, color: AppTheme.primaryEmerald, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Namaz Bildirimleri",
                  style: TextStyle(
                    color: Color(0xFF1B1B1B), // Siyah yapıldı
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Namaz vakitlerinde ezan okunmasını veya 1 dakika öncesinde hatırlatma bildirimi almayı ister misiniz?",
                style: TextStyle(
                    color: Color(0xFF2A2A2A), fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B4D3E).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1B4D3E).withOpacity(0.25)),
                ),
                child: const Text(
                  "• Vaktinden 1 dakika önce uyarı verilebilir.\n• Dilediğiniz zaman Ayarlar sayfasından değiştirebilirsiniz.",
                  style: TextStyle(
                      color: Color(0xFF1B4D3E), // Sarı yerine okunaklı koyu zümrüt tonu
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Text("🕌 ", style: TextStyle(fontSize: 16)),
                  label: const Text(
                    "Evet, Ezan Sesi İle Hatırlat (1 Dk Önce)",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    final s = SettingsService();
                    await s.setNotificationsEnabled(true);
                    await s.setSoundType('ezan');
                    await s.setNotificationTiming(15);
                    await s.setAskedPrompt(true);
                    if (dialogCtx.mounted) {
                      Navigator.of(dialogCtx).pop();
                    }
                    await DeviceSettingsService
                        .openBatteryOptimizationSettings();
                    if (!mounted) return;
                    _showOEMPermissionDialog();
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1B4D3E),
                    side: const BorderSide(color: Color(0xFF1B4D3E), width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Text("🔔 ", style: TextStyle(fontSize: 16)),
                  label: const Text(
                    "Evet, Standart Bildirim Ver (15 Dk Önce)",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4D3E)),
                  ),
                  onPressed: () async {
                    final s = SettingsService();
                    await s.setNotificationsEnabled(true);
                    await s.setSoundType('notification');
                    await s.setNotificationTiming(15);
                    await s.setAskedPrompt(true);
                    if (dialogCtx.mounted) {
                      Navigator.of(dialogCtx).pop();
                    }
                    if (!mounted) return;
                    _showOEMPermissionDialog();
                  },
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () async {
                    final s = SettingsService();
                    await s.setNotificationsEnabled(false);
                    await s.setAskedPrompt(true);
                    if (dialogCtx.mounted) {
                      Navigator.of(dialogCtx).pop();
                    }
                  },
                  child: const Text(
                    "Şimdilik İstemiyorum",
                    style: TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showOEMPermissionDialog([BuildContext? contextParam]) async {
    final permStatus = await DeviceSettingsService.checkNotificationPermissions();
    if (!mounted) return;

    final targetContext = (contextParam != null && contextParam.mounted)
        ? contextParam
        : (Get.context ?? context);
    if (!targetContext.mounted) return;

    final manufacturer = permStatus?.manufacturer ?? 'Bilinmiyor';
    final isXiaomi = permStatus?.isXiaomi ?? false;

    showDialog(
      context: targetContext,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.goldAccent, width: 1.5),
          ),
          title: const Row(
            children: [
              Text("🕌", style: TextStyle(fontSize: 24)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Ezan İzinleri",
                  style: TextStyle(
                    color: Color(0xFF1B1B1B), // Siyah
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Açıklama
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B4D3E).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1B4D3E).withOpacity(0.2)),
                ),
                child: Text(
                  "$manufacturer telefonunuzda ezan tam vaktinde çalabilmesi için 2 kolay ayar yapmanız gerekiyor. Her butona sırayla basın:",
                  style: const TextStyle(
                    color: Color(0xFF2C2C2C),
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ADIM 1 — Pil optimizasyonu (sistem dialogu, çok kolay)
              _buildPermissionStep(
                step: "1",
                emoji: "🔋",
                title: "Pil Kısıtlamasını Kaldır",
                description: "Açılan küçük pencerede sadece 'İzin Ver' veya 'Kısıtlama Yok' deyin.",
                buttonLabel: "Ayarı Aç →",
                onTap: () async {
                  // Bu direkt sistem popup'ı açıyor, çok basit
                  await DeviceSettingsService.openBatteryOptimizationSettings();
                },
              ),
              const SizedBox(height: 10),

              // ADIM 2 — Autostart (sistem listesi, rehber gerekli)
              _buildPermissionStep(
                step: "2",
                emoji: "▶️",
                title: "Arka Planda Çalışmaya İzin Ver",
                description: isXiaomi
                    ? "Açılan ekranda 'Kuran ve Namaz' uygulamasını bulup yanındaki düğmeyi açın (yeşile çevirin), sonra geri tuşuna basın."
                    : "Açılan ekranda 'Kuran ve Namaz' uygulamasını bulup izin verin, sonra geri tuşuna basın.",
                buttonLabel: "Listeyi Aç →",
                onTap: () => _showAutostartPreGuideAndOpen(ctx, isXiaomi),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final s = SettingsService();
                await s.setOemBannerDismissed(true);
                _checkOEMBatteryOptimization();
              },
              child: const Text(
                "Tamamlandı",
                style: TextStyle(
                    color: Color(0xFF1B4D3E),
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Autostart açmadan önce çok net bir "şimdi ne yapacaksın" dialogu
  Future<void> _showAutostartPreGuideAndOpen(
      BuildContext targetContext, bool isXiaomi) async {
    if (!mounted) return;
    final validContext = targetContext.mounted
        ? targetContext
        : (Get.context ?? context);
    if (!validContext.mounted) return;

    await showDialog(
      context: validContext,
      barrierDismissible: false,
      builder: (guideCtx) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.goldAccent, width: 1.5),
          ),
          title: const Row(
            children: [
              Text("👆", style: TextStyle(fontSize: 24)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Şimdi ne yapacaksınız?",
                  style: TextStyle(
                    color: Color(0xFF1B1B1B),
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Adım adım kutu
              _buildGuideStep(
                  number: "1",
                  text: "'Tamam, Açalım' butonuna basın"),
              const SizedBox(height: 8),
              _buildGuideStep(
                  number: "2",
                  text: isXiaomi
                      ? "Açılan listede aşağı kaydırarak 'Kuran ve Namaz' uygulamasını bulun"
                      : "Açılan ekranda 'Kuran ve Namaz' uygulamasını bulun"),
              const SizedBox(height: 8),
              _buildGuideStep(
                  number: "3",
                  text: isXiaomi
                      ? "Uygulamanın sağındaki düğmeye dokunun → Yeşil olsun"
                      : "Uygulamaya dokunun ve izin verin"),
              const SizedBox(height: 8),
              _buildGuideStep(
                  number: "4",
                  text: "Geri tuşuna basıp buraya dönün"),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B4D3E).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF1B4D3E).withOpacity(0.25),
                      width: 1),
                ),
                child: Row(
                  children: [
                    const Text("💡", style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isXiaomi
                            ? "İpucu: Liste alfabetik değil, uygulama adına göre sıralı. 'K' harfine bakın."
                            : "İpucu: Listede 'Kuran ve Namaz' yazan satırı arayın.",
                        style: const TextStyle(
                            color: Color(0xFF1B4D3E),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryEmerald,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppTheme.goldAccent),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(guideCtx);
                  // Artık açıyoruz
                  await DeviceSettingsService.openAutostartSettings();
                },
                child: const Text(
                  "Tamam, Açalım ✓",
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGuideStep({required String number, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: AppTheme.primaryEmerald,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF2C2C2C),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionStep({
    required String step,
    required String emoji,
    required String title,
    required String description,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppTheme.goldAccent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(step,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1B1B1B), // Siyah
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
                color: Color(0xFF2C2C2C), fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryEmerald,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onTap,
              child: Text(
                buttonLabel,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold),
              ),
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
        title: Text(AppTranslations.translate("app_title", fallback: "Namaz ve Kur'an")),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.goldAccent),
            tooltip: AppTranslations.translate('refresh', fallback: 'Yenile'),
            onPressed: _refreshContent,
          ),
          IconButton(
            icon:
                const Icon(Icons.settings_rounded, color: AppTheme.goldAccent),
            tooltip: AppTranslations.translate('settings', fallback: 'Ayarlar'),
            onPressed: () => Get.to(() => const SettingsPage()),
          ),
        ],
      ),
      drawer: _buildAppDrawer(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showOEMWarningBanner) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade900.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade600, width: 1.2),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.amber.shade400, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "oem_banner_text".tr,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _showOEMPermissionDialog(context),
                      child: Text("allow".tr,
                          style: const TextStyle(
                              color: AppTheme.goldAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white60, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'close'.tr,
                      onPressed: () async {
                        final s = SettingsService();
                        await s.setOemBannerDismissed(true);
                        if (mounted) {
                          setState(() {
                            _showOEMWarningBanner = false;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Main Prayer Clock Dashboard
            const MainPrayerClockWidget(),
            const SizedBox(height: 16),

            // Quick Access Features Bar
            _buildQuickAccessBar(),
            const SizedBox(height: 16),

            // Daily Content Cards
            AyetDuaHadisTheme(
              title: AppTranslations.getLocalizedCardTitle(currentAyet.title),
              arabicText: currentAyet.arabic,
              description: currentAyet.getText(),
              kaynakca: currentAyet.getSource(),
            ),
            AyetDuaHadisTheme(
              title: AppTranslations.getLocalizedCardTitle(currentHadis.title),
              arabicText: currentHadis.arabic,
              description: currentHadis.getText(),
              kaynakca: currentHadis.getSource(),
            ),
            AyetDuaHadisTheme(
              title: AppTranslations.getLocalizedCardTitle(currentDua.title),
              arabicText: currentDua.arabic,
              description: currentDua.getText(),
              kaynakca: currentDua.getSource(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessBar() {
    return Column(
      children: [
        Row(
          children: [
            _buildQuickTile(
              icon: Icons.menu_book_rounded,
              label: AppTranslations.translate("quran", fallback: "Kur'an-ı Kerim"),
              onTap: () => Get.to(() => const SurahListPage()),
            ),
            const SizedBox(width: 8),
            _buildQuickTile(
              icon: Icons.auto_stories_rounded,
              label: AppTranslations.translate("hadiths", fallback: "Hadis-i Şerifler"),
              onTap: () => Get.to(() => const HadithListPage()),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildQuickTile(
              icon: Icons.fingerprint_rounded,
              label: AppTranslations.translate("dhikr", fallback: "Zikirmatik"),
              onTap: () => Get.to(() => const Zikirmatik()),
            ),
            const SizedBox(width: 8),
            _buildQuickTile(
              icon: Icons.explore_rounded,
              label: AppTranslations.translate("qibla", fallback: "Kıble Pusulası"),
              onTap: () => Get.to(() => const QiblahCompass()),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildQuickTile(
              icon: Icons.calendar_month_rounded,
              label: AppTranslations.translate("hijri_calendar", fallback: "Hicri Takvim"),
              onTap: () => Get.to(() => const HijriCalendarWidget()),
            ),
            const SizedBox(width: 8),
            _buildQuickTile(
              icon: Icons.settings_rounded,
              label: AppTranslations.translate("settings_adhan", fallback: "Ayarlar & Ezan"),
              onTap: () => Get.to(() => const SettingsPage()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: AppTheme.cardDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.goldAccent, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textPrimaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.bgDark,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: AppTheme.headerGradientDecoration(
              borderRadius: BorderRadius.zero,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mosque_rounded,
                    color: AppTheme.goldAccent, size: 42),
                const SizedBox(height: 10),
                Text(
                  AppTranslations.translate("app_title", fallback: "Namaz ve Kur'an"),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppTranslations.translate("peace_guide", fallback: "Huzur rehberiniz"),
                  style: const TextStyle(color: AppTheme.goldLight, fontSize: 13),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_rounded, color: AppTheme.goldAccent),
            title: Text(AppTranslations.translate("home", fallback: "Ana Sayfa"), style: const TextStyle(color: AppTheme.textPrimaryDark, fontWeight: FontWeight.w500)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded, color: AppTheme.goldAccent),
            title: Text(AppTranslations.translate("quran", fallback: "Kur'an-ı Kerim"), style: const TextStyle(color: AppTheme.textPrimaryDark, fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const SurahListPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_stories_rounded, color: AppTheme.goldAccent),
            title: Text(AppTranslations.translate("hadiths", fallback: "Hadis-i Şerifler"), style: const TextStyle(color: AppTheme.textPrimaryDark, fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const HadithListPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint_rounded, color: AppTheme.goldAccent),
            title: Text(AppTranslations.translate("dhikr", fallback: "Zikirmatik"), style: const TextStyle(color: AppTheme.textPrimaryDark, fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const Zikirmatik());
            },
          ),
          ListTile(
            leading: const Icon(Icons.explore_rounded, color: AppTheme.goldAccent),
            title: Text(AppTranslations.translate("qibla", fallback: "Kıble Pusulası"), style: const TextStyle(color: AppTheme.textPrimaryDark, fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const QiblahCompass());
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_rounded, color: AppTheme.goldAccent),
            title: Text(AppTranslations.translate("hijri_calendar", fallback: "Hicri Takvim"), style: const TextStyle(color: AppTheme.textPrimaryDark, fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const HijriCalendarWidget());
            },
          ),
          const Divider(color: Colors.black12),
          ListTile(
            leading: const Icon(Icons.settings_rounded, color: AppTheme.goldAccent),
            title: Text(AppTranslations.translate("settings_adhan", fallback: "Ayarlar & Ezan"), style: const TextStyle(color: AppTheme.textPrimaryDark, fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const SettingsPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_city_rounded, color: AppTheme.goldAccent),
            title: Text(AppTranslations.translate("change_location", fallback: "Şehir / Ülke Değiştir"), style: const TextStyle(color: AppTheme.textPrimaryDark, fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const CountrySelectPage());
            },
          ),
        ],
      ),
    );
  }
}
