import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:letschat/utils/ValidationUtils.dart';
import 'package:letschat/utils/widget.dart';

import 'Otp.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController _controller = TextEditingController();
  String countryCode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(children: [
            Container(
              margin: EdgeInsets.only(top: 60),
              child: Center(
                child: Text(
                  'Phone Authentication',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                ),
              ),
            ),
            Container(
              decoration: ContainerDecoration(),
              margin: EdgeInsets.only(top: 40, right: 10, left: 10),
              padding: EdgeInsets.all(4),
              child: CountryCodePicker(
                onChanged: print,
                showFlagMain: true,
                showFlag: true,
                initialSelection: 'IN',
                showOnlyCountryWhenClosed: true,
                alignLeft: true,
                onInit: (code) => {countryCode = code.dialCode},
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10, right: 10, left: 10),
              child: TextFormField(
                decoration: TextFieldDecorationLogin("Phone Number"),
                maxLength: 10,
                keyboardType: TextInputType.number,
                controller: _controller,
                validator: ValidationUtils.validateMobile,
              ),
            )
          ]),
          Container(
            margin: EdgeInsets.all(10),
            width: double.infinity,
            child: TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        OTPScreen(countryCode + _controller.text)));
              },
              child: Text(
                'Next',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
