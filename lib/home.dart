import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/theme/namazvakitlericard.dart';
import 'package:kuranvenamaz/zikirmatik.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'core/utilities.dart';
import 'entity/namazvakitleri.dart';

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
    // Diğer DrawerEntity örnekleri burada...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.green,
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
      body:  SaatDilimiHesaplama(),


      /*SingleChildScrollView(
        child: Column(
          children: [
            NamazVakitleriCard(),
          ],
        ),
      ),*/
    );
  }
}

class SaatDilimiHesaplama extends StatefulWidget {
  @override
  _SaatDilimiHesaplamaState createState() => _SaatDilimiHesaplamaState();
}

class _SaatDilimiHesaplamaState extends State<SaatDilimiHesaplama> {
  var saatler ;
  Duration kalanSure = Duration();
  late final SharedPreferences prefs;
  late String cityName = "";
  late String countryName = "";
  late Future<List<NamazVakitleri>> namazVakitleriFuture; // Namaz vakitleri için gelecek veri


  Future<void> getShered() async {
    prefs = await SharedPreferences.getInstance();
    countryName = prefs.getString("country")??"";
    cityName = prefs.getString("city")??"";
  }
  @override
  void initState() {
    super.initState();
    namazVakitleriFuture = Utilities().getNamazVakitleri() ;// Future'ı başlat
    getShered();
    Timer.periodic(Duration(seconds: 1), (timer) {
      namazVakitleriFuture.then((value) =>   kalanZamanHesapla(value));
      setState(() {});
    });
  }
  void kalanZamanHesapla(List<NamazVakitleri> saatler) {
    final suankiZaman = DateTime.now();
    final suankiSaat = suankiZaman.hour * 3600 +
        suankiZaman.minute * 60 +
        suankiZaman.second;
    double enKucukFark = double.infinity;
    String enKucukSaat = "";
    for (final saat in saatler) {
      final saatDegerleri = saat.namazSaati.split(':').map((e) => int.parse(e)).toList();
      final saatSaat = saatDegerleri[0] * 3600 +
          saatDegerleri[1] * 60;

      final fark = saatSaat - suankiSaat;

      if (fark >= 0 && fark < enKucukFark) {
        enKucukFark = fark.toDouble();
        enKucukSaat = saat.namazSaati;
      }
    }

    if (enKucukSaat.isNotEmpty) {
      final saatDegerleri = enKucukSaat.split(':').map((e) => int.parse(e)).toList();
      final saatSaat = saatDegerleri[0] * 3600 +
          saatDegerleri[1] * 60;
      kalanSure = Duration(seconds: (saatSaat - suankiSaat).toInt());
    } else {
      kalanSure = Duration();
    }
  }
  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;
    final saat = kalanSure.inHours;
    final dakika = (kalanSure.inMinutes % 60);
    final saniye = (kalanSure.inSeconds % 60);

    return Container(
      height: height/3,
      width: width,
      decoration: BoxDecoration(
          border: Border.all(width: 1),borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
              onPressed: null, child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: [Text(countryName+"/"+cityName), Icon(Icons.map)],// bayrak getirmek ?
          )),
          Text(
            " $saat : $dakika : $saniye :",
            style: TextStyle(fontSize: 24),
          ),
          FutureBuilder<List<NamazVakitleri>>(
            future: namazVakitleriFuture, // Future kullanımı burada
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Hata: ${snapshot.error}');
              } else if (snapshot.hasData) {
                List<NamazVakitleri> namazVakitleriList = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (int index = 0;
                      index < namazVakitleriList.length;
                      index++)
                        NamazVakitleriKucuk(namazVakitleriList[index]),
                    ],
                  ),
                );
              } else {
                return Text('Veri bulunamadı');
              }
            },
          )

        ],
      ),
    );
  }
}




class DrawerEntity {
  String name;
  Icon icon;
  Widget whereItGo;
  DrawerEntity(
      {required this.name, required this.icon, required this.whereItGo});
}