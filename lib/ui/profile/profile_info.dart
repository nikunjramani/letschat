import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letschat/utils/constants.dart';
import 'package:letschat/utils/firestore_provider.dart';
import 'package:letschat/utils/preference_utils.dart';

import '../chatroom/chat_room.dart';

class ProfileInfo extends StatefulWidget {
  @override
  _ProfileInfoState createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  FirebaseStorage _storage = FirebaseStorage.instance;
  String profileImage, dob;
  bool profileImageSet = false;

  DateTime selectedDate = DateTime.now();

  TextEditingController name = new TextEditingController();
  TextEditingController aboutme = new TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dob = selectedDate.toString();
      });
  }

  AddUserInfo() async {
    Map<String, dynamic> map = new Map();
    map['name'] = name.text;
    map['aboutme'] = aboutme.text;
    map['dob'] = dob;
    map['number'] = FirebaseAuth.instance.currentUser.phoneNumber;
    map['image'] = profileImage;
    map['usertoken'] = await FirebaseMessaging().getToken();

    Constants.MyName = name.text;
    PreferenceUtils.setString(
        Constants.sharedPreferenceUserAbout, aboutme.text);
    PreferenceUtils.setString(Constants.sharedPreferenceUserName, name.text);
    PreferenceUtils.setString(Constants.sharedPreferenceUserNumber,
        FirebaseAuth.instance.currentUser.phoneNumber);
    PreferenceUtils.setString(
        Constants.sharedPreferenceUserImage, profileImage);
    PreferenceUtils.setString(Constants.sharedPreferenceUserDob, dob);
    PreferenceUtils.setString(Constants.sharedPreferenceUserToken,
        await FirebaseMessaging().getToken());
    PreferenceUtils.setBoolean(Constants.sharedPreferenceUserLogInKey, true);
    DataBaseMethods.uploadUserInfo(map);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ChatRoom()));
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
                    profileImage = await uploadPic();
                  },
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: getProfileWidget()),
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
                  onTap: () => _selectDate(context),
                  child: Container(
                      height: 50,
                      child: Text("${selectedDate.toLocal()}".split(' ')[0])),
                ),
                TextButton(
                  onPressed: AddUserInfo,
                  child: Text(
                    "Submit",
                    style: TextStyle(fontSize: 20.0),
                  ),
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
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
    Reference reference = _storage
        .ref()
        .child("UserProfileImage")
        .child(FirebaseAuth.instance.currentUser.uid + "_profile");
    UploadTask uploadTask = reference.putFile(pickedFile);
    String location = await uploadTask.then((res) => res.ref.getDownloadURL());

    //returns the download url
    setState(() {
      profileImageSet = true;
    });
    print(location);
    return location;
  }

  getProfileWidget() {
    return profileImageSet
        ? Image.network(
            profileImage,
            width: 200.0,
            height: 200.0,
            fit: BoxFit.fill,
          )
        : Image.asset(
            "images/user-profile.png",
            width: 200.0,
            height: 200.0,
            fit: BoxFit.fill,
          );
  }
}
