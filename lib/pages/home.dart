import 'package:flutter/material.dart';
import 'package:kuranvenamaz/pages/quran/surah_list_page.dart';

import 'package:get/get.dart';
import 'package:kuranvenamaz/core/content_data.dart';
import 'package:kuranvenamaz/hijricalendar/hijricalendar.dart';
import 'package:kuranvenamaz/pages/compass_pages/qiblah_screen.dart';
import 'package:kuranvenamaz/pages/prayertime/mainprayerclockwidget.dart';
import 'package:kuranvenamaz/pages/selectablepage/countryselect.dart';
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
  }

  void _refreshContent() async {
    final liveAyet = await ContentData.fetchLiveAyet();
    if (mounted) {
      setState(() {
        currentAyet = liveAyet;
        currentHadis = ContentData.getRandomHadis();
        currentDua = ContentData.getRandomDua();
      });
    }
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
              icon: Icons.fingerprint_rounded,
              label: "Zikirmatik",
              onTap: () => Get.to(() => const Zikirmatik()),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildQuickTile(
              icon: Icons.explore_rounded,
              label: "Kıble Pusulası",
              onTap: () => Get.to(() => const QiblahCompass()),
            ),
            const SizedBox(width: 8),
            _buildQuickTile(
              icon: Icons.calendar_month_rounded,
              label: "Hicri Takvim",
              onTap: () => Get.to(() => const HijriCalendarWidget()),
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
                Icon(Icons.mosque_rounded, color: AppTheme.goldAccent, size: 42),
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
            title: const Text("Ana Sayfa", style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded, color: AppTheme.goldAccent),
            title: const Text("Kur'an-ı Kerim", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const SurahListPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint_rounded, color: AppTheme.goldAccent),
            title: const Text("Zikirmatik", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const Zikirmatik());
            },
          ),
          ListTile(
            leading: const Icon(Icons.explore_rounded, color: AppTheme.goldAccent),
            title: const Text("Kıble Pusulası", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => QiblahCompass());
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_rounded, color: AppTheme.goldAccent),
            title: const Text("Hicri Takvim", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const HijriCalendarWidget());
            },
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.location_city_rounded, color: AppTheme.goldAccent),
            title: const Text("Şehir / Ülke Değiştir", style: TextStyle(color: Colors.white)),
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
