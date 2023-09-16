import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/pages/home.dart';
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
  late TextEditingController controller;
  List<City> _filteredCities = [];
  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    cities = HttpController().fetchCities(widget.country);
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  void _updateIsFirstRun() async {
    final SharedPreferences prefs=await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', true);
  }

  Future<void> setInformation(String city, String country) async{
    final SharedPreferences prefs=await SharedPreferences.getInstance();
    await prefs.setString('city', city);
    await prefs.setString('country', country);

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sehir Seç'),
        backgroundColor: Colors.black54,
      ),
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
            final cityList = snapshot.data!;
            return
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Şehir ara...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onChanged: (String query) {
                        final suggestions = cityList.where((city) {
                          final countryName = city.cityName.toLowerCase();
                          final input = query.toLowerCase();
                          return countryName.contains(input);
                        }).toList();
                        setState(() {
                          _filteredCities = suggestions;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredCities.isEmpty ? cityList.length : _filteredCities.length,
                      itemBuilder: (context, index) {
                        final country = _filteredCities.isEmpty ?cityList[index]: _filteredCities[index];
                        return GestureDetector(

                          onTap: () async{

                            _updateIsFirstRun();
                            await setInformation(snapshot.data![index].cityName,widget.country);
                            Get.to(HomePage());
                            setState(() {

                            });
                          },
                          child: ListTile(
                            title: Text(country.cityName),
                          ),
                        );
                      },
                    ),
                  )
                ],
              );

          }
        },
      ),
    );
  }
}
