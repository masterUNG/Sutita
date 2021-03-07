import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<String> urlImages = List();

  List<String> images = [
    'images/Newsrun2.png',
    'images/HowRun.png',
    'images/warm1.png',
    'images/w2.png'
  ];

  List<Widget> widgets = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readDataFromFirebase();
  }

  Future<Null> readDataFromFirebase() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('News')
          .orderBy('key')
          .snapshots()
          .listen((event) {
        for (var item in event.docs) {
          String url = item.data()['Url'];

          urlImages.add(url);
        }
        createArrayWidget();
      });
    });
  }

  void createArrayWidget() {
    for (var path in urlImages) {
      Widget widget = Image(image: NetworkImage(path));
      setState(() {
        widgets.add(widget);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgets.length == 0
          ? CircularProgressIndicator()
          : ListView.builder(
              itemCount: widgets.length,
              itemBuilder: (context, index) => widgets[index],
            ),
    );
  }
}
