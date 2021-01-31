import 'package:flutter/material.dart';

AppBar getAppBar(String title){
  return AppBar(
    title: Text(title),
  );
}

InputDecoration TextFieldDecorationLogin(String hint){
  return InputDecoration(
    labelText: hint,
    hintStyle: TextStyle(
        color: Colors.black
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black54, width: 1.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 1.0),
    ),
    prefix: Text('+91'),
  );
}