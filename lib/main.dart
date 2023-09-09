import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/pages/selectablepage/countryselect.dart';
import 'package:kuranvenamaz/zikirmatik.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage() //isFirstRun?HomePage(): CountrySelectPage(),
    );
  }
}


