import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/pages/selectablepage/cityselect.dart';
import 'package:kuranvenamaz/theme/app_theme.dart';
import '../../core/httpcontroller.dart';
import '../../entity/country.dart';

class CountrySelectPage extends StatefulWidget {
  const CountrySelectPage({Key? key}) : super(key: key);

  @override
  State<CountrySelectPage> createState() => _CountrySelectPageState();
}

class _CountrySelectPageState extends State<CountrySelectPage> {
  late Future<List<Country>> countries;
  late TextEditingController controller;
  List<Country> _filteredCountries = [];
  List<Country> _allCountries = [];

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
        title: const Text('Ülke Seç'),
      ),
      body: FutureBuilder<List<Country>>(
        future: countries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.goldAccent),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Hata: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white70)),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Ülke verisi bulunamadı.',
                  style: TextStyle(color: Colors.white70)),
            );
          } else {
            _allCountries = snapshot.data!;

            final displayList =
                _filteredCountries.isEmpty && controller.text.isEmpty
                    ? _allCountries
                    : _filteredCountries;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.search, color: AppTheme.goldAccent),
                      hintText: 'Ülke ara...',
                      hintStyle:
                          const TextStyle(color: AppTheme.textSecondaryDark),
                      filled: true,
                      fillColor: AppTheme.surfaceDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                            color: AppTheme.goldAccent.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                            color: AppTheme.goldAccent.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            const BorderSide(color: AppTheme.goldAccent),
                      ),
                    ),
                    onChanged: (String query) {
                      final suggestions = _allCountries.where((country) {
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final country = displayList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: AppTheme.cardDecoration(
                            color: AppTheme.surfaceDark),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppTheme.primaryEmerald,
                            child: Icon(Icons.flag_rounded,
                                color: AppTheme.goldAccent, size: 20),
                          ),
                          title: Text(
                            country.name,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            country.code,
                            style: const TextStyle(
                                color: AppTheme.textSecondaryDark),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: AppTheme.goldAccent),
                          onTap: () {
                            Get.to(() => CitySelectPage(country.name));
                          },
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
