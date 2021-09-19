import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommonWidgets {
  static Container chatScreenBottomSheetComponent(
      String _title, IconData _iconData, _onclick) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 23, vertical: 12),
      child: Column(
        children: [
          Container(
            child: GestureDetector(
              onTap: _onclick,
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      const Color(0xff007EF4),
                      const Color(0xff2A75BC),
                    ]),
                    borderRadius: BorderRadius.circular(50)),
                child: Icon(
                  _iconData,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text("Image")
        ],
      ),
    );
  }

  static TextFormField getCustomEditTextArea({
    String labelValue = "",
    String hintValue = "",
    Function validator,
    IconData icon,
    bool validation,
    TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String validationErrorMsg,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        prefixStyle: TextStyle(color: Colors.orange),
        fillColor: Colors.white.withOpacity(0.6),
        filled: true,
        isDense: true,
        labelStyle: TextStyle(color: Colors.orange),
        focusColor: Colors.orange,
        border: new OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(8.0),
          ),
          borderSide: new BorderSide(
            color: Colors.orange,
            width: 1.0,
          ),
        ),
        disabledBorder: new OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(8.0),
          ),
          borderSide: new BorderSide(
            color: Colors.orange,
            width: 1.0,
          ),
        ),
        focusedBorder: new OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(8.0),
          ),
          borderSide: new BorderSide(
            color: Colors.orange,
            width: 1.0,
          ),
        ),
        hintText: hintValue,
        labelText: labelValue,
      ),
      validator: validator,
    );
  }

  static AppBar getAppBar(String title) {
    return AppBar(
      title: Text(title),
    );
  }

  static InputDecoration TextFieldDecorationLogin(String hint) {
    return InputDecoration(
      labelText: hint,
      hintStyle: TextStyle(color: Colors.black),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black54, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black54, width: 1.0),
      ),
    );
  }

  static BoxDecoration ContainerDecoration() {
    return BoxDecoration(
        borderRadius: BorderRadius.all(
            Radius.circular(5.0) //                 <--- border radius here
            ),
        border: Border.all(color: Colors.black54));
  }

  static RoundedRectangleBorder ButtonDecoration() {
    return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.blue));
  }
}
