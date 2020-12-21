import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:letschat/helper/HelperFunction.dart';
import 'package:letschat/view/chatRoom.dart';
import 'package:letschat/view/setProfileInfo.dart';

import 'view/home.dart';
import 'view/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: HelperFunction.getUserLoginSharedPreference(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if(snapshot.data == true) {
            return Home();
          }else{
            return LoginScreen();
          }
        },
      ),
    );
  }
}

