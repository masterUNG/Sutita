import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sermsuk/models/user_model.dart';
import 'package:sermsuk/pages/edit_infor.dart';

class Information extends StatefulWidget {
  @override
  _InformationState createState() => _InformationState();
}

class _InformationState extends State<Information> {
  UserModel userModel;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readInfor();
  }

  Future<Null> readInfor() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseAuth.instance.authStateChanges().listen((event) async {
        String uid = event.uid;
        print('uid Login ==> $uid');
        await FirebaseFirestore.instance
            .collection('User')
            .doc(uid)
            .snapshots()
            .listen((event) {
          setState(() {
            userModel = UserModel.fromJson(event.data());
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: userModel == null
          ? Text('ไม่มีข้อมูล ')
          : Center(
              child: Column(
                children: [
                  buildAvatar(),
                  buildEditButton(),
                  Text('ชื่อ : ${userModel.name}'),
                  Text('นามสกุล : ${userModel.surname}'),
                  Text('เบอร์โทร : ${userModel.phone}'),
                  Text('อีเมล : ${userModel.email}'),
                ],
              ),
            ),
    );
  }

  RaisedButton buildEditButton() => RaisedButton.icon(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: Colors.blue,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditInfor(
              model: userModel,
            ),
          ),
        ).then((value) => readInfor()),
        icon: Icon(
          Icons.edit,
          color: Colors.white,
        ),
        label: Text(
          'แก้ไข',
          style: TextStyle(color: Colors.white),
        ),
      );

  Container buildAvatar() {
    return Container(
      margin: EdgeInsets.all(20),
      width: 250,
      height: 250,
      child: userModel.avatar == null
          ? Image.asset('images/avatar.png')
          : CircleAvatar(
              backgroundImage: NetworkImage(userModel.avatar),
            ),
    );
  }
}
