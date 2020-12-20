import 'package:flutter/material.dart';
import 'package:letschat/helper/Constants.dart';
import 'package:letschat/services/DataBaseMethod.dart';

class ChatRoom extends StatefulWidget {
  final String ChatRoomId;
  ChatRoom(this.ChatRoomId);
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {

  TextEditingController messageController=new TextEditingController();
  Stream chatMessageStream;

  Widget ChatMessageList(){
    return StreamBuilder(
      stream: chatMessageStream,
        builder: (context, snapshot){
          return snapshot.hasData != null ? ListView.builder(
            itemCount: snapshot.data.documents.length,
              itemBuilder: (context,index){
              return MessageTile(
                  snapshot.data.documents[index].get("message"),
                  snapshot.data.documents[index].get("sendBy")== Constants.MyName
              );
              }
          ):Container();
        }
    );
  }

  sendMessage(){
    if(messageController.text.isNotEmpty){
      Map<String,dynamic> messageMap=new Map();
      messageMap["message"]=messageController.text;
      messageMap["sendBy"]=Constants.MyName;
      messageMap["time"]=DateTime.now().millisecondsSinceEpoch;
      DataBaseMethods.sendConversationMessage(widget.ChatRoomId, messageMap);
      messageController.text="";
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getChat();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Scaffold(
        backgroundColor: Colors.black54,
        body: Stack(
          children: [
            ChatMessageList(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Color(0x54FFFFFF),
                padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                child: new Row(
                  children: [
                    Expanded(child: TextField(
                      style: TextStyle(color: Colors.black54),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.black54),
                        hintText: "Enter Message",
                        border: InputBorder.none
                      ),
                      controller: messageController,
                    )),
                    GestureDetector(
                      onTap: sendMessage,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0x36FFFFFF),
                              const Color(0x0FFFFFFF),
                            ]
                          ),
                          borderRadius: BorderRadius.circular(40)
                        ),
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.send),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  getChat() async{
    await DataBaseMethods.getConversationMessage(widget.ChatRoomId).then((value){
      setState(() {
        chatMessageStream=value;
      });
    });
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  MessageTile(this.message,this.isSendByMe);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: isSendByMe?0:24,right: isSendByMe?24:0),
      margin: EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width,
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24,vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSendByMe?[
              const Color(0xff007EF4),
              const Color(0xff2A75BC)
            ]:[
              const Color(0x1AFFFFFF),
              const Color(0x1AFFFFFF)
            ],
          ),
          borderRadius: isSendByMe?
              BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
                bottomLeft: Radius.circular(23)
              ):
              BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: Radius.circular(23)
              )
        ),
        child:Text(message,style: TextStyle(
          color: Colors.white,
          fontSize: 24
        ),)
      ),
    );
  }
}

