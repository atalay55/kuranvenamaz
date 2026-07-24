import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/pages/selectablepage/countryselect.dart';
import 'package:kuranvenamaz/theme/app_theme.dart';
import '../../core/utilities.dart';
import '../../core/widget_service.dart';
import '../../entity/namazvakitleri.dart';
import '../../theme/namazvakitlericard.dart';

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: AppTheme.goldAccent, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    "$cityName, $countryName",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
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
                    border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.edit_location_alt_rounded, color: AppTheme.goldAccent, size: 14),
                      SizedBox(width: 4),
                      Text(
                        "Değiştir",
                        style: TextStyle(color: AppTheme.goldAccent, fontSize: 12),
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
            "$sonrakiVakitIsmi Vaktine Kalan Süre",
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
              _buildTimeUnit(displaySaat, "Saat"),
              const Text(" : ", style: TextStyle(color: AppTheme.goldAccent, fontSize: 26, fontWeight: FontWeight.bold)),
              _buildTimeUnit(displayDakika, "Dakika"),
              const Text(" : ", style: TextStyle(color: AppTheme.goldAccent, fontSize: 26, fontWeight: FontWeight.bold)),
              _buildTimeUnit(displaySaniye, "Saniye"),
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
                              child: NamazVakitleriKucuk(
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
                      label: const Text("Yeniden Dene"),
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
                    const Text('Namaz vakitleri alınamadı.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _loadData();
                        });
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text("Yeniden Dene"),
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
            border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
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
}
