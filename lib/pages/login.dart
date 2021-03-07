import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sermsuk/pages/my_service.dart';
import 'package:sermsuk/pages/register.dart';
import 'package:sermsuk/utility/nornal_dialog.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email, password;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkStatus();
  }

  Future<Null> checkStatus() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseAuth.instance.authStateChanges().listen((event) {
        if (event != null) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MyService(),
              ),
              (route) => false);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildLogo(),
              buildAppName(),
              buildUser(),
              buildPassword(),
              buildForgotpassword(),
              buildButtonLogin(),
              buildResgister(),
            ],
          ),
        ),
      ),
    );
  }

  OutlinedButton buildButtonLogin() {
    return OutlinedButton(
      onPressed: () {
        if (email == null ||
            email.isEmpty ||
            password == null ||
            password.isEmpty) {
          normalDialog(context, 'กรุณากรอกทุกช่อง ค่ะ!!');
        } else {
          checkLogin();
        }
      },
      child: Text('เข้าสู่ระบบ'),
    );
  }

  Future<Null> checkLogin() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MyService(),
              ),
              (route) => false))
          .catchError((error) {
        normalDialog(context, error.message);
      });
    });
  }

  TextButton buildForgotpassword() => TextButton(
        onPressed: () async {
          email = null;
          showDialog(
            context: context,
            builder: (context) => SimpleDialog(
              title: ListTile(
                leading: Image(
                  image: AssetImage('images/logoip.png'),
                ),
                title: Text('Forgot Password ?'),
                subtitle: Text('กรุณากรอก Email ที่เคยสมัคร'),
              ),
              children: [
                Container(
                  margin: EdgeInsets.only(left: 50, right: 50),
                  child: TextField(
                    onChanged: (value) => email = value.trim(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (email?.isEmpty ?? true) {
                      normalDialog(context, 'Email ห้ามว่าง คะ');
                    } else {
                      await Firebase.initializeApp().then((value) async {
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(email: email)
                            .then((value) => normalDialog(context, 'กรุณาไปตรวจ Email เราส่ง Reset Email ไปแล้ว'))
                            .catchError((onError) {
                          normalDialog(context, onError.message);
                        });
                      });
                    }
                  },
                  child: Text('Send'),
                ),
              ],
            ),
          );
        },
        child: Text('ลืมรหัสผ่าน'),
      );

  TextButton buildResgister() => TextButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Register(),
            )),
        child: Text('สมัครสมาชิก'),
      );

  Container buildUser() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      width: 250,
      child: TextField(
        onChanged: (value) => email = value.trim(),
        decoration: InputDecoration(
          hintText: 'ชื่อผู้ใช้งาน',
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

  Container buildPassword() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      width: 250,
      child: TextField(
        onChanged: (value) => password = value.trim(),
        obscureText: true,
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

  Text buildAppName() => Text(
        'ลงชื่อเข้าใช้งาน',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );

  Container buildLogo() {
    return Container(
      width: 120,
      child: Image.asset('images/logoip.png'),
    );
  }
}
