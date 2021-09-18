import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letschat/utils/Constants.dart';
import 'package:letschat/utils/shared_preference.dart';
import 'package:letschat/utils/DataBaseMethod.dart';

import '../chatroom/ChatRoom.dart';
class SetProfileInfo extends StatefulWidget {
  @override
  _SetProfileInfoState createState() => _SetProfileInfoState();
}

class _SetProfileInfoState extends State<SetProfileInfo> {
  FirebaseStorage _storage = FirebaseStorage.instance;
  String profileImage,dob;
  bool profileImageSet=false;

  DateTime selectedDate = DateTime.now();

  TextEditingController name= new TextEditingController();
  TextEditingController aboutme=new TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dob=selectedDate.toString();
      });
  }

   AddUserInfo() async {
      Map<String,dynamic> map=new Map();
      map['name']=name.text;
      map['aboutme']=aboutme.text;
      map['dob']=dob;
      map['number']=FirebaseAuth.instance.currentUser.phoneNumber;
      map['image']=profileImage;
      map['usertoken']=await FirebaseMessaging().getToken();

      Constants.MyName=name.text;
      SharedPreference.setString(Constants.sharedPreferenceUserAbout,aboutme.text);
      SharedPreference.setString(Constants.sharedPreferenceUserName,name.text);
      SharedPreference.setString(Constants.sharedPreferenceUserNumber,FirebaseAuth.instance.currentUser.phoneNumber);
      SharedPreference.setString(Constants.sharedPreferenceUserImage,profileImage);
      SharedPreference.setString(Constants.sharedPreferenceUserDob,dob);
      SharedPreference.setString(Constants.sharedPreferenceUserToken,await FirebaseMessaging().getToken());
      SharedPreference.setBoolean(Constants.sharedPreferenceUserLogInKey,true);
    DataBaseMethods.uploadUserInfo(map);
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => Home()
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: new Container(
          child: Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    profileImage=await uploadPic();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100.0),
                    child:getProfileWidget()
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Name',
                  ),
                  keyboardType: TextInputType.text,
                  controller: name,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'About Me',
                  ),
                  keyboardType: TextInputType.text,
                  controller: aboutme,
                ),
                GestureDetector(
                  onTap: ()=>_selectDate(context),
                  child: Container(
                    height: 50,
                      child: Text("${selectedDate.toLocal()}".split(' ')[0])
                  ),
                ),
                FlatButton(
                    onPressed: AddUserInfo,
                    child: Text("Submit", style: TextStyle(fontSize: 20.0),),
                    color: Colors.blueAccent,
                    textColor: Colors.white,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


   uploadPic() async {

    //Get the file from the image picker and store it
    final pickedFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    Reference reference = _storage.ref().child("UserProfileImage").child(FirebaseAuth.instance.currentUser.uid+"_profile");
    UploadTask uploadTask = reference.putFile(pickedFile);
    String location = await uploadTask.then((ress) => ress.ref.getDownloadURL());

    //returns the download url
    setState(() {
      profileImageSet=true;
    });
    print(location);
    return location;
  }

  getProfileWidget() {
    return profileImageSet?Image.network(
      profileImage,
      width: 200.0,
      height: 200.0,
      fit: BoxFit.fill,
    ):Image.asset(
    "images/user-profile.png",
    width: 200.0,
    height: 200.0,
    fit: BoxFit.fill,
    );
  }
}
