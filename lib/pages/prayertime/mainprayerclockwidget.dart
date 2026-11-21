import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kuranvenamaz/core/settings_service.dart';
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
  Map<String, List<String>> _timesByDate = {};
  List<String> _sortedDates = [];
  String _selectedDateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _calculationMethod = SettingsService().calculationMethod;
  Timer? _timer;
  int? _lastUpdatedMinute;

  @override
  void initState() {
    super.initState();
    SettingsService().calculationMethodNotifier.addListener(_onMethodChanged);
    _loadData();
  }

  void _onMethodChanged() {
    if (!mounted) return;
    setState(() {
      _calculationMethod = SettingsService().calculationMethod;
      _loadData();
    });
  }

  void _loadData() {
    final utils = PrayerUtilities();
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    namazVakitleriFuture = utils.getNamazVakitleri();

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
        final allDates = utils.cachedTimesByDate;
        final sorted = allDates.keys.toList()..sort();
        setState(() {
          _cachedVakitler = vakitler;
          _timesByDate = allDates;
          _sortedDates = sorted;
          if (!allDates.containsKey(_selectedDateStr)) {
            _selectedDateStr = allDates.containsKey(todayStr)
                ? todayStr
                : (sorted.isNotEmpty ? sorted.first : todayStr);
          }
          _calculationMethod = SettingsService().calculationMethod;
          _updateTimer(forceWidgetUpdate: true);
        });
      }
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _cachedVakitler.isNotEmpty) {
        setState(() {
          _updateTimer();
        });
      }
    });
  }

  String get _todayStr => DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool get _isViewingToday => _selectedDateStr == _todayStr;

  List<NamazVakitleri> _vakitlerForSelectedDate(List<NamazVakitleri> fallbackToday) {
    final raw = _timesByDate[_selectedDateStr];
    if (raw != null && raw.length >= 6) {
      return PrayerUtilities.buildVakitList(raw);
    }
    return fallbackToday;
  }

  void _stepDay(int delta) {
    if (_sortedDates.isEmpty) return;
    final idx = _sortedDates.indexOf(_selectedDateStr);
    if (idx < 0) return;
    final nextIdx = idx + delta;
    if (nextIdx >= 0 && nextIdx < _sortedDates.length) {
      setState(() {
        _selectedDateStr = _sortedDates[nextIdx];
      });
    }
  }

  String _formatDateLabel(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    final locale = Get.locale?.languageCode ?? 'tr';
    final formatted = DateFormat('d MMM EEE', locale).format(dt);
    return dateStr == _todayStr ? "Bugün • $formatted" : formatted;
  }

  void _updateTimer({bool forceWidgetUpdate = false}) {
    final utils = PrayerUtilities();
    kalanSure = utils.kalanZamanHesapla(_cachedVakitler, kalanSure);
    sonrakiVakitIsmi = utils.getSonrakiVakitIsmi(_cachedVakitler);

    // Her saniye widget güncellemek yerine dakikada bir veya ilk yüklemede güncelle
    final currentMinute = DateTime.now().minute;
    if (forceWidgetUpdate || _lastUpdatedMinute != currentMinute) {
      _lastUpdatedMinute = currentMinute;
      WidgetService.updateWidgetData(
        cityName: cityName,
        countryName: countryName,
        vakitler: _cachedVakitler,
        sonrakiVakitIsmi: sonrakiVakitIsmi,
        kalanSure: kalanSure,
      );
    }
  }

  @override
  void dispose() {
    SettingsService().calculationMethodNotifier.removeListener(_onMethodChanged);
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
          const SizedBox(height: 14),

          // Gün Değiştirici + Aylık İmsakiye Çubuğu
          if (_sortedDates.isNotEmpty) ...[
            _buildDateNavigationBar(context),
            const SizedBox(height: 10),
          ],

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

              final List<NamazVakitleri> todayList =
                  (snapshot.hasData && snapshot.data!.isNotEmpty)
                      ? snapshot.data!
                      : _cachedVakitler;
              final List<NamazVakitleri> namazVakitleriList =
                  _vakitlerForSelectedDate(todayList);

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
                                isNextVakit: _isViewingToday &&
                                    namazVakitleriList[index].vakitIsmi == sonrakiVakitIsmi,
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

  Widget _buildDateNavigationBar(BuildContext context) {
    final idx = _sortedDates.indexOf(_selectedDateStr);
    final canPrev = idx > 0;
    final canNext = idx >= 0 && idx < _sortedDates.length - 1;
    final methodLabel = _calculationMethod == 'fazilet' ? 'Fazilet' : 'Diyanet';

    return Row(
      children: [
        IconButton(
          onPressed: canPrev ? () => _stepDay(-1) : null,
          icon: Icon(
            Icons.chevron_left_rounded,
            color: canPrev ? AppTheme.goldAccent : Colors.white24,
            size: 22,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: 'Önceki Gün',
        ),
        Expanded(
          child: InkWell(
            onTap: () => _showMonthlyCalendarSheet(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_month_rounded,
                      color: AppTheme.goldAccent, size: 15),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _formatDateLabel(_selectedDateStr),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.goldAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      methodLabel,
                      style: const TextStyle(
                        color: AppTheme.goldLight,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: canNext ? () => _stepDay(1) : null,
          icon: Icon(
            Icons.chevron_right_rounded,
            color: canNext ? AppTheme.goldAccent : Colors.white24,
            size: 22,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: 'Sonraki Gün',
        ),
      ],
    );
  }

  void _showMonthlyCalendarSheet(BuildContext context) {
    final locale = Get.locale?.languageCode ?? 'tr';
    final methodLabel = _calculationMethod == 'fazilet'
        ? 'Fazilet (Temkinli)'
        : 'Diyanet İşleri';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.textSecondaryDark.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded,
                          color: AppTheme.primaryEmerald, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$cityName • Aylık İmsakiye",
                              style: const TextStyle(
                                color: AppTheme.primaryEmerald,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Kaynak: $methodLabel",
                              style: const TextStyle(
                                color: AppTheme.textSecondaryDark,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!_isViewingToday)
                        TextButton(
                          onPressed: () {
                            setState(() => _selectedDateStr = _todayStr);
                            Navigator.pop(ctx);
                          },
                          child: const Text(
                            "Bugün",
                            style: TextStyle(
                              color: AppTheme.primaryEmerald,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryEmerald,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text("Tarih",
                              style: TextStyle(
                                  color: AppTheme.goldLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Expanded(child: Text("İms", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                        Expanded(child: Text("Gün", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                        Expanded(child: Text("Öğl", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                        Expanded(child: Text("İkn", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                        Expanded(child: Text("Akş", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                        Expanded(child: Text("Yat", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _sortedDates.length,
                      itemBuilder: (_, i) {
                        final dateStr = _sortedDates[i];
                        final times = _timesByDate[dateStr] ?? const [];
                        if (times.length < 6) return const SizedBox.shrink();
                        final isToday = dateStr == _todayStr;
                        final isSelected = dateStr == _selectedDateStr;
                        final dt = DateTime.tryParse(dateStr);
                        final label = dt != null
                            ? DateFormat('d MMM', locale).format(dt)
                            : dateStr;

                        return InkWell(
                          onTap: () {
                            setState(() => _selectedDateStr = dateStr);
                            Navigator.pop(ctx);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 9),
                            decoration: BoxDecoration(
                              color: isToday
                                  ? AppTheme.primaryEmerald.withValues(alpha: 0.14)
                                  : (isSelected
                                      ? AppTheme.goldAccent.withValues(alpha: 0.18)
                                      : (i.isEven
                                          ? Colors.black.withValues(alpha: 0.025)
                                          : Colors.transparent)),
                              borderRadius: BorderRadius.circular(8),
                              border: isToday
                                  ? Border.all(
                                      color: AppTheme.primaryEmerald, width: 1)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    isToday ? "$label ★" : label,
                                    style: TextStyle(
                                      color: isToday
                                          ? AppTheme.primaryEmerald
                                          : AppTheme.textPrimaryDark,
                                      fontSize: 11,
                                      fontWeight: isToday
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ),
                                for (int c = 0; c < 6; c++)
                                  Expanded(
                                    child: Text(
                                      times[c],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isToday
                                            ? AppTheme.primaryEmerald
                                            : AppTheme.textPrimaryDark,
                                        fontSize: 11,
                                        fontWeight: isToday
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
