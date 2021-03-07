import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'package:sermsuk/models/runner_model.dart';
import 'package:sermsuk/pages/my_service.dart';
import 'package:sermsuk/pages/show_list_runner.dart';
import 'package:sermsuk/utility/nornal_dialog.dart';

class GpsRunner extends StatefulWidget {
  final String typeRunner;
  final bool status;
  GpsRunner({Key key, this.typeRunner, this.status}) : super(key: key);
  @override
  _GpsRunnerState createState() => _GpsRunnerState();
}

class _GpsRunnerState extends State<GpsRunner> {
  double lat, lng, distance = 0;
  bool runStatus = true;
  int runTime = 0;
  List<LatLng> latlngs = List();
  List<LatLng> coorLatLngs = List();
  LatLng latlng1, latLng2;
  bool first = true;
  String typeRunner = '3K';
  bool status = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    var object = widget.typeRunner;
    if (object != null) {
      typeRunner = object;
    }

    var object2 = widget.status;
    if (object2 != null) {
      status = object2;
    }

    findLatLng();
  }

  Future<Null> findLatLng() async {
    LocationData data = await findLocationData();
    if (data != null) {
      setState(() {
        lat = data.latitude;
        lng = data.longitude;
        // print('lat =$lat,lng =$lng');
        coorLatLngs.add(LatLng(lat, lng));
        createPolyLine();
        if (first) {
          latlng1 = LatLng(lat, lng);
          first = false;
        }
        latLng2 = LatLng(lat, lng);
        latlngs.add(LatLng(lat, lng));
      });
    }
  }

  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      return location.getLocation();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: status
            ? SizedBox()
            : IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyService(),
                      ),
                      (route) => false);
                }),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildMap(context),
              buildRunButton(),
              buildDistance(),
              buildShowTime(),
              buildSave(),
            ],
          ),
        ),
      ),
    );
  }

  OutlineButton buildSave() => OutlineButton.icon(
        onPressed: () {
          if (runTime == 0) {
            normalDialog(context, 'กรุณา วิ่งก่อน ค่อยบันทึกคะ');
          } else if (!runStatus) {
            normalDialog(context, 'กรุณา หยูดวิ่งก่อน ค่อยบันทึก คะ');
          } else {
            print('Process Save');
            processSave();
          }
        },
        icon: Icon(Icons.save),
        label: Text('บันทึก การวิ่ง'),
      );

  

  String printDuration(int sec) {
    Duration duration = Duration(seconds: sec);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }


  Future<Null> processSave() async {
    DateTime dateTime = DateTime.now();
    String dateTimeStr = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    print('dateTimeStr == $dateTimeStr');

    String distanceStr = NumberFormat('##0.0#', 'en_US').format(distance);

    List<String> typeRunners = ['3K', '5K', '10K', 'ไม่ระบุ'];
    String typeRunner;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => SimpleDialog(
          contentPadding: EdgeInsets.all(16),
          title: Text('Confirm Save'),
          children: [
            Text('วันที่บันทึก: $dateTimeStr'),
            Text('ระยะทางที่บันทึก: $distanceStr Km'),
            Text('เวลาที่บันทึก: ${printDuration(runTime)} วินาที'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    saveRunnerToServer(dateTimeStr, distanceStr, runTime);
                  },
                  child: Text('Save'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Padding buildDistance() {
    var myFormat = NumberFormat('##0.0#', 'en_US');
    String string = myFormat.format(distance);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Distance = $string km',
        style: TextStyle(
          color: Colors.red[700],
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Padding buildShowTime() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'เวลา = ${printDuration(runTime)}',
          style: TextStyle(
            color: Colors.green[700],
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  OutlinedButton buildRunButton() {
    return OutlinedButton.icon(
      onPressed: () {
        setState(() {
          runStatus = !runStatus;
          processRun();
        });
      },
      icon: Icon(
        runStatus ? Icons.run_circle : Icons.stop,
        color: runStatus ? Colors.green : Colors.red,
      ),
      label: Text(runStatus ? 'เริ่มวิ่ง' : 'หยุดวิ่ง'),
    );
  }

  void processRun() {
    print('runStatus ==>> $runStatus');
    if (runStatus) {
      //process stop
    } else {
      //process start
      autoTime();
    }
  }

  PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinate = List();
  Map<PolylineId, Polyline> polylines = Map();

  Future<Null> createPolyLine() async {
    polylinePoints = PolylinePoints();
    List<LatLng> runnerLatLng = List();
    for (var i = 0; i < 2; i++) {
      runnerLatLng.add(LatLng(lat, lng));
    }
    runnerLatLng[0] = LatLng(lat, lng);
    runnerLatLng[1] = LatLng(13.669987943560528, 100.62409090432341);

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyC0sTI_cQyGa-c09ppHnCB_gr9e2rGC1Us',
      PointLatLng(latlngs[0].latitude, latlngs[0].longitude),
      PointLatLng(latlngs[1].latitude, latlngs[1].longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      for (var item in result.points) {
        polylineCoordinate.add(LatLng(item.latitude, item.longitude));
      }
    }

    PolylineId id = PolylineId('poly');

    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: coorLatLngs,
      width: 3,
    );

    polylines[id] = polyline;
  }

  Future<Null> autoTime() async {
    Duration duration = Duration(seconds: 2);
    await Timer(duration, () async {
      if (!runStatus) {
        setState(() {
          runTime += 2;
          distance = distance +
              calculateDistance(latlng1.latitude, latlng1.longitude,
                  latLng2.latitude, latLng2.longitude);
          latlng1 = latLng2;
        });
        print('runTime = $runTime');
        findLatLng();
        autoTime();
      }
    });
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    double distance = 0;

    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
    distance = 12742 * asin(sqrt(a));

    return distance;
  }

  Set<Marker> setMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId('YourHere'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: 'คุณอยู่ที่นี่')),
    ].toSet();
  }

  Container buildMap(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 0.7,
      child: lat == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(lat, lng),
                zoom: 16,
              ),
              mapType: MapType.normal,
              onMapCreated: (controller) {},
              markers: setMarker(),
              polylines: Set<Polyline>.of(polylines.values),
            ),
    );
  }

  Future<Null> saveDashBoard(
      String dateTimeStr, String distanceStr, int runTime, String uid) async {}

  Future<Null> saveRunnerToServer(
      String dateTimeStr, String distanceStr, int runTime) async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseAuth.instance.authStateChanges().listen((event) async {
        String uid = event.uid;
        print('uid = $uid');

        RunnerModel model = RunnerModel(
            daterunner: dateTimeStr,
            distance: distanceStr,
            timerunner: runTime.toString(),
            typerunner: typeRunner);

        Map<String, dynamic> data = model.toJson();

        List<String> strings = dateTimeStr.split(' ');
        List<String> string2s = strings[0].split('/');
        String string = '${string2s[0]}-${string2s[1]}-${string2s[2]}';
        // String string = '05-${string2s[1]}-${string2s[2]}';

        await FirebaseFirestore.instance
            .collection(typeRunner)
            .doc(string)
            .set({'type': typeRunner});

        await FirebaseFirestore.instance
            .collection(typeRunner)
            .doc(string)
            .collection('runner')
            .doc(uid)
            .set(data);

        await FirebaseFirestore.instance
            .collection('User')
            .doc(uid)
            .collection('runner')
            .doc()
            .set(data)
            .then((value) {
          print('Save Success');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShowListRunner(),
            ),
          ).then((value) => clearMembery());
        });
      });
    });
  }

  void clearMembery() {
    setState(() {
      runTime = 0;
      distance = 0;
    });
  }
}
