
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:letschat/ui/chatRoom.dart';

class ChatRoomTile extends StatelessWidget {
  final String username, chatRoom;

  ChatRoomTile(this.username, this.chatRoom);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatRoom(chatRoom, username)));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(48),
              ),
              child: Text("${username.substring(0, 1).toUpperCase()}"),
            ),
            SizedBox(
              width: 8,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              width: MediaQuery.of(context).size.width - 100,
              decoration: new BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1.0, color: Colors.grey),
                ),
              ),
              child: Text(username, style: TextStyle(fontSize: 17)),
            ),
          ],
        ),
      ),
    );
  }
}
