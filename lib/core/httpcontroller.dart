import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kuranvenamaz/entity/location.dart';

import '../entity/city.dart';
import '../entity/country.dart';

class HttpController{


// Country nesnelerini saklamak için liste

  // JSON veriyi almak ve Country nesnelerine dönüştürmek için asenkron bir fonksiyon
  Future<List<Country>> fetchCountryJSONData() async {
    List<Country> countries = [];
    final response = await http.get(Uri.parse('https://namaz-vakti.vercel.app/api/countries'));  // API URL'sini güncelleyin
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      countries = jsonData.map((data) => Country(code: data['code'], name: data['name'])).toList();
      return countries;
    } else {
      throw Exception('Veri alınamadı.');
    }
  }



  Future<List<City>> fetchCities( String country) async {
    final response = await http.get(Uri.parse('https://namaz-vakti.vercel.app/api/regions?country=$country'));  // API URL'sini güncelleyin

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      final List<String> cityNames = List<String>.from(jsonData);
      List<City> cities = cityNames.map((name) => City(name)).toList();
      return cities;
    } else {
      throw Exception('Veri alınamadı.');
    }
  }

  Future<Times> fetchPrayerTimesData(String country ,String city) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    final response = await http.get(Uri.parse('https://namaz-vakti.vercel.app/api/timesFromPlace?country=$country&region=$city&city=$city&date=$formattedDate&days=7&timezoneOffset=180&calculationMethod=$country'));  // API URL'sini güncelleyin

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final Map<String, dynamic> timesData = jsonData['times'];

      final Map<String, List<String>> parsedTimes = timesData.map((key, value) {
        return MapEntry(key, List<String>.from(value));
      });

      final Times times = Times(timesByDate: parsedTimes);
      return times;
    } else {
      throw Exception('Veri alınamadı.');
    }
  }

}