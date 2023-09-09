
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class Zikirmatik extends StatefulWidget {
  const Zikirmatik({Key? key}) : super(key: key);

  @override
  State<Zikirmatik> createState() => _ZikirmatikState();
}

class _ZikirmatikState extends State<Zikirmatik> {
  RxInt count = RxInt(0);
  RxInt pieceCount = RxInt(0);

  var height = Get.height;
  var width = Get.width;
  void saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("count", count.toInt());
    prefs.setInt("pieceCount", pieceCount.toInt());

  }

  void reset(){
    pieceCount.value=0;
    count.value=0;
    saveCounter();
  }
  Future<void> getCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int savedCount =
        prefs.getInt("count") ?? 0; // Get the saved count or default to 0
    count.value = savedCount;

    int savedPiecCount =
        prefs.getInt("pieceCount") ?? 0; // Get the saved count or default to 0
    count.value = savedPiecCount;// Update the count with the saved value
  }
  void vibratePhone() {
    Vibration.vibrate(duration: 1000); // Telefonu 1 saniye boyunca titret
  }
  @override
  void initState() {
    getCounter().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (count.value % 33 == 0 && count.value != 0) {
      vibratePhone();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title:  Text("ZikirMatik" ,style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
        toolbarHeight: height/14,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

           Padding(
             padding:  EdgeInsets.symmetric(vertical: height/15),
             child: Text(" Toplam : $pieceCount  * 99  = ${pieceCount.value*99}",style:TextStyle(fontSize: 25, )),
           ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: (){
                      setState(() {
                        if (count.value > 0) {
                          count--;
                          saveCounter();
                        }

                      });
                     },
                    style: ElevatedButton.styleFrom(
                      fixedSize:Size.fromRadius(22) ,
                      shape: CircleBorder(),
                      primary: Colors.red, // Azaltma düğmesinin arkaplan rengini ayarlayın
                    ),
                    child: Icon(Icons.remove,size:35,),
                  ),
                  GestureDetector(
                   onTap: (){
                     setState(() {
                       if (count.value==99)
                       {
                         pieceCount++; count.value=0;
                       }
                       count++;
                       saveCounter();
                     });
                   },
                    child: Center(
                      child: Container(
                        width: width/2,
                        height: height/3,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Text("${count.value} / 99" ,style: TextStyle(color: Colors.black, fontSize: 25),),

                          ],
                        ),
                      ),
                    ),
                  ),  ElevatedButton(
                    onPressed: (){
                      setState(() {
                        if (count.value==99)
                          {
                            pieceCount++; count.value=0;
                          }
                        count++;
                        saveCounter();
                      });

                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize:Size.fromRadius(22) ,
                      shape: CircleBorder(),
                      primary: Colors.green, // Artırma düğmesinin arkaplan rengini ayarlayın
                    ),
                    child: Icon(Icons.add,size:35),
                  ),
                ],
              ),
            ),

        Padding(
          padding:  EdgeInsets.only(top: height/10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: Size(150, 50),
              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(10), // Dikdörtgenin kenar yarıçapını ayarlayın
              ),
              primary: Colors.black45, // Artırma düğmesinin arkaplan rengini ayarlayın
            ),
            child:Text("Sıfırla" ,style: TextStyle(fontSize: 22),) ,onPressed:(){
            setState(() {
              aboutDialog();
            });
          } ,),
        ),
            Padding(
              padding:  EdgeInsets.only(top: 15),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(150, 50),
                  shape: RoundedRectangleBorder(

                    borderRadius: BorderRadius.circular(10), // Dikdörtgenin kenar yarıçapını ayarlayın
                  ),
                  primary: Colors.black45, // Artırma düğmesinin arkaplan rengini ayarlayın
                ),
                child:Text("Ayarlar" ,style: TextStyle(fontSize: 22),) ,
                onPressed:(){
                setState(() {

                });
              } ,),
            )

/*
            Padding(
              padding: EdgeInsets.only(top: height / 10),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    count++;
                    saveCounter();
                  });
                },
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                            onPressed: () {
                              // Icona tıklanınca yapılacak işlem
                            },
                            icon: CircleAvatar(
                              child: Text("0"),
                              backgroundColor: Colors.white,
                              radius: 50,
                            )),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () {
                              // Icona tıklanınca yapılacak işlem
                            },
                            icon: Icon(
                              Icons.settings,
                              size: 25,
                            )),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              count.value = 0;
                              saveCounter();
                            });
                          },
                          icon: Icon(Icons.replay_circle_filled),
                        ),
                      ),

                      Align(
                        alignment: Alignment.bottomLeft,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              count--;
                              saveCounter();
                            });
                          },
                          icon: Icon(Icons.exposure_minus_1),
                          iconSize: 25,
                        ),
                      ),

                      Align(
                        alignment: Alignment.center,
                        child: Text("${count.value} / 99"),
                      ),

                      // Diğer widget'lar buraya eklenebilir
                    ],
                  ),
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
  aboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.grey,
          titlePadding: EdgeInsets.only(top: 15, left: width / 2),
          title: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.clear),
          ),
          content: Column(
            children: [Text("Sıfırlamak istiyor musunuz?")],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Düğme rengi
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Düğme köşe yarıçapı
                ),
              ),
              child: Text("Hayır"),
            ),
            ElevatedButton(
              onPressed: (){
                setState(() {
                  reset();
                  Navigator.of(context).pop();
                });
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // Düğme rengi
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Düğme köşe yarıçapı
                ),
              ),
              child: Text("Evet"),
            ),
          ],
        );
      },
    );
  }

}

