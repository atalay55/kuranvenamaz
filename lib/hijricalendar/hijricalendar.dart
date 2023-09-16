import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:kuranvenamaz/core/utilities.dart';
class HijriCalendarWidget extends StatefulWidget {
  const HijriCalendarWidget({Key? key}) : super(key: key);

  @override
  State<HijriCalendarWidget> createState() => _HijriCalendarWidgetState();
}

class _HijriCalendarWidgetState extends State<HijriCalendarWidget> {

  DateTime selectedDate = DateTime.now();
  var _format = HijriCalendar.now();
  // localization olayını tamamlamak lazım yarım kaldı
  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: const Locale('tr'),
      child: Scaffold(
        appBar: AppBar(title: Text("Hicri Takvim"),
          backgroundColor: Colors.black54,),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/mescidi-nebevi.jpg'), // Resmin yolunu belirtin
                fit: BoxFit.cover,
                opacity: 0.7 // Resmin nasıl doldurulacağını seçin
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.black26
                  ),
                  height: Utilities().height/2.5,
                  width: Utilities().width,
                  child:_buildCupertinoDatePicker(context),

                ),
              ),
              SizedBox(height: 20.0),
          Text(
            "${_format.toFormat("dd MMMM yyyy",)}",
            style: TextStyle(
              fontSize: 24.0,
            ),),/*
              Text(
                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCupertinoDatePicker(BuildContext context) {
    return Container(
      height: Utilities().height/3,

      child: CupertinoDatePicker(
        dateOrder: DatePickerDateOrder.dmy,
        mode: CupertinoDatePickerMode.date,
        initialDateTime: selectedDate,
        onDateTimeChanged: (dateTime) {
          setState(() {
            selectedDate = dateTime;
            _format= HijriCalendar.fromDate(selectedDate);
          });
        },
      ),

    );
  }
}
