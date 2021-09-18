import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:letschat/utils/Constants.dart';
import 'package:letschat/utils/shared_preference.dart';
import 'package:letschat/ui/chatroom/ChatRoom.dart';
import 'package:letschat/ui/signin/login.dart';


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
        future: SharedPreference.getBool(Constants.sharedPreferenceUserLogInKey),
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

