import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sermsuk/models/user_model.dart';
import 'package:sermsuk/utility/nornal_dialog.dart';

class EditInfor extends StatefulWidget {
  final UserModel model;
  EditInfor({Key key, this.model}) : super(key: key);

  @override
  _EditInforState createState() => _EditInforState();
}

class _EditInforState extends State<EditInfor> {
  UserModel userModel;
  File file;
  String name, surname, phone, avatar;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userModel = widget.model;

    name = userModel.name;
    surname = userModel.surname;
    phone = userModel.phone;
    if (userModel.avatar != null) {
      avatar = userModel.avatar;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไข Profile ${userModel.name}'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildAvatar(),
              buildCameraGallery(),
              buildName(),
              buildSurName(),
              buildPhone(),
              buildSaveButton()
            ],
          ),
        ),
      ),
    );
  }

  Future<Null> chooseAvatar(ImageSource source) async {
    try {
      var result = await ImagePicker()
          .getImage(source: source, maxWidth: 800, maxHeight: 800);
      setState(() {
        file = File(result.path);
      });
    } catch (e) {}
  }

  RaisedButton buildSaveButton() {
    return RaisedButton.icon(
      onPressed: () {
        if (avatar == null && file == null) {
          normalDialog(context, 'กรุณาเลือกรูปภาพด้วย');
        } else if (name.isEmpty || surname.isEmpty || phone.isEmpty) {
          normalDialog(context, 'กรุณากรอกทุกช่อง ค่ะ');
        } else {
          uploadAvatarEditDatabase();
        }
      },
      icon: Icon(Icons.save),
      label: Text('บันทึก'),
    );
  }

  Future<Null> uploadAvatarEditDatabase() async {
    if (file != null) {
      await Firebase.initializeApp().then((value) async {
        int i = Random().nextInt(1000000);
        String nameFile = 'avatar$i.jpg';
        FirebaseStorage storage = FirebaseStorage.instance;
        var refer = storage.ref().child('Avatar/$nameFile');
        UploadTask task = refer.putFile(file);
        await task.whenComplete(() async {
          avatar = await refer.getDownloadURL();
          print('avatar ==>> $avatar');
          editValueOnFirebase();
        });
      });
    } else {
      editValueOnFirebase();
    }
  }

  Future<Null> editValueOnFirebase() async {
    await Firebase.initializeApp().then((value) async {
      Map<String, dynamic> map = Map();
      map['Name'] = name;
      map['Surname'] = surname;
      map['Phone'] = phone;
      map['Avatar'] = avatar;
      await FirebaseAuth.instance.authStateChanges().listen((event) async {
        String uid = event.uid;
        await FirebaseFirestore.instance
            .collection('User')
            .doc(uid)
            .update(map)
            .then((value) => Navigator.pop(context));
      });
    });
  }

  Container buildName() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      width: 250,
      child: TextFormField(
        onChanged: (value) => name = value.trim(),
        initialValue: userModel.name,
        decoration: InputDecoration(
          labelText: 'ชื่อ',
          prefixIcon: Icon(Icons.account_circle),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.blue),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Container buildSurName() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      width: 250,
      child: TextFormField(
        onChanged: (value) => surname = value.trim(),
        initialValue: userModel.surname,
        decoration: InputDecoration(
          labelText: 'นามสกุล',
          prefixIcon: Icon(Icons.group),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.blue),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Container buildPhone() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      width: 250,
      child: TextFormField(
        onChanged: (value) => phone = value.trim(),
        keyboardType: TextInputType.phone,
        initialValue: userModel.phone,
        decoration: InputDecoration(
          labelText: 'เบอร์โทรศัพท์',
          prefixIcon: Icon(Icons.phone),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.blue),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Row buildCameraGallery() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(Icons.add_a_photo),
          onPressed: () => chooseAvatar(ImageSource.camera),
        ),
        IconButton(
          icon: Icon(Icons.add_photo_alternate),
          onPressed: () => chooseAvatar(ImageSource.gallery),
        )
      ],
    );
  }

  Container buildAvatar() {
    return Container(
      margin: EdgeInsets.all(20),
      width: 250,
      height: 250,
      child: file == null
          ? userModel.avatar == null
              ? Image.asset('images/avatar.png')
              : CircleAvatar(backgroundImage: NetworkImage(userModel.avatar),)
          : Image.file(file),
    );
  }
}
