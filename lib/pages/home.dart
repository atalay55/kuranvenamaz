import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContentItem currentAyet = ContentData.getRandomAyet();
  ContentItem currentHadis = ContentData.getRandomHadis();
  ContentItem currentDua = ContentData.getRandomDua();

  @override
  void initState() {
    super.initState();
    _refreshContent();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeNotificationPrompt();
    });
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

  void _showNotificationOnboardingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.goldAccent, width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.mosque_rounded, color: AppTheme.goldAccent, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Namaz Bildirimleri",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Namaz vakitlerinde ezan okunmasını veya 1 dakika öncesinde hatırlatma bildirimi almayı ister misiniz?",
                style: TextStyle(
                    color: AppTheme.textPrimaryDark, fontSize: 14, height: 1.4),
              ),
              SizedBox(height: 12),
              Text(
                "• Vaktinden 1 dakika önce uyarı verilebilir.\n• Dilediğiniz zaman Ayarlar sayfasından değiştirebilirsiniz.",
                style: TextStyle(
                    color: AppTheme.goldLight, fontSize: 12, height: 1.3),
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
                      side: const BorderSide(color: AppTheme.goldAccent),
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
                    await s.setNotificationTiming(1);
                    await s.setAskedPrompt(true);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    Get.to(() => const SettingsPage());
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.goldAccent,
                    side: const BorderSide(color: AppTheme.goldAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Text("🔔 ", style: TextStyle(fontSize: 16)),
                  label: const Text(
                    "Evet, Standart Bildirim Ver (1 Dk Önce)",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    final s = SettingsService();
                    await s.setNotificationsEnabled(true);
                    await s.setSoundType('notification');
                    await s.setNotificationTiming(1);
                    await s.setAskedPrompt(true);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    Get.to(() => const SettingsPage());
                  },
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () async {
                    final s = SettingsService();
                    await s.setNotificationsEnabled(false);
                    await s.setAskedPrompt(true);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Şimdilik İstemiyorum",
                    style: TextStyle(
                        color: AppTheme.textSecondaryDark, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Namaz ve Kur'an"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.goldAccent),
            tooltip: 'İçerik Yenile',
            onPressed: _refreshContent,
          ),
          IconButton(
            icon:
                const Icon(Icons.settings_rounded, color: AppTheme.goldAccent),
            tooltip: 'Ayarlar',
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
            // Main Prayer Clock Dashboard
            const MainPrayerClockWidget(),
            const SizedBox(height: 16),

            // Quick Access Features Bar
            _buildQuickAccessBar(),
            const SizedBox(height: 16),

            // Daily Content Cards
            AyetDuaHadisTheme(
              title: currentAyet.title,
              arabicText: currentAyet.arabic,
              description: currentAyet.turkish,
              kaynakca: currentAyet.source,
            ),
            AyetDuaHadisTheme(
              title: currentHadis.title,
              arabicText: currentHadis.arabic,
              description: currentHadis.turkish,
              kaynakca: currentHadis.source,
            ),
            AyetDuaHadisTheme(
              title: currentDua.title,
              arabicText: currentDua.arabic,
              description: currentDua.turkish,
              kaynakca: currentDua.source,
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
              label: "Kur'an-ı Kerim",
              onTap: () => Get.to(() => const SurahListPage()),
            ),
            const SizedBox(width: 8),
            _buildQuickTile(
              icon: Icons.auto_stories_rounded,
              label: "Hadis-i Şerifler",
              onTap: () => Get.to(() => const HadithListPage()),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildQuickTile(
              icon: Icons.fingerprint_rounded,
              label: "Zikirmatik",
              onTap: () => Get.to(() => const Zikirmatik()),
            ),
            const SizedBox(width: 8),
            _buildQuickTile(
              icon: Icons.explore_rounded,
              label: "Kıble Pusulası",
              onTap: () => Get.to(() => const QiblahCompass()),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildQuickTile(
              icon: Icons.calendar_month_rounded,
              label: "Hicri Takvim",
              onTap: () => Get.to(() => const HijriCalendarWidget()),
            ),
            const SizedBox(width: 8),
            _buildQuickTile(
              icon: Icons.settings_rounded,
              label: "Ayarlar & Ezan",
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mosque_rounded,
                    color: AppTheme.goldAccent, size: 42),
                SizedBox(height: 10),
                Text(
                  "Namaz ve Kur'an",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Huzur rehberiniz",
                  style: TextStyle(color: AppTheme.goldLight, fontSize: 13),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_rounded, color: AppTheme.goldAccent),
            title:
                const Text("Ana Sayfa", style: TextStyle(color: Colors.black)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded,
                color: Color.fromRGBO(197, 160, 89, 1)),
            title: const Text("Kur'an-ı Kerim",
                style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const SurahListPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_stories_rounded,
                color: AppTheme.goldAccent),
            title: const Text("Hadis-i Şerifler",
                style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const HadithListPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint_rounded,
                color: AppTheme.goldAccent),
            title:
                const Text("Zikirmatik", style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const Zikirmatik());
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.explore_rounded, color: AppTheme.goldAccent),
            title: const Text("Kıble Pusulası",
                style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const QiblahCompass());
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_rounded,
                color: AppTheme.goldAccent),
            title: const Text("Hicri Takvim",
                style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const HijriCalendarWidget());
            },
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading:
                const Icon(Icons.settings_rounded, color: AppTheme.goldAccent),
            title: const Text("Ayarlar & Ezan",
                style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const SettingsPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_city_rounded,
                color: AppTheme.goldAccent),
            title: const Text("Şehir / Ülke Değiştir",
                style: TextStyle(color: Colors.black)),
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
