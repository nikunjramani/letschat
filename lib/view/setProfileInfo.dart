import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letschat/helper/Constants.dart';
import 'package:letschat/helper/HelperFunction.dart';
import 'package:letschat/services/DataBaseMethod.dart';

import 'home.dart';
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

   AddUserInfo(){
      Map<String,dynamic> map=new Map();
      map['name']=name.text;
      map['aboutme']=aboutme.text;
      map['dob']=dob;
      map['number']=FirebaseAuth.instance.currentUser.phoneNumber;
      map['image']=profileImage;

      Constants.MyName=name.text;
      HelperFunction.saveUserAboutSharedPreference(aboutme.text);
      HelperFunction.saveUserNameSharedPreference(name.text);
      HelperFunction.saveUserNumberSharedPreference(FirebaseAuth.instance.currentUser.phoneNumber);
      HelperFunction.saveUserImageSharedPreference(profileImage);
      HelperFunction.saveUserDobSharedPreference(dob);
      HelperFunction.saveUserLoginSharedPreference(true);
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
