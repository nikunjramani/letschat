import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:letschat/utils/Constants.dart';
import 'package:letschat/utils/DataBaseMethod.dart';
import 'package:http/http.dart' as http;
import 'package:letschat/ui/chatscreen/ChatScreen.dart';
import 'package:image/image.dart' as Imp;

class UploadImage extends StatefulWidget {
  File _file;
  String _chatRoomId,_username;

  UploadImage(this._file, this._chatRoomId, this._username);

  @override
  _UploadImageState createState() => _UploadImageState(_file,_chatRoomId,_username);
}

class _UploadImageState extends State<UploadImage> {
  _UploadImageState(File file, String chatRoomId, String username);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarBuild(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          Reference reference = FirebaseStorage.instance.ref().child("UserShareMedia").child(FirebaseAuth.instance.currentUser.uid).child("Image").child(fileName);
          UploadTask uploadTask = reference.putFile(widget._file);
          String location = await uploadTask.then((ress) => ress.ref.getDownloadURL());

          if(location!=null) {
            Map<String,dynamic> messageMap=new Map();
            messageMap["message"]=location;
            messageMap["sendBy"]=Constants.MyName;
            messageMap["type"]="image";
            messageMap["time"]=DateTime.now().millisecondsSinceEpoch;
            DataBaseMethods.sendConversationMessage(widget._chatRoomId, messageMap);
            String sendToken=await DataBaseMethods.getUserToken(Constants.Token);
            print(sendToken);
            sendAndRetrieveMessage(Constants.MyName, location,sendToken);
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatRoom(widget._chatRoomId, widget._username)));
          }
        },
        child: Icon(Icons.send,color: Colors.white,),
      ),
      body: new Container(
        margin: EdgeInsets.symmetric(vertical: 150),
        decoration: BoxDecoration(
          color: Colors.black54
        ),
        child: Center(
            child: Image.file(
                widget._file,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            )
        ),
      ),
    );
  }
  Widget AppbarBuild(){
    return AppBar(
      leading:  IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text("Upload Image"),
    );
  }
  Future<Map<String, dynamic>> sendAndRetrieveMessage(String title,String message,String token) async {
    await FirebaseMessaging().requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),
    );

    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key='+Constants.ServerToken,
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': '$message',
            'title': '$title'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': ''+widget._chatRoomId+","+widget._username,
            'id': '1',
            'status': 'done'
          },
          'to': token,
        },
      ),
    );
  }
}
