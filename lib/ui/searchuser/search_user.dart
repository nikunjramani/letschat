import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:letschat/ui/chatscreen/chat_screen.dart';
import 'package:letschat/utils/constants.dart';
import 'package:letschat/utils/firestore_provider.dart';

class SearchUser extends StatelessWidget {
  String name, number, image, token;
  String chatRoomId;

  SearchUser({this.name, this.number, this.image, this.token});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: GestureDetector(
        onTap: () {
          chatRoomId = getChatRoomId(name, Constants.MyName);
          List<String> user = [name, Constants.MyName];
          var parts = chatRoomId.split('_');
          var user1 = parts[0].trim();
          var user2 = parts.sublist(1).join(':').trim();

          List<String> userToken = [];
          if (user1 != Constants.MyName) {
            userToken = [token, Constants.Token];
          } else {
            userToken = [FirebaseMessaging().getToken().toString(), token];
          }

          // List<String> userToken=[FirebaseMessaging().getToken().toString(),FirebaseMessaging().getToken().toString()];

          Map<String, dynamic> chatRoomMap = new Map();
          chatRoomMap['users'] = user;
          chatRoomMap["userToken"] = userToken;
          chatRoomMap['chatroomId'] = chatRoomId;

          DataBaseMethods.createChatRoom(chatRoomId, chatRoomMap);

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatScreen(chatRoomId, name)));
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: Image.network(
                  image,
                  width: 45.0,
                  height: 45.0,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    width: MediaQuery.of(context).size.width - 110,
                    decoration: new BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1.0, color: Colors.grey),
                      ),
                    ),
                    child: Text(name, style: TextStyle(fontSize: 17)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  getChatRoomId(String user1, String user2) {
    if (user1.substring(0, 1).codeUnitAt(0) >
        user2.substring(0, 1).codeUnitAt(0)) {
      return "$user2\_$user1";
    } else {
      return "$user1\_$user2";
    }
  }
}
