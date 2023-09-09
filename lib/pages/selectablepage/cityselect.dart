import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/httpcontroller.dart';
import '../../entity/city.dart';

class CitySelectPage extends StatefulWidget {
    String country="";
   CitySelectPage(this.country);

  @override
  State<CitySelectPage> createState() => _CitySelectPageState();
}

class _CitySelectPageState extends State<CitySelectPage> {

  late Future<List<City>> cities;  // Future nesnesini tanımla

  @override
  void initState() {
    super.initState();
    cities = HttpController().fetchCities(widget.country);
    print(cities);
  }
  void _updateIsFirstRun() async {
    final SharedPreferences prefs=await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', true);
  }

  void setInformation(String city, String country) async{
    final SharedPreferences prefs=await SharedPreferences.getInstance();
    print(city);
    print(country);
    await prefs.setString('city', city);
    await prefs.setString('country', country);

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<City>>(
        future: cities,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Veri beklenirken yükleniyor göster
          } else if (snapshot.hasError) {
            print("${snapshot.error}");
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('Veri bulunamadı.');
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return GestureDetector(

                  onTap: () async{
                  _updateIsFirstRun();
                  setInformation(snapshot.data![index].cityName,widget.country);
                  Get.to(HomePage());

                  },
                  child: ListTile(
                    title: Text(snapshot.data![index].cityName),

                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
