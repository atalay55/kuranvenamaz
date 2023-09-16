import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/core/notificationservice.dart';
import 'package:kuranvenamaz/hijricalendar/hijricalendar.dart';
import 'package:kuranvenamaz/pages/selectablepage/countryselect.dart';
import 'package:kuranvenamaz/pages/zikirmatik_pages/zikirmatik.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'pages/home.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  NotificationService().initNotification();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstRun = prefs.getBool('isFirstRun') ?? false;
  runApp(MyApp(isFirstRun));
}

class MyApp extends StatelessWidget {
  MyApp(this.isFirstRun);
  final bool isFirstRun;

  @override
  Widget build(BuildContext context) {

   return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quran and Namaz',
       localizationsDelegates: [
         GlobalMaterialLocalizations.delegate,
         GlobalWidgetsLocalizations.delegate,
         GlobalCupertinoLocalizations.delegate,
       ],
       supportedLocales: [
         Locale('en'),
         Locale('tr'),
       ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isFirstRun?HomePage(): CountrySelectPage(),
    );
  }
}


