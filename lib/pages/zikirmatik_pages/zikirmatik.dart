import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/core/app_translations.dart';
import 'package:kuranvenamaz/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class ZikirItem {
  final String titleTr;
  final String titleEn;
  final String titleDe;
  final String titleAr;
  final String arabic;
  final String meaningTr;
  final String meaningEn;
  final String meaningDe;
  final String meaningAr;

  const ZikirItem({
    required this.titleTr,
    required this.titleEn,
    required this.titleDe,
    required this.titleAr,
    required this.arabic,
    required this.meaningTr,
    required this.meaningEn,
    required this.meaningDe,
    required this.meaningAr,
  });

  String getTitle(String lang) {
    switch (lang) {
      case 'de':
        return titleDe;
      case 'en':
        return titleEn;
      case 'ar':
        return titleAr;
      default:
        return titleTr;
    }
  }

  String getMeaning(String lang) {
    switch (lang) {
      case 'de':
        return meaningDe;
      case 'en':
        return meaningEn;
      case 'ar':
        return meaningAr;
      default:
        return meaningTr;
    }
  }
}

class Zikirmatik extends StatefulWidget {
  const Zikirmatik({Key? key}) : super(key: key);

  @override
  State<Zikirmatik> createState() => _ZikirmatikState();
}

class _ZikirmatikState extends State<Zikirmatik> {
  RxInt count = RxInt(0);
  RxInt tourCount = RxInt(0);
  int targetLimit = 33;
  bool isVibrationEnabled = true;

  final List<ZikirItem> zikirList = const [
    ZikirItem(
      titleTr: "Sübhânallah",
      titleEn: "SubhanAllah",
      titleDe: "SubhanAllah",
      titleAr: "سُبْحَانَ اللَّهِ",
      arabic: "سُبْحَانَ اللَّهِ",
      meaningTr: "Allah noksan sıfatlardan münezzehtir.",
      meaningEn: "Glory be to Allah.",
      meaningDe: "Gepriesen sei Allah (erhaben über alle Mängel).",
      meaningAr: "تنزيه الله تعالى عن كل نقص وعيب.",
    ),
    ZikirItem(
      titleTr: "Elhamdülillâh",
      titleEn: "Alhamdulillah",
      titleDe: "Alhamdulillah",
      titleAr: "الْحَمْدُ لِلَّهِ",
      arabic: "الْحَمْدُ لِلَّهِ",
      meaningTr: "Hamd Allah'a mahsustur.",
      meaningEn: "All praise is due to Allah.",
      meaningDe: "Alles Lob und aller Dank gebührt Allah.",
      meaningAr: "الثناء والشكر كله لله عز وجل.",
    ),
    ZikirItem(
      titleTr: "Allâhu Ekber",
      titleEn: "Allahu Akbar",
      titleDe: "Allahu Akbar",
      titleAr: "اللَّهُ أَكْبَرُ",
      arabic: "اللَّهُ أَكْبَرُ",
      meaningTr: "Allah en büyüktür.",
      meaningEn: "Allah is the Greatest.",
      meaningDe: "Allah ist der Größte.",
      meaningAr: "الله أعظم وأجل من كل شيء.",
    ),
    ZikirItem(
      titleTr: "Lâ ilâhe illallâh",
      titleEn: "La ilaha illallah",
      titleDe: "La ilaha illallah",
      titleAr: "لَا إِلٰهَ إِلَّا اللَّهُ",
      arabic: "لَا إِلٰهَ إِلَّا اللَّهُ",
      meaningTr: "Allah'tan başka ilah yoktur.",
      meaningEn: "There is no deity worthy of worship except Allah.",
      meaningDe: "Es gibt keinen anbetungswürdigen Gott außer Allah.",
      meaningAr: "لا معبود بحق إلا الله وحده لا شريك له.",
    ),
    ZikirItem(
      titleTr: "Estağfirullâh",
      titleEn: "Astaghfirullah",
      titleDe: "Astaghfirullah",
      titleAr: "أَسْتَغْفِرُ اللَّهَ",
      arabic: "أَسْتَغْفِرُ اللَّهَ",
      meaningTr: "Allah'tan bağışlanma dilerim.",
      meaningEn: "I seek forgiveness from Allah.",
      meaningDe: "Ich bitte Allah um Vergebung.",
      meaningAr: "أطلب المغفرة والستر من الله تعالى.",
    ),
    ZikirItem(
      titleTr: "Lâ Havle",
      titleEn: "La Hawla",
      titleDe: "La Hawla",
      titleAr: "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ",
      arabic: "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ",
      meaningTr: "Güç ve kuvvet ancak Allah'a aittir.",
      meaningEn: "There is no power nor strength except with Allah.",
      meaningDe: "Es gibt keine Macht noch Kraft außer durch Allah.",
      meaningAr: "لا حول ولا قوة إلا بالله العلي العظيم.",
    ),
    ZikirItem(
      titleTr: "Salavât-ı Şerîfe",
      titleEn: "Salawat",
      titleDe: "Salawat",
      titleAr: "الصلاة على النبي",
      arabic: "اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ",
      meaningTr: "Allah'ım! Efendimiz Muhammed'e salât ve selâm eyle.",
      meaningEn: "O Allah, send blessings upon our Master Muhammad.",
      meaningDe: "O Allah, segne unseren Meister Muhammad.",
      meaningAr: "اللهم صل وسلم وبارك على سيدنا محمد.",
    ),
  ];

