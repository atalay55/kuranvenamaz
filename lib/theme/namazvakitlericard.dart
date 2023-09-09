import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kuranvenamaz/core/utilities.dart';
import 'package:kuranvenamaz/entity/namazvakitleri.dart';
import 'package:shared_preferences/shared_preferences.dart';



class NamazVakitleriCard extends StatefulWidget {


  @override
  State<NamazVakitleriCard> createState() => _NamazVakitleriCardState();
}

class _NamazVakitleriCardState extends State<NamazVakitleriCard> {

  late Timer timer;
  late final SharedPreferences prefs;
  List<NamazVakitleri> namazVakitleri=[];
  String namazSaati="";
  late String cityName ="";
  late String countryName ="";
  late NamazVakitleri currentNamazVakti = NamazVakitleri(namazSaati: "15.0",vakitIsmi: "asdasd");
  @override
  void initState() {
    super.initState();
    initializeData();
    getShered();

   // decideTime();
  }

  initializeData() async {
   Utilities().getNamazVakitleri().then((value) {
   namazVakitleri= value;
   namazSaati=namazVakitleri[0].namazSaati;
   // findLastPastTime(namazVakitleri);
 });
  }
  Future<void> getShered() async {
    prefs = await SharedPreferences.getInstance();
     countryName = prefs.getString("country")??"";
      cityName = prefs.getString("city")??"";
  }
/*
// namaz vakitlerini göstermede sıkıntı var
  NamazVakitleri? findLastPastTime(List<NamazVakitleri> timeList) {
    DateTime now = DateTime.now();
     DateTime dateTime = DateTime.parse(timeList[0].namazSaati);
     String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
     print(dateTime);
  }

*/


  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: height/3,
        width: width,
        decoration: BoxDecoration(
            border: Border.all(width: 1),borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: null, child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: [Text(countryName+"/"+cityName), Icon(Icons.map)],// bayrak getirmek ?
            )),
            Text("${currentNamazVakti.vakitIsmi} vaktine kalan süre"),
            StreamBuilder<int>(
              stream: Stream.periodic(Duration(seconds: 1), (i) => i), // Her saniye artan bir sayı üretir
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  int secondsPassed = snapshot.data!;
                  // Burada sürekli güncellenen widget'ınızı oluşturabilirsiniz
                  return Text(
                    'Geçen Süre: $secondsPassed saniye',
                    style: TextStyle(fontSize: 18),
                  );
                } else {
                  return Text("Veri alınamıyor...");
                }
              },
            ),
            Text("widget.date"),

            FutureBuilder<List<NamazVakitleri>>(
              future: Utilities().getNamazVakitleri(),
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
                      crossAxisAlignment: CrossAxisAlignment.center,// veya ListView
                      children: [
                        for (int index = 0; index < namazVakitleriList.length; index++)
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
      ),
    );
  }
}

Widget NamazVakitleriKucuk(NamazVakitleri namazVakit){
  return Container(
    width:50,
    height: 50,
    decoration: BoxDecoration(
        border: Border.all(width: 1),borderRadius: BorderRadius.circular(10)
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(namazVakit.vakitIsmi),
        Text(namazVakit.namazSaati)
      ],
    ),
  );
}