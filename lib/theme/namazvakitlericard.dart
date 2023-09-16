
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kuranvenamaz/entity/namazvakitleri.dart';



Widget NamazVakitleriKucuk(NamazVakitleri namazVakit){
  return Container(
    width:50,
    height: 50,
    decoration: BoxDecoration(
        border: Border.all(width: 1),borderRadius: BorderRadius.circular(10)
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(namazVakit.vakitIsmi),
        Text(namazVakit.namazSaati)
      ],
    ),
  );
}