  late ZikirItem selectedZikir = zikirList.first;

  @override
  void initState() {
    super.initState();
    AppTranslations.currentLocaleNotifier.addListener(_onLocaleChanged);
    _loadCounterData();
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppTranslations.currentLocaleNotifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

  Future<void> _loadCounterData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      count.value = prefs.getInt("count") ?? 0;
      tourCount.value = prefs.getInt("tourCount") ?? 0;
      isVibrationEnabled = prefs.getBool("vibration") ?? true;
    });
  }

  Future<void> _saveCounterData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("count", count.value);
    await prefs.setInt("tourCount", tourCount.value);
    await prefs.setBool("vibration", isVibrationEnabled);
  }

  void _incrementCounter() {
    setState(() {
      count.value++;
      if (targetLimit > 0 && count.value % targetLimit == 0) {
        tourCount.value++;
        _triggerVibration(isLong: true);
      } else {
        _triggerVibration(isLong: false);
      }
    });
    _saveCounterData();
  }

  void _triggerVibration({bool isLong = false}) async {
    if (!isVibrationEnabled) return;
    try {
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        if (isLong) {
          Vibration.vibrate(duration: 400);
        } else {
          Vibration.vibrate(duration: 40);
        }
      }
    } catch (_) {}
  }

  void _resetCounter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.goldAccent, width: 1.5),
        ),
        title: Text(
          AppTranslations.translate('reset_dhikr_title', fallback: "Zikri Sıfırla"),
          style: const TextStyle(color: Color(0xFF1B1B1B), fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppTranslations.translate('reset_dhikr_desc', fallback: "Zikir sayacını sıfırlamak istediğinize emin misiniz?"),
          style: const TextStyle(color: Color(0xFF2C2C2C)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppTranslations.translate('cancel', fallback: "İptal"),
              style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              setState(() {
                count.value = 0;
                tourCount.value = 0;
              });
              _saveCounterData();
              Navigator.pop(context);
            },
            child: Text(AppTranslations.translate('reset', fallback: "Sıfırla")),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langCode = AppTranslations.currentLanguageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.translate('dhikr', fallback: "Zikirmatik")),
        actions: [
          IconButton(
            icon: Icon(
              isVibrationEnabled ? Icons.vibration_rounded : Icons.phone_android_rounded,
              color: isVibrationEnabled ? AppTheme.goldAccent : Colors.white38,
            ),
            tooltip: AppTranslations.translate('vibration', fallback: 'Titreşim'),
            onPressed: () {
              setState(() {
                isVibrationEnabled = !isVibrationEnabled;
              });
              _saveCounterData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded, color: AppTheme.goldAccent),
            tooltip: AppTranslations.translate('reset', fallback: 'Sıfırla'),
            onPressed: _resetCounter,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Zikir Selector Dropdown Card
              _buildZikirSelectorCard(langCode),
              const SizedBox(height: 20),

              // Target Limit Selector (33 / 99 / 100 / Sınırsız)
              _buildTargetSelectorRow(langCode),
              const SizedBox(height: 20),

              // Tour & Total Stats Card
              _buildStatsDisplay(langCode),
              const Spacer(),

              // Interactive Tasbeeh Counter Button
              _buildMainCounterButton(langCode),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZikirSelectorCard(String langCode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppTheme.cardDecoration(color: AppTheme.surfaceDark),
      child: Column(
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton<ZikirItem>(
              value: selectedZikir,
              isExpanded: true,
              dropdownColor: AppTheme.surfaceDark,
              icon: const Icon(Icons.arrow_drop_down_circle_rounded, color: AppTheme.goldAccent),
              items: zikirList.map((item) {
                return DropdownMenuItem<ZikirItem>(
                  value: item,
                  child: Text(
                    item.getTitle(langCode),
                    style: const TextStyle(
                      color: AppTheme.primaryEmerald,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newItem) {
                if (newItem != null) {
                  setState(() {
                    selectedZikir = newItem;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            selectedZikir.arabic,
            style: const TextStyle(
              color: AppTheme.primaryEmerald,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            selectedZikir.getMeaning(langCode),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondaryDark,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSelectorRow(String langCode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [33, 99, 100, 0].map((limit) {
        final isSelected = targetLimit == limit;
        final label = limit == 0
            ? AppTranslations.translate('unlimited', fallback: "Sınırsız")
            : "$limit";
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ChoiceChip(
            label: Text(label),
            selected: isSelected,
            selectedColor: AppTheme.primaryEmerald,
            backgroundColor: AppTheme.surfaceDark,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textPrimaryDark,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  targetLimit = limit;
                });
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsDisplay(String langCode) {
    String tourLabel;
    if (langCode == 'de') {
      tourLabel = targetLimit > 0 ? "Runde (${targetLimit}er)" : "Runde";
    } else if (langCode == 'en') {
      tourLabel = targetLimit > 0 ? "Round ($targetLimit)" : "Round";
    } else if (langCode == 'ar') {
      tourLabel = targetLimit > 0 ? "جولة ($targetLimit)" : "جولة";
    } else {
      tourLabel = targetLimit > 0 ? "Tur ($targetLimit'lük)" : "Tur";
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: AppTheme.cardDecoration(color: AppTheme.surfaceDark),
            child: Column(
              children: [
                Text(tourLabel, style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12)),
                const SizedBox(height: 4),
                Obx(() => Text(
                      "${tourCount.value}",
                      style: const TextStyle(color: AppTheme.primaryEmerald, fontSize: 22, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: AppTheme.cardDecoration(color: AppTheme.surfaceDark),
            child: Column(
              children: [
                Text(
                  AppTranslations.translate('total_dhikr', fallback: "Toplam Zikir"),
                  style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                      "${count.value}",
                      style: const TextStyle(color: AppTheme.textPrimaryDark, fontSize: 22, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainCounterButton(String langCode) {
    return GestureDetector(
      onTap: _incrementCounter,
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppTheme.primaryEmerald, AppTheme.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppTheme.goldAccent, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryEmerald.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => Text(
                    "${count.value}",
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  )),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.goldAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppTranslations.translate('tap', fallback: "DOKUN"),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
