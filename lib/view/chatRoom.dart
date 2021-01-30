import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letschat/helper/Constants.dart';
import 'package:letschat/services/DataBaseMethod.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:letschat/view/viewImageBeforeUpload.dart';

class ChatRoom extends StatefulWidget {
  final String ChatRoomId,name;
  ChatRoom(this.ChatRoomId, this.name);
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  bool type=false;
  TextEditingController messageController=new TextEditingController();
  Stream chatMessageStream;
  bool dialVisible = true;
  FirebaseStorage _storage = FirebaseStorage.instance;
  bool isLoading;
  final GlobalKey _menuKey = new GlobalKey();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  ScrollController _myController = ScrollController();

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
    return Container(
      margin: EdgeInsets.only(bottom: 55),
      child: StreamBuilder(
        stream: chatMessageStream,
          builder: (context, snapshot){
            return snapshot.data != null ? ListView.builder(
              itemCount: snapshot.data.documents.length,
                controller: _myController,
                itemBuilder: (context,index){
                  return MessageTile(
                      snapshot.data.documents[index].get("message"),
                      snapshot.data.documents[index].get("sendBy")== Constants.MyName,
                      snapshot.data.documents[index].get("type"),
                    );
                }
            ):Container();
          }
      ),
    );
  }

  Future<void> sendMessage(String type,String content) async {
    if(content.isNotEmpty & content.trim().isNotEmpty){
      Map<String,dynamic> messageMap=new Map();
      messageMap["message"]=content;
      messageMap["sendBy"]=Constants.MyName;
      messageMap["type"]=type;
      messageMap["time"]=DateTime.now().millisecondsSinceEpoch;
      DataBaseMethods.sendConversationMessage(widget.ChatRoomId, messageMap);
      messageController.text="";
      String sendToken=await DataBaseMethods.getUserToken(Constants.Token);
      print(sendToken);
      sendAndRetrieveMessage(Constants.MyName, content,sendToken);
      // isLoading=false;
    }
  }

  Future<Map<String, dynamic>> sendAndRetrieveMessage(String title,String message,String token) async {
    await _firebaseMessaging.requestNotificationPermissions(
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
            'click_action': ''+widget.ChatRoomId+","+widget.name,
            'id': '1',
            'status': 'done'
          },
          'to': token,
        },
      ),
    );
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




  @override
  Widget build(BuildContext context) {
    Timer(Duration(milliseconds: 500), () => _myController.jumpTo(_myController.position.maxScrollExtent));
    return MaterialApp(
      home: new Scaffold(
        appBar: AppbarBuild(),
        body: Stack(
          children: [
            // buildLoading(),
            ChatMessageList(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width-65,
                    margin: EdgeInsets.symmetric(vertical: 3,horizontal: 5),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white
                          ],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(30))
                    ),
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
                            icon: Icon(
                                Icons.attachment_outlined,
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  isDismissible: true,
                                  builder: (builder) {
                                    return new Container(
                                      padding: EdgeInsets.all(5),
                                      height: 250.0,
                                      color: Color(0xFF737373),
                                      child: new Container(
                                          decoration: new BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: new BorderRadius.only(
                                                  topLeft: const Radius.circular(10.0), topRight: const Radius.circular(10.0))),
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:EdgeInsets.symmetric(horizontal: 23,vertical: 12),
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                             child: GestureDetector(
                                                              onTap:uploadImage,
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
                                                                    borderRadius: BorderRadius.circular(50)
                                                                ),
                                                                child: Icon(Icons.image,color: Colors.white,size: 30,),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 10,),
                                                          Text("Image")
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:EdgeInsets.symmetric(horizontal: 23,vertical: 12),
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            child: GestureDetector(
                                                              onTap:_takePhoto,
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
                                                                    borderRadius: BorderRadius.circular(50)
                                                                ),
                                                                child: Icon(Icons.camera_alt_outlined,color: Colors.white,size: 30,),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 10,),
                                                          Text("Camera")
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:EdgeInsets.symmetric(horizontal: 23,vertical: 12),
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            child: GestureDetector(
                                                              onTap:_recordVideo,
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
                                                                    borderRadius: BorderRadius.circular(50)
                                                                ),
                                                                child: Icon(Icons.videocam_outlined,color: Colors.white,size: 30,),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 10,),
                                                          Text("Video")
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:EdgeInsets.symmetric(horizontal: 23,vertical: 12),
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            child: GestureDetector(
                                                              onTap:()=> {},
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
                                                                    borderRadius: BorderRadius.circular(50)
                                                                ),
                                                                child: Icon(Icons.audiotrack_outlined,color: Colors.white,size: 30,),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 10,),
                                                          Text("Audio")
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:EdgeInsets.symmetric(horizontal: 23,vertical: 12),
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            child: GestureDetector(
                                                              onTap:()=> {},
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
                                                                    borderRadius: BorderRadius.circular(50)
                                                                ),
                                                                child: Icon(Icons.file_copy_outlined,color: Colors.white,size: 30,),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 10,),
                                                          Text("Documents")
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:EdgeInsets.symmetric(horizontal: 23,vertical: 12),
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            child: GestureDetector(
                                                              onTap:()=> {
                                                              },
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
                                                                    borderRadius: BorderRadius.circular(50)
                                                                ),
                                                                child: Icon(Icons.person,color: Colors.white,size: 30,),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 10,),
                                                          Text("Contact")
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )),
                                    );
                                  });
                            }),
                      ],
                    ),
                  ),
                  getSendAndRecordButton(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void uploadImage() async {
    //Get the file from the image picker and store it
    final pickedFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    Navigator.push(context, MaterialPageRoute(builder: (context)=>UploadImage(pickedFile, widget.ChatRoomId, widget.name)));
  }

  void _takePhoto() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    ImagePicker.pickImage(source: ImageSource.camera).then((File recordedImage) async {
      if (recordedImage != null && recordedImage.path != null) {
        Reference reference = _storage.ref().child("UserShareMedia").child(FirebaseAuth.instance.currentUser.uid).child("Image").child(fileName);
        UploadTask uploadTask = reference.putFile(recordedImage);
        String location = await uploadTask.then((ress) => ress.ref.getDownloadURL());
        if(location!=null) {
            sendMessage("image", location);
        }
        // GallerySaver.saveImage(recordedImage.path).then((path) {
        //   setState(() {
        //   });
        // });
      }
    });
  }
  void _recordVideo() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    ImagePicker.pickVideo(source: ImageSource.camera)
        .then((File recordedVideo) async {
      if (recordedVideo != null && recordedVideo.path != null) {
        Reference reference = _storage.ref().child("UserShareMedia").child(FirebaseAuth.instance.currentUser.uid).child("Video").child(fileName);
        // isLoading=true;
        UploadTask uploadTask = reference.putFile(recordedVideo);
        String location = await uploadTask.then((ress) => ress.ref.getDownloadURL());
        if(location!=null) {
          setState(() {
            sendMessage("video", location);
          });
        }

        GallerySaver.saveVideo(recordedVideo.path).then((path) {
          setState(() {
          });
        });
      }
    });
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

  getSendAndRecordButton() {
    messageController.addListener(() {
      if(messageController.text.isNotEmpty){
        setState(() {
          type=true;
        });
      }else{
        setState(() {
          type=false;
        });
      }
    });
    if(!type){
      return GestureDetector(
        onTap:()=> (){},
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    const Color(0xff007EF4),
                    const Color(0xff2A75BC),
                  ]
              ),
              borderRadius: BorderRadius.circular(30)
          ),
          padding: EdgeInsets.all(5),
          child: Icon(
            Icons.audiotrack_outlined,
            color: Colors.white,
          ),
        ),
      );
    }else{
      return GestureDetector(
        onTap:()=> sendMessage("message",messageController.text),
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    const Color(0xff007EF4),
                    const Color(0xff2A75BC),
                  ]
              ),
              borderRadius: BorderRadius.circular(30)
          ),
          padding: EdgeInsets.all(5),
          child: Icon(
            Icons.send,
            color: Colors.white,
          ),
        ),
      );
    }
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
      margin: EdgeInsets.symmetric(vertical: 5),
      width: MediaQuery.of(context).size.width,
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child:type=="message"? Container(
        height: 45,
        padding: EdgeInsets.symmetric(horizontal: 22,vertical: 14),
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
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15)
              ):
              BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15)
              )
        ),
        child:Text(message,style: TextStyle(
          color: Colors.white,
          fontSize: 16
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

