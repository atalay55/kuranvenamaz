import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/core/notificationservice.dart';
import 'package:kuranvenamaz/core/utilities.dart';
import 'package:kuranvenamaz/pages/selectablepage/countryselect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kuranvenamaz/theme/app_theme.dart';
import 'package:kuranvenamaz/pages/home.dart';
import 'package:kuranvenamaz/core/app_translations.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  try {
    await NotificationService().initNotification();
    // Namaz vakitlerini ve 7 günlük bildirim zamanlamalarını uygulama açılışında anında yenile
    await PrayerUtilities().initializeData();
  } catch (e, s) {
    debugPrint("Notification init error on startup: $e\n$s");
  }

  bool isFirstRun = false;
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isFirstRun = prefs.getBool('isFirstRun') ?? false;
  } catch (e) {
    debugPrint("SharedPreferences error: $e");
  }

  Locale initialLocale = AppTranslations.defaultLocale;
  try {
    initialLocale = await AppTranslations.loadSavedLocale();
  } catch (_) {}

  runApp(MyApp(isFirstRun, initialLocale));
}

class MyApp extends StatelessWidget {
  const MyApp(this.isFirstRun, this.initialLocale, {super.key});
  final bool isFirstRun;
  final Locale initialLocale;

  @override
  Widget build(BuildContext context) {
    AppTranslations.init();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Namaz ve Kuran',
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: AppTranslations.defaultLocale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('de'),
        Locale('ar'),
      ],
      theme: AppTheme.darkTheme,
      home: isFirstRun ? const HomePage() : const CountrySelectPage(),
    );
  }
}


