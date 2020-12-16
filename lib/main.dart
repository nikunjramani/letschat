import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
    if (FirebaseAuth.instance.currentUser != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Home(),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),
      );
    }
  }
}
