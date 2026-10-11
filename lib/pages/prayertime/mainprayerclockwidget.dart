import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/pages/selectablepage/countryselect.dart';
import 'package:kuranvenamaz/theme/app_theme.dart';
import '../../core/utilities.dart';
import '../../core/widget_service.dart';
import '../../entity/namazvakitleri.dart';
import '../../theme/namazvakitlericard.dart';
import '../../core/app_translations.dart';

class MainPrayerClockWidget extends StatefulWidget {
  const MainPrayerClockWidget({Key? key}) : super(key: key);

  @override
  State<MainPrayerClockWidget> createState() => _MainPrayerClockWidgetState();
}

class _MainPrayerClockWidgetState extends State<MainPrayerClockWidget> {
  Duration kalanSure = Duration.zero;
  String cityName = "Istanbul";
  String countryName = "Turkey";
  String sonrakiVakitIsmi = "Vakit";
  late Future<List<NamazVakitleri>> namazVakitleriFuture;
  List<NamazVakitleri> _cachedVakitler = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    namazVakitleriFuture = PrayerUtilities().getNamazVakitleri();

    PrayerUtilities().getCityAndCountry().then((value) {
      if (mounted) {
        setState(() {
          cityName = value[0].isEmpty ? "Istanbul" : value[0];
          countryName = value[1].isEmpty ? "Turkey" : value[1];
        });
      }
    });

    namazVakitleriFuture.then((vakitler) {
      if (mounted) {
        setState(() {
          _cachedVakitler = vakitler;
          _updateTimer(forceWidgetUpdate: true);
        });
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _cachedVakitler.isNotEmpty) {
        setState(() {
          _updateTimer();
        });
      }
    });
  }

  void _updateTimer({bool forceWidgetUpdate = false}) {
    kalanSure = PrayerUtilities().kalanZamanHesapla(_cachedVakitler, kalanSure);
    sonrakiVakitIsmi = _getSonrakiVakitIsmi(_cachedVakitler);

    // Her saniye widget güncellemek yerine dakikada bir veya ilk yüklemede güncelle
    if (forceWidgetUpdate || kalanSure.inSeconds % 60 == 0) {
      WidgetService.updateWidgetData(
        cityName: cityName,
        countryName: countryName,
        vakitler: _cachedVakitler,
        sonrakiVakitIsmi: sonrakiVakitIsmi,
        kalanSure: kalanSure,
      );
    }
  }

  String _getSonrakiVakitIsmi(List<NamazVakitleri> vakitler) {
    if (vakitler.isEmpty) return "Vakit";
    final now = DateTime.now();
    final currentSeconds = now.hour * 3600 + now.minute * 60 + now.second;

    for (var vakit in vakitler) {
      final parts = vakit.namazSaati.split(':').map((e) => int.tryParse(e) ?? 0).toList();
      if (parts.length < 2) continue;
      final vakitSeconds = parts[0] * 3600 + parts[1] * 60;
      if (vakitSeconds > currentSeconds) {
        return vakit.vakitIsmi;
      }
    }
    return vakitler.first.vakitIsmi; // If all passed today, next is tomorrow's first
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saat = kalanSure.inHours;
    final dakika = (kalanSure.inMinutes % 60);
    final saniye = (kalanSure.inSeconds % 60);

    final String displaySaat = saat.toString().padLeft(2, '0');
    final String displayDakika = dakika.toString().padLeft(2, '0');
    final String displaySaniye = saniye.toString().padLeft(2, '0');

    return Container(
      width: double.infinity,
      decoration: AppTheme.headerGradientDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Row(
            children: [
              // 1. Sol: Konum Bilgisi (Asla taşmaz, çift Expanded + ellipsis korumalı)
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppTheme.goldAccent, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "$cityName, ${AppTranslations.getLocalizedCountryName(countryName)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // 2. Dil Seçici Butonu (🌐 TR / EN / DE / AR)
              InkWell(
                onTap: () => _showLanguageBottomSheet(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language_rounded, color: AppTheme.goldAccent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        (Get.locale?.languageCode ?? 'tr').toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.goldAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // 3. Konum Değiştir Butonu
              InkWell(
                onTap: () {
                  Get.to(const CountrySelectPage())?.then((_) => _loadData());
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit_location_alt_rounded, color: AppTheme.goldAccent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'change'.tr,
                        style: const TextStyle(color: AppTheme.goldAccent, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Countdown Display Banner
          Text(
            'remaining_to'.trParams({
              'vakit': AppTranslations.getLocalizedPrayerName(sonrakiVakitIsmi),
            }),
            style: const TextStyle(
              color: AppTheme.goldLight,
              fontSize: 13,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeUnit(displaySaat, 'hours'.tr),
              const Text(" : ", style: TextStyle(color: AppTheme.goldAccent, fontSize: 26, fontWeight: FontWeight.bold)),
              _buildTimeUnit(displayDakika, 'minutes'.tr),
              const Text(" : ", style: TextStyle(color: AppTheme.goldAccent, fontSize: 26, fontWeight: FontWeight.bold)),
              _buildTimeUnit(displaySaniye, 'seconds'.tr),
            ],
          ),
          const SizedBox(height: 18),

          // Prayer Times Grid / Chips
          FutureBuilder<List<NamazVakitleri>>(
            future: namazVakitleriFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && _cachedVakitler.isEmpty) {
                return const SizedBox(
                  height: 60,
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.goldAccent),
                  ),
                );
              }

              final List<NamazVakitleri> namazVakitleriList =
                  (snapshot.hasData && snapshot.data!.isNotEmpty)
                      ? snapshot.data!
                      : _cachedVakitler;

              if (namazVakitleriList.isNotEmpty) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int index = 0; index < namazVakitleriList.length; index++)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2.0),
                              child: namazVakitleriKucuk(
                                namazVakitleriList[index],
                                isNextVakit: namazVakitleriList[index].vakitIsmi == sonrakiVakitIsmi,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Column(
                  children: [
                    Text('Hata: ${snapshot.error}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _loadData();
                        });
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: Text('retry'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryEmerald,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Text('failed_prayer_times'.tr, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _loadData();
                        });
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: Text('retry'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryEmerald,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String unit) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          unit,
          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondaryDark),
        ),
      ],
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final currentCode = Get.locale?.languageCode ?? 'tr';
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.textSecondaryDark.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.language_rounded, color: AppTheme.primaryEmerald, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'select_language'.tr,
                      style: const TextStyle(
                        color: AppTheme.primaryEmerald,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...AppTranslations.supportedLanguages.map((lang) {
                  final isSelected = lang['code'] == currentCode;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.goldAccent
                              : AppTheme.goldAccent.withValues(alpha: 0.2),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      tileColor: isSelected
                          ? AppTheme.goldAccent.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.03),
                      leading: Text(lang['flag']!, style: const TextStyle(fontSize: 26)),
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
          ),
        );
      },
    );
  }
}
