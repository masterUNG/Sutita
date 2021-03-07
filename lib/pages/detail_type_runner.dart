import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sermsuk/models/runner_model.dart';
import 'package:sermsuk/models/user_model.dart';
import 'package:sermsuk/pages/gps_runner.dart';
import 'package:sermsuk/utility/nornal_dialog.dart';

class DetailTypeRunner extends StatefulWidget {
  final String imagePath;
  final String title;
  final int index;
  DetailTypeRunner({Key key, this.imagePath, this.title, this.index})
      : super(key: key);

  @override
  _DetailTypeRunnerState createState() => _DetailTypeRunnerState();
}

class _DetailTypeRunnerState extends State<DetailTypeRunner> {
  String image, title, type;
  int index;

  List<String> nameTypes = [
    '3K Lorem Ipsum is simply',
    '5K Lorem Ipsum is simply',
    '10K Lorem Ipsum is simply',
  ];
  List<String> detailType = [
    '3K Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries',
    '5K Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries',
    '10K Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    image = widget.imagePath;
    title = widget.title;
    index = widget.index;
    readData();
  }

  List<String> uidRunners = [];
  List<String> nameRunners = [];
  List<RunnerModel> runnerModels = [];
  List<DateTime> dateTimes = [];
  Map<String, dynamic> nameSurMap = Map();
  int i = 1;

  Future<Null> readData() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('User')
          .snapshots()
          .listen((event) async {
        for (var item in event.docs) {
          String nameRunner =
              '${item.data()['Name']} ${item.data()['Surname']}';
          nameSurMap[item.id] = nameRunner;
        } // for

        print('########## title = $title');
        await FirebaseFirestore.instance
            .collection(title)
            .snapshots()
            .listen((event) async {
          print('###### evetn ==> ${event.docs}');
          for (var item in event.docs) {
            String dateTimeStr = item.id;
            print('####### dateTimeStr = $dateTimeStr');
            List<String> strings = dateTimeStr.split('-');
            DateTime dateTime = DateTime(
              int.parse(strings[2]),
              int.parse(strings[1]),
              int.parse(strings[0]),
            );
            print('###### datetime ==>> $dateTime');
            if (dateTimes.length == 0) {
              dateTimes.add(dateTime);
            } else {
              if (dateTimes[0].isBefore(dateTime)) {
                dateTimes[0] = dateTime;
              }
            }
          } // for
          print('##### การแข่งขันล่าสุด ==>> ${dateTimes[0]}');
          String string = dateTimes[0].toString();
          List<String> strings = string.split(' ');

          List<String> dateStrs = strings[0].split('-');
          String dateStr = '${dateStrs[2]}-${dateStrs[1]}-${dateStrs[0]}';
          print('##### dateStrs ===> $dateStr');

          await FirebaseFirestore.instance
              .collection(title)
              .doc(dateStr)
              .collection('runner')
              .orderBy('timerunner')
              .snapshots()
              .listen((event) {
            for (var item in event.docs) {
              setState(() {
                nameRunners.add('$i ${nameSurMap[item.id]}');
                runnerModels.add(RunnerModel.fromJson(item.data()));
              });
              i++;
            }
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: buildRegister(context),
      appBar: AppBar(
        title: Text('ชนิดการแข่งขันแบบ: $title'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTitle1(),
            buildDetail(),
            buildTitle2(),
            buildListView(),
          ],
        ),
      ),
    );
  }

  ListView buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: nameRunners.length,
      itemBuilder: (context, index) => Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nameRunners[index],
                style: TextStyle(fontSize: 18),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Distance = ${runnerModels[index].distance} Km'),
                  Text('Time = ${runnerModels[index].timerunner} Hr'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding buildTitle2() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('จัดอันดับผู้แข่งขัน',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          )),
    );
  }

  Padding buildDetail() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(detailType[index]),
    );
  }

  Padding buildTitle1() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        nameTypes[index],
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  ElevatedButton buildRegister(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        print('####################### register Work');
        await Firebase.initializeApp().then((value) async {
          await FirebaseAuth.instance.authStateChanges().listen((event) async {
            String uid = event.uid;
            await FirebaseFirestore.instance
                .collection('User')
                .doc(uid)
                .snapshots()
                .listen((event) {
              UserModel model = UserModel.fromJson(event.data());
              print('###### type ==>> ${model.type}');
              if (model.type == null) {
                print('ยังไม่มี Type');
                showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) => SimpleDialog(
                        title: ListTile(
                          leading: Image(
                            image: AssetImage('images/logoip.png'),
                          ),
                          title: Text('โปรดเลือก Type'),
                        ),
                        children: [
                          RadioListTile(
                            title: Text('บุคลทั้วไป'),
                            value: 'General',
                            groupValue: type,
                            onChanged: (value) {
                              setState(() {
                                type = value;
                              });
                            },
                          ),
                          RadioListTile(
                            title: Text('ผู้แข่งขั้น'),
                            value: 'Sport',
                            groupValue: type,
                            onChanged: (value) {
                              setState(() {
                                type = value;
                              });
                            },
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              if (type == null) {
                                normalDialog(context, 'โปรดเลือก Type ด้วยคะ');
                              } else {
                                Map<String, dynamic> data = Map();
                                data['Type'] = type;
                                await FirebaseFirestore.instance
                                    .collection('User')
                                    .doc(uid)
                                    .update(data)
                                    .then((value) =>
                                        moveToGpsRunner(context, model));
                              }
                            },
                            child: Text('Save'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                moveToGpsRunner(context, model);
              }
            });
          });
        });
      },
      child: Text('สมัครแข่งขันแบบ : $title'),
    );
  }

  void moveToGpsRunner(BuildContext context, UserModel model) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => GpsRunner(
            typeRunner: title,
            status: false,
          ),
        ),
        (route) => false);
  }
}
