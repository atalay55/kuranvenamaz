import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:kuranvenamaz/theme/app_theme.dart';

class DiniGunItem {
  final String title;
  final String hijriDate;
  final String gregorianDate;

  const DiniGunItem({
    required this.title,
    required this.hijriDate,
    required this.gregorianDate,
  });
}

class HijriCalendarWidget extends StatefulWidget {
  const HijriCalendarWidget({Key? key}) : super(key: key);

  @override
  State<HijriCalendarWidget> createState() => _HijriCalendarWidgetState();
}

class _HijriCalendarWidgetState extends State<HijriCalendarWidget> {
  DateTime selectedDate = DateTime.now();
  var _hijriFormat = HijriCalendar.now();

  final List<DiniGunItem> diniGunler = const [
    DiniGunItem(
        title: "Ramazan-ı Şerif Başı",
        hijriDate: "1 Ramazan 1446",
        gregorianDate: "1 Mart 2025"),
    DiniGunItem(
        title: "Kadir Gecesi",
        hijriDate: "26 Ramazan 1446",
        gregorianDate: "26 Mart 2025"),
    DiniGunItem(
        title: "Ramazan Bayramı 1. Gün",
        hijriDate: "1 Şevval 1446",
        gregorianDate: "30 Mart 2025"),
    DiniGunItem(
        title: "Arafat Günü (Arife)",
        hijriDate: "9 Zilhicce 1446",
        gregorianDate: "5 Haziran 2025"),
    DiniGunItem(
        title: "Kurban Bayramı 1. Gün",
        hijriDate: "10 Zilhicce 1446",
        gregorianDate: "6 Haziran 2025"),
    DiniGunItem(
        title: "Hicri Yılbaşı (1447)",
        hijriDate: "1 Muharrem 1447",
        gregorianDate: "26 Haziran 2025"),
    DiniGunItem(
        title: "Aşure Günü",
        hijriDate: "10 Muharrem 1447",
        gregorianDate: "5 Temmuz 2025"),
    DiniGunItem(
        title: "Mevlid Kandili",
        hijriDate: "12 Rebiülevvel 1447",
        gregorianDate: "4 Eylül 2025"),
  ];

  @override
  Widget build(BuildContext context) {
    final formatMiladi =
        DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hicri Takvim"),
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
                    _hijriFormat.toFormat("dd MMMM yyyy"),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                    child: Text(
                      "Tarih Seç ve Hicriye Çevir",
                      style: TextStyle(
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
            const Row(
              children: [
                Icon(Icons.star_rounded, color: AppTheme.goldAccent, size: 20),
                SizedBox(width: 8),
                Text(
                  "Önemli Dini Gün ve Geceler",
                  style: TextStyle(
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
                              item.title,
                              style: const TextStyle(
                                color: AppTheme.textPrimaryDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.hijriDate,
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
                          color: AppTheme.primaryEmerald.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.goldAccent.withOpacity(0.3)),
                        ),
                        child: Text(
                          item.gregorianDate,
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
