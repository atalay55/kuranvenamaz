import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../entity/namazvakitleri.dart';
import 'httpcontroller.dart';

class Utilities {
  late SharedPreferences prefs;
  List<String> namazSaatleri = [];

  Future<void> initializeData() async {
    await getShered(); // prefs değişkenini başlat
    String? country = prefs.getString("country");
    String? city = prefs.getString("city");
    late Map<String, List<String>> times;
    await HttpController()
        //.fetchPrayerTimesData(country!, city!)
        .fetchPrayerTimesData("Turkey", "Samsun")
        .then((value) {
      times = value.timesByDate;
      namazSaatleri = times[DateFormat('yyyy-MM-dd').format(DateTime.now())] ??
          [];
    });

    print(namazSaatleri);
  }

  Future<void> getShered() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<List<NamazVakitleri>> getNamazVakitleri() async {
    List<String> namazVakitIsmi = ["imsak","Güneş", "sabah", "ögle", "ikindi", "yatsi"];
    List<NamazVakitleri> namazVakitleri = [];
   await initializeData();

    for (int i = 0; i < namazVakitIsmi.length; i++) {
      namazVakitleri.add(NamazVakitleri(namazSaati: namazSaatleri[i], vakitIsmi: namazVakitIsmi[i]));
    }

    print(namazVakitleri);
    return namazVakitleri;
  }
}
