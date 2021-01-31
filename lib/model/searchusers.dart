
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:letschat/constant/Constants.dart';
import 'package:letschat/data/firestore/DataBaseMethod.dart';
import 'package:letschat/ui/chatRoom.dart';

class SearchUserList extends StatelessWidget {
  String name,number,image,token;
  String chatRoomId;
  SearchUserList({this.name,this.number,this.image,this.token});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:(){
        chatRoomId=getChatRoomId(name,Constants.MyName);
        List<String> user=[name,Constants.MyName];
        var parts = chatRoomId.split('_');
        var user1 = parts[0].trim();
        var user2 = parts.sublist(1).join(':').trim();

        List<String> userToken=new List();
        if(user1!=Constants.MyName){
          userToken=[token,Constants.Token];
        }else{
          userToken=[FirebaseMessaging().getToken().toString(),token];
        }

        // List<String> userToken=[FirebaseMessaging().getToken().toString(),FirebaseMessaging().getToken().toString()];

        Map<String,dynamic> chatRoomMap=new Map();
        chatRoomMap['users']=user;
        chatRoomMap["userToken"]=userToken;
        chatRoomMap['chatroomId']=chatRoomId;

        DataBaseMethods.createChatRoom(chatRoomId, chatRoomMap);

        Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatRoom(chatRoomId,name)));
      } ,
      child:Card(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24,vertical: 16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: Image.network(
                  image,
                  width: 40.0,
                  height: 40.0,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(width: 8,),
              Text(name,style: TextStyle(
                  fontSize: 17
              )),
              Text(name,style: TextStyle(
                  fontSize: 17
              ))
            ],
          ),
        ),
      ),
    );
  }

  getChatRoomId(String user1,String user2){
    if(user1.substring(0,1).codeUnitAt(0)>user2.substring(0,1).codeUnitAt(0)){
      return "$user2\_$user1";
    }else{
      return "$user1\_$user2";
    }
  }
}