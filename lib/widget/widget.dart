import 'package:flutter/material.dart';

AppBar getAppBar(String title){
  return AppBar(
    title: Text(title),
  );
}

InputDecoration TextFieldDecoration(String hint){
  return InputDecoration(
      labelText: hint,
      hintStyle: TextStyle(
          color: Colors.black12
      ),
      focusedBorder: UnderlineInputBorder(
          borderSide:BorderSide(color:  Colors.black26)
      )
  );
}