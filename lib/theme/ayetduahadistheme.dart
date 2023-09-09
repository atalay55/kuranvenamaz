import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AyetDuaHadisTheme extends StatelessWidget {
   AyetDuaHadisTheme({required this.title,required this.description , this.kaynakca});
    String title;
    String description;
    String? kaynakca;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1),borderRadius: BorderRadius.circular(5)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(description),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(kaynakca??""),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
