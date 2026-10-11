import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:kuranvenamaz/core/app_translations.dart';
import 'package:kuranvenamaz/theme/app_theme.dart';

class DiniGunItem {
  final String titleTr;
  final String titleEn;
  final String titleDe;
  final String titleAr;
  final String hijriTr;
  final String hijriEn;
  final String hijriDe;
  final String hijriAr;
  final DateTime date;

  const DiniGunItem({
    required this.titleTr,
    required this.titleEn,
    required this.titleDe,
    required this.titleAr,
    required this.hijriTr,
    required this.hijriEn,
    required this.hijriDe,
    required this.hijriAr,
    required this.date,
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

  String getHijriDate(String lang) {
    switch (lang) {
      case 'de':
        return hijriDe;
      case 'en':
        return hijriEn;
      case 'ar':
        return hijriAr;
      default:
        return hijriTr;
    }
  }

  String getGregorianDate(String lang) {
    final localeMap = {
      'tr': 'tr_TR',
      'de': 'de_DE',
      'en': 'en_US',
      'ar': 'ar_SA',
    };
    final loc = localeMap[lang] ?? 'tr_TR';
    return DateFormat('d MMMM yyyy', loc).format(date);
  }
}

class HijriCalendarWidget extends StatefulWidget {
  const HijriCalendarWidget({Key? key}) : super(key: key);

  @override
  State<HijriCalendarWidget> createState() => _HijriCalendarWidgetState();
}

class _HijriCalendarWidgetState extends State<HijriCalendarWidget> {
  DateTime selectedDate = DateTime.now();
  var _hijriFormat = HijriCalendar.now();

  final List<DiniGunItem> diniGunler = [
    DiniGunItem(
      titleTr: "Ramazan-ı Şerif Başı",
      titleEn: "Beginning of Ramadan",
      titleDe: "Beginn des Ramadan",
      titleAr: "بداية شهر رمضان المبارك",
      hijriTr: "1 Ramazan 1446",
      hijriEn: "1 Ramadan 1446",
      hijriDe: "1. Ramadan 1446",
      hijriAr: "1 رمضان 1446",
      date: DateTime(2025, 3, 1),
    ),
    DiniGunItem(
      titleTr: "Kadir Gecesi",
      titleEn: "Laylat al-Qadr (Night of Power)",
      titleDe: "Lailat al-Qadr (Nacht der Bestimmung)",
      titleAr: "ليلة القدر المباركة",
      hijriTr: "26 Ramazan 1446",
      hijriEn: "26 Ramadan 1446",
      hijriDe: "26. Ramadan 1446",
      hijriAr: "26 رمضان 1446",
      date: DateTime(2025, 3, 26),
    ),
    DiniGunItem(
      titleTr: "Ramazan Bayramı 1. Gün",
      titleEn: "Eid al-Fitr (Day 1)",
      titleDe: "Eid al-Fitr (Fastenbrechenfest, Tag 1)",
      titleAr: "عيد الفطر المبارك (اليوم الأول)",
      hijriTr: "1 Şevval 1446",
      hijriEn: "1 Shawwal 1446",
      hijriDe: "1. Schawwal 1446",
      hijriAr: "1 شوال 1446",
      date: DateTime(2025, 3, 30),
    ),
    DiniGunItem(
      titleTr: "Arafat Günü (Arife)",
      titleEn: "Day of Arafah",
      titleDe: "Tag von Arafah",
      titleAr: "يوم عرفة",
      hijriTr: "9 Zilhicce 1446",
      hijriEn: "9 Dhu al-Hijjah 1446",
      hijriDe: "9. Dhu l-hiddscha 1446",
      hijriAr: "9 ذو الحجة 1446",
      date: DateTime(2025, 6, 5),
    ),
    DiniGunItem(
      titleTr: "Kurban Bayramı 1. Gün",
      titleEn: "Eid al-Adha (Day 1)",
      titleDe: "Eid al-Adha (Opferfest, Tag 1)",
      titleAr: "عيد الأضحى المبارك (اليom الأول)",
      hijriTr: "10 Zilhicce 1446",
      hijriEn: "10 Dhu al-Hijjah 1446",
      hijriDe: "10. Dhu l-hiddscha 1446",
      hijriAr: "10 ذو الحجة 1446",
      date: DateTime(2025, 6, 6),
    ),
    DiniGunItem(
      titleTr: "Hicri Yılbaşı (1447)",
      titleEn: "Islamic New Year (1447)",
      titleDe: "Islamisches Neujahr (1447)",
      titleAr: "رأس السنة الهجرية (1447)",
      hijriTr: "1 Muharrem 1447",
      hijriEn: "1 Muharram 1447",
      hijriDe: "1. Muharram 1447",
      hijriAr: "1 محرم 1447",
      date: DateTime(2025, 6, 26),
    ),
    DiniGunItem(
      titleTr: "Aşure Günü",
      titleEn: "Day of Ashura",
      titleDe: "Aschura-Tag",
      titleAr: "يوم عاشوراء",
      hijriTr: "10 Muharrem 1447",
      hijriEn: "10 Muharram 1447",
      hijriDe: "10. Muharram 1447",
      hijriAr: "10 محرم 1447",
      date: DateTime(2025, 7, 5),
    ),
    DiniGunItem(
      titleTr: "Mevlid Kandili",
      titleEn: "Mawlid al-Nabi (Prophet's Birthday)",
      titleDe: "Mawlid an-Nabi (Geburtstag des Propheten)",
      titleAr: "المولد النبوي الشريف",
      hijriTr: "12 Rebiülevvel 1447",
      hijriEn: "12 Rabi' al-Awwal 1447",
      hijriDe: "12. Rabi' al-awwal 1447",
      hijriAr: "12 ربيع الأول 1447",
      date: DateTime(2025, 9, 4),
    ),
  ];

  @override
  void initState() {
    super.initState();
    AppTranslations.currentLocaleNotifier.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppTranslations.currentLocaleNotifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

  String _formatHijriDate(HijriCalendar hijri, String lang) {
    const monthsTr = [
      'Muharrem', 'Sefer', 'Rebiülevvel', 'Rebiülahir',
      'Cemaziyelevvel', 'Cemaziyelahir', 'Recep', 'Şaban',
      'Ramazan', 'Şevval', 'Zilkade', 'Zilhicce'
    ];
    const monthsEn = [
      'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Thani",
      "Jumada al-Awwal", "Jumada al-Thani", 'Rajab', "Sha'ban",
      'Ramadan', 'Shawwal', "Dhu al-Qi'dah", 'Dhu al-Hijjah'
    ];
    const monthsDe = [
      'Muharram', 'Safar', "Rabi' al-awwal", "Rabi' al-thani",
      'Dschumada l-ula', 'Dschumada th-thaniya', 'Radschab', "Scha'ban",
      'Ramadan', 'Schawwal', "Dhu l-qa'da", 'Dhu l-hiddscha'
    ];
    const monthsAr = [
      'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني',
      'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبan',
      'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
    ];

    final monthIndex = (hijri.hMonth - 1).clamp(0, 11);
    switch (lang) {
      case 'de':
        return "${hijri.hDay}. ${monthsDe[monthIndex]} ${hijri.hYear}";
      case 'en':
        return "${hijri.hDay} ${monthsEn[monthIndex]} ${hijri.hYear}";
      case 'ar':
        return "${hijri.hDay} ${monthsAr[monthIndex]} ${hijri.hYear}";
      default:
        return "${hijri.hDay} ${monthsTr[monthIndex]} ${hijri.hYear}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final langCode = AppTranslations.currentLanguageCode;
    final localeMap = {
      'tr': 'tr_TR',
      'de': 'de_DE',
      'en': 'en_US',
      'ar': 'ar_SA',
    };
    final localeStr = localeMap[langCode] ?? 'tr_TR';
    final formatMiladi = DateFormat('dd MMMM yyyy, EEEE', localeStr).format(selectedDate);
    final formattedHijri = _formatHijriDate(_hijriFormat, langCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.translate('hijri_calendar', fallback: "Hicri Takvim")),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dual Calendar Display Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.headerGradientDecoration(
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  const Icon(Icons.calendar_month_rounded,
                      color: AppTheme.goldAccent, size: 36),
                  const SizedBox(height: 10),
                  Text(
                    formattedHijri,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.goldLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatMiladi,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.goldLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Date Picker Card
            Container(
              decoration: AppTheme.cardDecoration(color: AppTheme.surfaceDark),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                    child: Text(
                      AppTranslations.translate('select_date_convert_hijri', fallback: "Tarih Seç ve Hicriye Çevir"),
                      style: const TextStyle(
                          color: AppTheme.goldAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                  SizedBox(
                    height: 150,
                    child: CupertinoTheme(
                      data: const CupertinoThemeData(
                        brightness: Brightness.dark,
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle:
                              TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        dateOrder: DatePickerDateOrder.dmy,
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: selectedDate,
                        onDateTimeChanged: (dateTime) {
                          setState(() {
                            selectedDate = dateTime;
                            _hijriFormat = HijriCalendar.fromDate(selectedDate);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Dini Gün ve Geceler Title
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppTheme.goldAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppTranslations.translate('important_religious_days', fallback: "Önemli Dini Gün ve Geceler"),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // List of Dini Gunler
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: diniGunler.length,
              itemBuilder: (context, index) {
                final item = diniGunler[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: AppTheme.cardDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.getTitle(langCode),
                              style: const TextStyle(
                                color: AppTheme.textPrimaryDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.getHijriDate(langCode),
                              style: const TextStyle(
                                color: AppTheme.primaryEmerald,
                                fontWeight: FontWeight.w500,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryEmerald.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.goldAccent.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          item.getGregorianDate(langCode),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
