import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kuranvenamaz/core/notificationservice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../entity/namazvakitleri.dart';
import 'httpcontroller.dart';

class Utilities {
  var width = Get.width;
  var height = Get.height;

}
class PrayerUtilities{
  late SharedPreferences prefs;

  String? country;
  String? city;
  Future<List<String>> getCityAndCountry() async {
    prefs = await SharedPreferences.getInstance();
    country = await  prefs.getString("country")??"";
    city = await prefs.getString("city")??"";
    return [city!,country!];
  }


  List<String> namazSaatleri = [];


  Future<void> initializeData() async {
    prefs = await SharedPreferences.getInstance();
    country = await prefs.getString("country");
    city =  await prefs.getString("city");
    late Map<String, List<String>> times;
    await HttpController()
        .fetchPrayerTimesData(country.toString(), city.toString())
        .then((value) {
      times = value.timesByDate;
      namazSaatleri = times[DateFormat('yyyy-MM-dd').format(DateTime.now())] ??
          [];
    });
  }

  Future<List<NamazVakitleri>> getNamazVakitleri() async {
    List<String> namazVakitIsmi = ["imsak","Güneş",  "ögle", "ikindi", "akşam","yatsi"];
    List<NamazVakitleri> namazVakitleri = [];
    await initializeData();

    for (int i = 0; i < namazVakitIsmi.length; i++) {
      namazVakitleri.add(NamazVakitleri(namazSaati: namazSaatleri[i], vakitIsmi: namazVakitIsmi[i]));
    }
    return namazVakitleri;
  }


  Duration kalanZamanHesapla(List<NamazVakitleri> saatler,Duration kalanSure) {
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
      if(kalanSure.inSeconds == 30){
        print(saat.namazSaati);
        NotificationService().showNotification(body:saat.namazSaati,title: saat.vakitIsmi);
      }
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
      kalanSure  = Duration(seconds: (saatSaat - suankiSaat).toInt());

      return  kalanSure;
    } else {
      kalanSure =Duration(seconds: 50);
      return  kalanSure;
    }
  }

}