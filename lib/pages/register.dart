import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sermsuk/models/user_model.dart';
import 'package:sermsuk/utility/nornal_dialog.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String name, surname, phone, email, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('สมัครสมาชิก'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildName(),
              buildSurName(),
              buildPhone(),
              buildEmail(),
              buildPassword(),
              buildButtonResgister()
            ],
          ),
        ),
      ),
    );
  }

  Container buildButtonResgister() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: OutlinedButton(
        onPressed: () {
          print(
              'name = $name,surname = $surname,phone =$phone,email =$email,password =$password');
          if (name == null ||
              name.isEmpty ||
              surname == null ||
              surname.isEmpty ||
              phone == null ||
              phone.isEmpty ||
              email == null ||
              email.isEmpty ||
              password == null ||
              password.isEmpty) {
            normalDialog(context, 'กรุณากรอกทุกช่องค่ะ');
          } else {
            registerAndInsertUser();
          }
        },
        child: Text('ยืนยัน'),
      ),
    );
  }

  Future<Null> registerAndInsertUser() async {
    await Firebase.initializeApp().then((value) async {
      print('Initialize Success');

      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
        String uid = value.user.uid;
        print('Resgister Success uid ==> $uid');

        UserModel model = UserModel(
            name: name,
            surname: surname,
            phone: phone,
            email: email,
            avatar: '');
        Map<String, dynamic> data = model.toJson();

        print('data for registe ==>> ${data.toString()}');

        insertData(uid, data);
      }).catchError((error) {
        normalDialog(context, error.message);
      });
    });
  }

  Future<Null> insertData(String uid, Map<String, dynamic> data) async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(uid)
          .set(data)
          .then((value) {
        print('insert Data Success ############');
        Navigator.pop(context);
      }).catchError((value) {
        print('Error ======>>> ${value.message}');
      });
    });
  }

  Container buildName() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      width: 250,
      child: TextField(
        onChanged: (value) => name = value.trim(),
        decoration: InputDecoration(
          hintText: 'ชื่อ',
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
      child: TextField(
        onChanged: (value) => surname = value.trim(),
        decoration: InputDecoration(
          hintText: 'นามสกุล',
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
      child: TextField(
        onChanged: (value) => phone = value.trim(),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'เบอร์โทรศัพท์',
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

  Container buildEmail() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      width: 250,
      child: TextField(
        onChanged: (value) => email = value.trim(),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'อีเมล',
          prefixIcon: Icon(Icons.email),
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

  Container buildPassword() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      width: 250,
      child: TextField(
        onChanged: (value) => password = value.trim(),
        decoration: InputDecoration(
          hintText: 'รหัสผ่าน',
          prefixIcon: Icon(Icons.lock),
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
}
