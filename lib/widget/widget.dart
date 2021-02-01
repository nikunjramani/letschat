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
      borderSide: BorderSide(color: Colors.black54, width: 1.0),
    ),
  );
}

BoxDecoration ContainerDecoration(){
  return BoxDecoration(
      borderRadius: BorderRadius.all(
          Radius.circular(5.0) //                 <--- border radius here
      ),
      border: Border.all(color: Colors.black54)
  );
}

RoundedRectangleBorder ButtonDecoration(){
  return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
      side: BorderSide(color: Colors.blue)
  );
}