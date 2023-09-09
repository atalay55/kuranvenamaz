import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/pages/selectablepage/cityselect.dart';
import '../../core/httpcontroller.dart';
import '../../entity/country.dart';

class CountrySelectPage extends StatefulWidget {
  const CountrySelectPage({Key? key}) : super(key: key);

  @override
  State<CountrySelectPage> createState() => _CountrySelectPageState();
}

class _CountrySelectPageState extends State<CountrySelectPage> {

  late Future<List<Country>> countries;  // Future nesnesini tanımla
  @override
  void initState() {
    super.initState();
    countries = HttpController().fetchCountryJSONData();
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: FutureBuilder<List<Country>>(
        future: countries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Veri beklenirken yükleniyor göster
          } else if (snapshot.hasError) {
            print("${snapshot.error}");
            return Text('Hata: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('Veri bulunamadı.');
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: (){
                    Get.to(CitySelectPage(snapshot.data![index].name));

                  },
                  child: ListTile(
                    title: Text(snapshot.data![index].name),
                    subtitle: Text(snapshot.data![index].code),
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
