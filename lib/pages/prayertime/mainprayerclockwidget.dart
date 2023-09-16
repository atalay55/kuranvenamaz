import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/pages/selectablepage/countryselect.dart';
import '../../core/utilities.dart';
import '../../entity/namazvakitleri.dart';
import '../../theme/namazvakitlericard.dart';

class MainPrayerClockWidget extends StatefulWidget {
  const MainPrayerClockWidget({Key? key}) : super(key: key);

  @override
  State<MainPrayerClockWidget> createState() => _MainPrayerClockWidgetState();
}

class _MainPrayerClockWidgetState extends State<MainPrayerClockWidget> {
  Duration kalanSure = Duration(seconds: 50);
  late String cityName = "";
  late String countryName = "";
  late Future<List<NamazVakitleri>>
      namazVakitleriFuture; // Namaz vakitleri için gelecek veri

  @override
  void initState() {
    namazVakitleriFuture =
        PrayerUtilities().getNamazVakitleri(); // Future'ı başlat
    PrayerUtilities().getCityAndCountry().then((value) {
      cityName = value[0];
      countryName = value[1];
    });
    Timer.periodic(Duration(seconds: 1), (timer) {
      namazVakitleriFuture.then((value) =>
          kalanSure = PrayerUtilities().kalanZamanHesapla(value, kalanSure));
      setState(() {

      });
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final saat = kalanSure.inHours;
    final dakika = (kalanSure.inMinutes % 60);
    final saniye = (kalanSure.inSeconds % 60);

    return Container(
      height: Utilities().height / 3,
      width: Utilities().width,
      decoration: BoxDecoration(
          border: Border.all(width: 1),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey)),
                onPressed: (){
                  Get.to(CountrySelectPage());
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(countryName + "/" + cityName),
                    Icon(Icons.map)
                  ], // bayrak getirmek ?
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              " $saat : $dakika : $saniye ",
              style: TextStyle(fontSize: 40),
            ),
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
                  padding: EdgeInsets.symmetric(vertical: 25, horizontal: 25),
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
