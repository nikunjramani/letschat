import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letschat/constant/Constants.dart';
import 'package:letschat/model/messagetile.dart';
import 'package:letschat/data/firestore/DataBaseMethod.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:letschat/utils/notification.dart';
import 'package:letschat/ui/viewImageBeforeUpload.dart';

class ChatRoom extends StatefulWidget {
  final String ChatRoomId, name;

  ChatRoom(this.ChatRoomId, this.name);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  bool type = false;
  bool isShowSticker;
  bool isKeyboardVisible = false;
  TextEditingController messageController = new TextEditingController();
  Stream chatMessageStream;
  bool dialVisible = true;
  FirebaseStorage _storage = FirebaseStorage.instance;
  bool isLoading;
  final GlobalKey _menuKey = new GlobalKey();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  ScrollController _myController = ScrollController();
  FocusNode textFieldFocus = FocusNode();

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

  Widget ChatMessageList() {
    return Container(
      child: StreamBuilder(
          stream: chatMessageStream,
          builder: (context, snapshot) {
            return snapshot.data != null
                ? ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    controller: _myController,
                    itemBuilder: (context, index) {
                      return MessageTile(
                        snapshot.data.documents[index].get("message"),
                        snapshot.data.documents[index].get("sendBy") ==
                            Constants.MyName,
                        snapshot.data.documents[index].get("type"),
                      );
                    })
                : Container();
          }),
    );
  }

  Future<void> sendMessage(String type, String content) async {
    if (content.isNotEmpty & content.trim().isNotEmpty) {
      Map<String, dynamic> messageMap = new Map();
      messageMap["message"] = content;
      messageMap["sendBy"] = Constants.MyName;
      messageMap["type"] = type;
      messageMap["time"] = DateTime.now().millisecondsSinceEpoch;
      DataBaseMethods.sendConversationMessage(widget.ChatRoomId, messageMap);
      messageController.text = "";
      String sendToken = await DataBaseMethods.getUserToken(Constants.Token);
      print(sendToken);
      sendAndRetrieveMessage(
          Constants.MyName, content, sendToken, widget.name, widget.ChatRoomId);
      // isLoading=false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isShowSticker = false;
    // isLoading=false;
    getChat();
  }

  Widget AppbarBuild() {
    return AppBar(
      leading: FlatButton(
        shape: CircleBorder(),
        padding: const EdgeInsets.only(left: 2.0),
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Row(
          children: [
            Icon(
              Icons.arrow_back,
              size: 24.0,
              color: Colors.white,
            ),
            CircleAvatar(
              radius: 15.0,
              backgroundImage: NetworkImage(Constants.MyImage),
            ),
          ],
        ),
      ),
      title: Text(widget.name),
      actions: <Widget>[
        PopupMenuButton<String>(
          onSelected: handleClick,
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(value: "Profile Info", child: Text("Profile Info")),
            PopupMenuItem(value: "Media", child: Text("Media")),
            PopupMenuItem(value: "Search", child: Text("Search")),
            PopupMenuItem(value: "Notification", child: Text("Notification")),
            PopupMenuItem(value: "WallPepar", child: Text("WallPepar")),
          ],
        ),
      ],
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Profile Info':
        break;
      case 'Media':
        break;
      case 'Notification':
        break;
      case 'WallPepar':
        break;
      case 'Search':
        break;
    }
  }

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer() {
    setState(() {
      isShowSticker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      isShowSticker = true;
    });
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  Widget buildSticker() {
    return EmojiPicker(
      rows: 4,
      columns: 7,
      buttonMode: ButtonMode.MATERIAL,
      recommendKeywords: ["face"],
      numRecommended: 50,
      onEmojiSelected: (emoji, category) {
        messageController.text = messageController.text + emoji.emoji;
      },
    );
  }

  Widget buildChatController() {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Row(
        children: [
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width - 65,
            margin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white],
                ),
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: new Row(
              children: [
                IconButton(
                  icon: Icon(Icons.emoji_emotions_sharp),
                  onPressed: () {
                    setState(() {
                      if (!isShowSticker) {
                        hideKeyboard();
                        showEmojiContainer();
                      } else {
                        showKeyboard();
                        hideEmojiContainer();
                      }
                    });
                  },
                ),
                Expanded(
                    child: TextField(
                  focusNode: textFieldFocus,
                  style: TextStyle(color: Colors.black54),
                  decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.black54),
                      hintText: "Enter Message",
                      border: InputBorder.none),
                  controller: messageController,
                  onTap: () {
                    hideEmojiContainer();
                  },
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
                                          topLeft: const Radius.circular(10.0),
                                          topRight:
                                              const Radius.circular(10.0))),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 23, vertical: 12),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    child: GestureDetector(
                                                      onTap: uploadImage,
                                                      child: Container(
                                                        height: 60,
                                                        width: 60,
                                                        decoration:
                                                            BoxDecoration(
                                                                gradient:
                                                                    LinearGradient(
                                                                        colors: [
                                                                      const Color(
                                                                          0xff007EF4),
                                                                      const Color(
                                                                          0xff2A75BC),
                                                                    ]),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50)),
                                                        child: Icon(
                                                          Icons.image,
                                                          color: Colors.white,
                                                          size: 30,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text("Image")
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 23, vertical: 12),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    child: GestureDetector(
                                                      onTap: _takePhoto,
                                                      child: Container(
                                                        height: 60,
                                                        width: 60,
                                                        decoration:
                                                            BoxDecoration(
                                                                gradient:
                                                                    LinearGradient(
                                                                        colors: [
                                                                      const Color(
                                                                          0xff007EF4),
                                                                      const Color(
                                                                          0xff2A75BC),
                                                                    ]),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50)),
                                                        child: Icon(
                                                          Icons
                                                              .camera_alt_outlined,
                                                          color: Colors.white,
                                                          size: 30,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text("Camera")
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 23, vertical: 12),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    child: GestureDetector(
                                                      onTap: _recordVideo,
                                                      child: Container(
                                                        height: 60,
                                                        width: 60,
                                                        decoration:
                                                            BoxDecoration(
                                                                gradient:
                                                                    LinearGradient(
                                                                        colors: [
                                                                      const Color(
                                                                          0xff007EF4),
                                                                      const Color(
                                                                          0xff2A75BC),
                                                                    ]),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50)),
                                                        child: Icon(
                                                          Icons
                                                              .videocam_outlined,
                                                          color: Colors.white,
                                                          size: 30,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text("Video")
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 23, vertical: 12),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    child: GestureDetector(
                                                      onTap: () => {},
                                                      child: Container(
                                                        height: 60,
                                                        width: 60,
                                                        decoration:
                                                            BoxDecoration(
                                                                gradient:
                                                                    LinearGradient(
                                                                        colors: [
                                                                      const Color(
                                                                          0xff007EF4),
                                                                      const Color(
                                                                          0xff2A75BC),
                                                                    ]),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50)),
                                                        child: Icon(
                                                          Icons
                                                              .audiotrack_outlined,
                                                          color: Colors.white,
                                                          size: 30,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text("Audio")
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 23, vertical: 12),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    child: GestureDetector(
                                                      onTap: () => {},
                                                      child: Container(
                                                        height: 60,
                                                        width: 60,
                                                        decoration:
                                                            BoxDecoration(
                                                                gradient:
                                                                    LinearGradient(
                                                                        colors: [
                                                                      const Color(
                                                                          0xff007EF4),
                                                                      const Color(
                                                                          0xff2A75BC),
                                                                    ]),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50)),
                                                        child: Icon(
                                                          Icons
                                                              .file_copy_outlined,
                                                          color: Colors.white,
                                                          size: 30,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text("Documents")
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 23, vertical: 12),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    child: GestureDetector(
                                                      onTap: () => {},
                                                      child: Container(
                                                        height: 60,
                                                        width: 60,
                                                        decoration:
                                                            BoxDecoration(
                                                                gradient:
                                                                    LinearGradient(
                                                                        colors: [
                                                                      const Color(
                                                                          0xff007EF4),
                                                                      const Color(
                                                                          0xff2A75BC),
                                                                    ]),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50)),
                                                        child: Icon(
                                                          Icons.person,
                                                          color: Colors.white,
                                                          size: 30,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    Timer(Duration(milliseconds: 500),
        () => _myController.jumpTo(_myController.position.maxScrollExtent));
    return Scaffold(
      appBar: AppbarBuild(),
      body: WillPopScope(
        child: Column(
          children: <Widget>[
            // buildLoading(),
            Expanded(
              child: ChatMessageList(),
            ),
            buildChatController(),
            (isShowSticker ? Container(child: buildSticker()) : Container()),
          ],
        ),
        onWillPop: onBackPress,
      ),
    );
  }

  void uploadImage() async {
    final pickedFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                UploadImage(pickedFile, widget.ChatRoomId, widget.name)));
  }

  void _takePhoto() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    ImagePicker.pickImage(source: ImageSource.camera)
        .then((File recordedImage) async {
      if (recordedImage != null && recordedImage.path != null) {
        Reference reference = _storage
            .ref()
            .child("UserShareMedia")
            .child(FirebaseAuth.instance.currentUser.uid)
            .child("Image")
            .child(fileName);
        UploadTask uploadTask = reference.putFile(recordedImage);
        String location =
            await uploadTask.then((ress) => ress.ref.getDownloadURL());
        if (location != null) {
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
        Reference reference = _storage
            .ref()
            .child("UserShareMedia")
            .child(FirebaseAuth.instance.currentUser.uid)
            .child("Video")
            .child(fileName);
        // isLoading=true;
        UploadTask uploadTask = reference.putFile(recordedVideo);
        String location =
            await uploadTask.then((ress) => ress.ref.getDownloadURL());
        if (location != null) {
          setState(() {
            sendMessage("video", location);
          });
        }

        GallerySaver.saveVideo(recordedVideo.path).then((path) {
          setState(() {});
        });
      }
    });
  }

  getChat() async {
    // isLoading=true;
    await DataBaseMethods.getConversationMessage(widget.ChatRoomId)
        .then((value) {
      setState(() {
        chatMessageStream = value;
        // isLoading=false;
      });
    });
  }

  getSendAndRecordButton() {
    messageController.addListener(() {
      if (messageController.text.isNotEmpty) {
        setState(() {
          type = true;
        });
      } else {
        setState(() {
          type = false;
        });
      }
    });
    if (!type) {
      return GestureDetector(
        onTap: () => () {},
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                const Color(0xff007EF4),
                const Color(0xff2A75BC),
              ]),
              borderRadius: BorderRadius.circular(30)),
          padding: EdgeInsets.all(5),
          child: Icon(
            Icons.audiotrack_outlined,
            color: Colors.white,
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => sendMessage("message", messageController.text),
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                const Color(0xff007EF4),
                const Color(0xff2A75BC),
              ]),
              borderRadius: BorderRadius.circular(30)),
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
