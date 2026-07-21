import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/core/notificationservice.dart';
import 'package:kuranvenamaz/pages/selectablepage/countryselect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kuranvenamaz/theme/app_theme.dart';
import 'package:kuranvenamaz/pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  try {
    await NotificationService().initNotification();
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

  runApp(MyApp(isFirstRun));
}

class MyApp extends StatelessWidget {
  MyApp(this.isFirstRun);
  final bool isFirstRun;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Namaz ve Kuran',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
      ],
      theme: AppTheme.darkTheme,
      home: isFirstRun ? const HomePage() : const CountrySelectPage(),
    );
  }
}


