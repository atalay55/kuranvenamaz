
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/hijricalendar/hijricalendar.dart';

import 'package:kuranvenamaz/pages/compass_pages/qiblah_screen.dart';
import 'package:kuranvenamaz/pages/prayertime/mainprayerclockwidget.dart';
import 'package:kuranvenamaz/theme/ayetduahadistheme.dart';
import 'package:kuranvenamaz/pages/zikirmatik_pages/zikirmatik.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../entity/DrawerEntity.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Map<String, List<String>> times = {};
  late final SharedPreferences prefs;
  late String formattedDate = "";

  @override
  void initState() {
    super.initState();
  }


  String title = "Namaz ve Kuran";
  List<DrawerEntity> listName = [
    DrawerEntity(
      name: "Ana Ekran",
      icon: const Icon(
        Icons.home,
        color: Colors.white,
      ),
      whereItGo: const HomePage(),
    ),
    DrawerEntity(
      name: "ZikirMatik",
      icon: const Icon(
        Icons.countertops_outlined,
        color: Colors.white,
      ),
      whereItGo: const Zikirmatik(),
    ),
    DrawerEntity(
      name: "Pusula",
      icon: const Icon(
        Icons.compass_calibration,
        color: Colors.white,
      ),
      whereItGo:  QiblahCompass(),
    ),
    DrawerEntity(
      name: "Hicri Takvim",
      icon: const Icon(
        Icons.calendar_month_rounded,
        color: Colors.white,
      ),
      whereItGo:  HijriCalendarWidget(),
    ),

    // Diğer DrawerEntity örnekleri burada...
  ];
// Colors.grey.shade900,
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.black54,
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        width: Get.width / 2,
        child: ListView.builder(
          itemCount: listName.length,
          padding: EdgeInsets.only(top: 50),
          itemBuilder: (context, index) {
            return ListTile(
              leading: listName[index].icon,
              title: Text(
                listName[index].name,
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() {
                  Get.to(listName[index].whereItGo);
                });
              },
            );
          },
        ),
      ),
      body:  Padding(
        padding: const EdgeInsets.all(8.0),
        child:Column(
          children: [
            MainPrayerClockWidget(),
            AyetDuaHadisTheme(title: "Ayet",description: "sdasdasdasdsad",),
            AyetDuaHadisTheme(title: "Hadis",description: "sdasdasdasdsad",),
            AyetDuaHadisTheme(title: "Dua",description: "sdasdasdasdsad",),

          ],
        )
      ),

    );
  }
}


