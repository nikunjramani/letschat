import 'dart:io';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letschat/helper/Constants.dart';
import 'package:letschat/services/DataBaseMethod.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class ChatRoom extends StatefulWidget {
  final String ChatRoomId,name;
  ChatRoom(this.ChatRoomId, this.name);
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {

  TextEditingController messageController=new TextEditingController();
  Stream chatMessageStream;
  bool dialVisible = true;
  FirebaseStorage _storage = FirebaseStorage.instance;
  bool isLoading;
  final GlobalKey _menuKey = new GlobalKey();

  // Widget buildLoading() {
  //   return Positioned(
  //     child: isLoading ? Container(
  //       color: Colors.lightBlue,
  //       child: Center(
  //         child: Loading(indicator: BallPulseIndicator(), size: 100.0,color: Colors.pink),
  //       ),
  //     ): Container(),
  //   );
  // }

  Widget ChatMessageList(){
    return StreamBuilder(
      stream: chatMessageStream,
        builder: (context, snapshot){
          return snapshot.data != null ? ListView.builder(
            itemCount: snapshot.data.documents.length,
              itemBuilder: (context,index){
              return MessageTile(
                  snapshot.data.documents[index].get("message"),
                  snapshot.data.documents[index].get("sendBy")== Constants.MyName,
                  snapshot.data.documents[index].get("type"),
                );
              }
          ):Container();
        }
    );
  }

  void sendMessage(String type,String content){
    if(content.isNotEmpty & content.trim().isNotEmpty){
      Map<String,dynamic> messageMap=new Map();
      messageMap["message"]=content;
      messageMap["sendBy"]=Constants.MyName;
      messageMap["type"]=type;
      messageMap["time"]=DateTime.now().millisecondsSinceEpoch;
      DataBaseMethods.sendConversationMessage(widget.ChatRoomId, messageMap);
      messageController.text="";
      // isLoading=false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // isLoading=false;
    getChat();
  }
  Widget AppbarBuild(){
    return AppBar(
      leading:  IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(widget.name),
      actions: <Widget>[
        // ClipRRect(
        //   borderRadius: BorderRadius.circular(50.0),
        //   child: Image.network(
        //     Constants.MyImage,
        //     width: 50.0,
        //     height: 40.0,
        //     fit: BoxFit.fill,
        //   ),
        // ),
      ],
    );
  }

  uploadImage() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final pickedFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    Reference reference = _storage.ref().child("UserShareMedia").child(FirebaseAuth.instance.currentUser.uid).child("Image").child(fileName);
    // isLoading=true;
    UploadTask uploadTask = reference.putFile(pickedFile);
    String location = await uploadTask.then((ress) => ress.ref.getDownloadURL());
    if(location!=null) {
      sendMessage("image", location);
    }
  }

  uploadVideo() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final pickedFile = await ImagePicker.pickVideo(source: ImageSource.gallery);
    Reference reference = _storage.ref().child("UserShareMedia").child(FirebaseAuth.instance.currentUser.uid).child("Video").child(fileName);
    // isLoading=true;
    UploadTask uploadTask = reference.putFile(pickedFile);
    String location = await uploadTask.then((ress) => ress.ref.getDownloadURL());
    if(location!=null) {
      sendMessage("video", location);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Scaffold(
        appBar: AppbarBuild(),
        body: Stack(
          children: [
            // buildLoading(),
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
                     IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (builder) {
                                return new Container(
                                  height: 200.0,
                                  color: Color(0xFF737373),
                                  child: new Container(
                                      decoration: new BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: new BorderRadius.only(
                                              topLeft: const Radius.circular(10.0), topRight: const Radius.circular(10.0))),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap:()=> uploadImage(),
                                                child: Container(
                                                  height: 60,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                          colors: [
                                                            const Color(0xff007EF4),
                                                            const Color(0xff2A75BC),
                                                          ]
                                                      ),
                                                      borderRadius: BorderRadius.circular(10)
                                                  ),
                                                  child: Icon(Icons.image,color: Colors.white,size: 40,),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap:()=> uploadVideo(),
                                                child: Container(
                                                  height: 60,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                          colors: [
                                                            const Color(0xff007EF4),
                                                            const Color(0xff2A75BC),
                                                          ]
                                                      ),
                                                      borderRadius: BorderRadius.circular(10)
                                                  ),
                                                  child: Icon(Icons.videocam_outlined,color: Colors.white,size: 40,),
                                                ),
                                              ),

                                            ],
                                          )
                                        ],
                                      )),
                                );
                              });
                        }),
                    GestureDetector(
                      onTap:()=> sendMessage("message",messageController.text),
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
                    ),
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
    // isLoading=true;
    await DataBaseMethods.getConversationMessage(widget.ChatRoomId).then((value){
      setState(() {
        chatMessageStream=value;
        // isLoading=false;
      });
    });
  }
}

class MessageTile extends StatelessWidget {
  final String message,type;
  final bool isSendByMe;
  MessageTile(this.message,this.isSendByMe, this.type);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: isSendByMe?0:16,right: isSendByMe?16:0),
      margin: EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width,
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child:type=="message"? Container(
        padding: EdgeInsets.symmetric(horizontal: 24,vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSendByMe?[
              const Color(0xff007EF4),
              const Color(0xff2A75BC)
            ]:[
              const Color(0xff2A75BC),
              const Color(0xff2A75BC)
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
                  bottomRight: Radius.circular(23)
              )
        ),
        child:Text(message,style: TextStyle(
          color: Colors.white,
          fontSize: 17
        ),)
      ):Container(
          padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSendByMe?[
                  const Color(0xff007EF4),
                  const Color(0xff2A75BC)
                ]:[
                  const Color(0xff2A75BC),
                  const Color(0xff2A75BC)
                ],
              ),
              borderRadius: isSendByMe?
              BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10)
              ):
              BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10)
              )
          ),
          child:CachedNetworkImage(
            placeholder: (context, url) => Container(
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor:
                AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              width: 150.0,
              height: 150.0,
              padding: EdgeInsets.all(20.0),
            ),
            imageUrl: message,
            width: 150.0,
            height: 150.0,
            fit: BoxFit.cover,
          )
      )
    );
  }
}

