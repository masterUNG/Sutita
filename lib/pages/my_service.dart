import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sermsuk/pages/gps_runner.dart';
import 'package:sermsuk/pages/information.dart';
import 'package:sermsuk/pages/login.dart';
import 'package:sermsuk/pages/news_page.dart';
import 'package:sermsuk/pages/show_list_runner.dart';
import 'package:sermsuk/pages/type_runner.dart';

class MyService extends StatefulWidget {
  @override
  _MyServiceState createState() => _MyServiceState();
}

class _MyServiceState extends State<MyService> {
  int index = 0;
  List<Widget> widgets = [NewsPage(), GpsRunner(), TypeRunner(), Information()];

  BottomNavigationBarItem newsBotton() => BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'ข่าวสาร',
      );

  BottomNavigationBarItem gpsBotton() => BottomNavigationBarItem(
        icon: Icon(Icons.directions_run),
        label: 'GPS run',
      );

  BottomNavigationBarItem typeBotton() => BottomNavigationBarItem(
        icon: Icon(Icons.military_tech),
        label: 'การแข่งขัน',
      );

  BottomNavigationBarItem inforBotton() => BottomNavigationBarItem(
        icon: Icon(
          Icons.account_circle,
        ),
        label: 'โปรไฟล์ส่วนตัว',
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SERMSUK'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShowListRunner(),
                )),
          ),
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                await Firebase.initializeApp().then((value) async {
                  await FirebaseAuth.instance
                      .signOut()
                      .then((value) => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(),
                          ),
                          (route) => false));
                });
              })
        ],
      ),
      body: widgets[index],
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.blue,
        items: [newsBotton(), gpsBotton(), typeBotton(), inforBotton()],
        currentIndex: index,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
      ),
    );
  }
}
