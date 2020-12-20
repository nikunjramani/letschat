import 'package:flutter/material.dart';
import 'package:letschat/helper/Constants.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Center(
        child: new Container(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: Image.network(
                  Constants.MyImage,
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.fill,
                ),
              ),
              Text(Constants.MyName),
              Text(Constants.MyNumber),
              Text(Constants.MyDob),
              Text(Constants.MyAvoutMe),
            ],
          ),
        ),
      ),
    );
  }
}
