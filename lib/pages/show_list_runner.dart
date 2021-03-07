import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sermsuk/models/runner_model.dart';

class ShowListRunner extends StatefulWidget {
  @override
  _ShowListRunnerState createState() => _ShowListRunnerState();
}

class _ShowListRunnerState extends State<ShowListRunner> {
  bool statusLoad = true;
  bool statusData = false; // true => Have Data
  List<RunnerModel> runnerModels = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readData();
  }

  Future<Null> readData() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseAuth.instance.authStateChanges().listen((event) async {
        String uid = event.uid;
        print('uid ==>> $uid');
        await FirebaseFirestore.instance
            .collection('User')
            .doc(uid)
            .collection('runner')
            .snapshots()
            .listen((event) {
          // print('event == ${event.docs}');
          setState(() {
            statusLoad = false;
          });
          if (event.docs.toString() != '[]') {
            for (var item in event.docs) {
              RunnerModel model = RunnerModel.fromJson(item.data());

              setState(() {
                statusData = true;
                runnerModels.add(model);
              });
            }
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แสดงสถิติการวิ่ง'),
      ),
      body: statusLoad
          ? Center(child: CircularProgressIndicator())
          : statusData
              ? ListView.builder(
                  itemCount: runnerModels.length,
                  itemBuilder: (context, index) => Card(color: index % 2 == 0 ? Colors.lime : Colors.lime.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   'ชนิดของการแข่งขัน: ${runnerModels[index].typerunner}',
                          //   style: TextStyle(
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.bold,
                          //     color: Colors.purple.shade700,
                          //   ),
                          // ),
                          Text('วันเวลา: ${runnerModels[index].daterunner}'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  'ระยะทาง: ${runnerModels[index].distance} กิโลเมตร'),
                              Text(
                                  'เวลาแข่งขัน: ${runnerModels[index].timerunner} วินาที'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Center(child: Text('ไม่มี สถิติการวิ่ง เลยคะ')),
    );
  }
}
