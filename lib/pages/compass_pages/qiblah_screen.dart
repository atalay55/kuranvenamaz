import 'dart:async';
import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'location_error_widget.dart';

class QiblahCompass extends StatefulWidget {
  @override
  _QiblahCompassState createState() => _QiblahCompassState();
}

class _QiblahCompassState extends State<QiblahCompass> {
  final _locationStreamController = StreamController<LocationStatus>.broadcast();
  Stream<LocationStatus> get stream => _locationStreamController.stream;

  Future<void> _checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    if (locationStatus.enabled && locationStatus.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      final s = await FlutterQiblah.checkLocationStatus();
      _locationStreamController.sink.add(s);
    } else {
      _locationStreamController.sink.add(locationStatus);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  @override
  void dispose() {
    super.dispose();
    _locationStreamController.close();
    FlutterQiblah().dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Text("Pusula"),
      ),
      body: Container(
        color: Colors.black87,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<LocationStatus>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data?.enabled == true) {
              final status = snapshot.data!.status;
              if (status == LocationPermission.always || status == LocationPermission.whileInUse) {
                return QiblahCompassWidget();
              } else {
                String errorMessage = status == LocationPermission.denied
                    ? "Location service permission denied"
                    : "Location service Denied Forever !";
                return LocationErrorWidget(
                  error: errorMessage,
                  callback: _checkLocationStatus,
                );
              }
            } else {
              return LocationErrorWidget(
                error: "Please enable Location service",
                callback: _checkLocationStatus,
              );
            }
          },
        ),
      ),
    );
  }
}

class QiblahCompassWidget extends StatelessWidget {
  final _compassSvg = Image.asset('assets/compass.png',height:Get.height/2,width: Get.width/1.1,);
  final _needleSvg = Image.asset(
    'assets/needle.png',
    fit: BoxFit.contain,

    height: 320,
    alignment: Alignment.center,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.black12,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            StreamBuilder<QiblahDirection>(
              stream: FlutterQiblah.qiblahStream,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final qiblahDirection = snapshot.data!;
                final compassRotation = qiblahDirection.direction * (pi / 180) * -1;
                final needleRotation = qiblahDirection.qiblah * (pi / 180) * -1;

                return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Transform.rotate(
                      angle: compassRotation,
                      child: _compassSvg,
                    ),
                    Transform.rotate(
                      angle: needleRotation,
                      alignment: Alignment.center,
                      child: _needleSvg,
                    ),

                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
