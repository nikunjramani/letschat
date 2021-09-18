import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:letschat/ui/chatroom/ChatRoom.dart';
import 'package:letschat/ui/signin/SignIn.dart';
import 'package:letschat/utils/Constants.dart';
import 'package:letschat/utils/PreferenceUtils.dart';

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
        future: PreferenceUtils.getBool(Constants.sharedPreferenceUserLogInKey),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data == true) {
            return Home();
          } else {
            return SignIn();
          }
        },
      ),
    );
  }
}
