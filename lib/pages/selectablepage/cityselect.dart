import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/pages/home.dart';
import 'package:kuranvenamaz/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/httpcontroller.dart';
import '../../entity/city.dart';

class CitySelectPage extends StatefulWidget {
  final String country;
  const CitySelectPage(this.country, {Key? key}) : super(key: key);

  @override
  State<CitySelectPage> createState() => _CitySelectPageState();
}

class _CitySelectPageState extends State<CitySelectPage> {
  late Future<List<City>> cities;
  late TextEditingController controller;
  List<City> _filteredCities = [];
  List<City> _allCities = [];

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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', true);
  }

  Future<void> setInformation(String city, String country) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('city', city);
    await prefs.setString('country', country);
  }

  String _normalize(String s) {
    return s
        .toLowerCase()
        .trim()
        .replaceAll('İ', 'i')
        .replaceAll('I', 'i')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.country} - Şehir Seç'),
      ),
      body: FutureBuilder<List<City>>(
        future: cities,
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
              child: Text('Şehir verisi bulunamadı.',
                  style: TextStyle(color: Colors.white70)),
            );
          } else {
            _allCities = snapshot.data!;
            final queryText = controller.text.trim();
            final displayList =
                _filteredCities.isEmpty && queryText.isEmpty
                    ? _allCities
                    : _filteredCities;

            final hasExactMatch = displayList.any((c) =>
                _normalize(c.cityName) == _normalize(queryText));

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
                      hintText: 'Şehir ara (örn: Berlin, Köln, Frankfurt)...',
                      hintStyle:
                          const TextStyle(color: AppTheme.textSecondaryDark),
                      filled: true,
                      fillColor: AppTheme.surfaceDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                            color: AppTheme.goldAccent.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                            color: AppTheme.goldAccent.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            const BorderSide(color: AppTheme.goldAccent),
                      ),
                    ),
                    onChanged: (String query) {
                      final input = _normalize(query);
                      final suggestions = _allCities.where((city) {
                        return _normalize(city.cityName).contains(input);
                      }).toList();
                      setState(() {
                        _filteredCities = suggestions;
                      });
                    },
                  ),
                ),
                if (queryText.isNotEmpty && !hasExactMatch)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryEmerald.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.goldAccent, width: 1.2),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppTheme.goldAccent,
                          child: Icon(Icons.add_location_alt_rounded,
                              color: Colors.black, size: 20),
                        ),
                        title: Text(
                          "'$queryText' Şehrini Kullan",
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          "Listede bulamadıysanız bu şehri kaydedin",
                          style: TextStyle(
                              color: AppTheme.goldLight,
                              fontSize: 12),
                        ),
                        trailing: const Icon(Icons.check_circle_rounded,
                            color: AppTheme.goldAccent),
                        onTap: () async {
                          _updateIsFirstRun();
                          await setInformation(queryText, widget.country);
                          Get.offAll(() => const HomePage());
                        },
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final city = displayList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: AppTheme.cardDecoration(
                            color: AppTheme.surfaceDark),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppTheme.primaryEmerald,
                            child: Icon(Icons.location_city_rounded,
                                color: AppTheme.goldAccent, size: 20),
                          ),
                          title: Text(
                            city.cityName,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: const Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppTheme.goldAccent),
                          onTap: () async {
                            _updateIsFirstRun();
                            await setInformation(city.cityName, widget.country);
                            Get.offAll(() => const HomePage());
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
