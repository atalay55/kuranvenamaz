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
  late Future<List<Country>> countries; // Future nesnesini tanımla
  late TextEditingController controller;
  List<Country> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    countries = HttpController().fetchCountryJSONData();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ülke Seç'),
        backgroundColor: Colors.black54,
      ),
      body: FutureBuilder<List<Country>>(
        future: countries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            ); // Veri beklenirken yükleniyor göster
          } else if (snapshot.hasError) {
            print("${snapshot.error}");
            return Center(
              child: Text('Hata: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Veri bulunamadı.'),
            );
          } else {
            final countryList = snapshot.data!;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Ülke ara...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onChanged: (String query) {
                      final suggestions = countryList.where((country) {
                        final countryName = country.name.toLowerCase();
                        final input = query.toLowerCase();
                        return countryName.contains(input);
                      }).toList();
                      setState(() {
                        _filteredCountries = suggestions;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredCountries.isEmpty ? countryList.length : _filteredCountries.length,
                    itemBuilder: (context, index) {
                      final country = _filteredCountries.isEmpty ?countryList[index]: _filteredCountries[index];
                      return GestureDetector(
                        onTap: () {
                          Get.to(CitySelectPage(country.name));
                          print(country.name);
                        },
                        child: ListTile(
                          title: Text(country.name),
                          subtitle: Text(country.code),
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
