import 'dart:async';
import 'dart:io';

import 'package:emoji_picker/emoji_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letschat/ui/chatscreen/bloc/bloc.dart';
import 'package:letschat/ui/chatscreen/chat_screen_messageTile.dart';
import 'package:letschat/ui/chatscreen/view_image_before_upload.dart';
import 'package:letschat/utils/common_utils.dart';
import 'package:letschat/utils/common_widgets.dart';
import 'package:letschat/utils/constants.dart';
import 'package:letschat/utils/firestore_provider.dart';
import 'package:letschat/utils/notification_utils.dart';
import 'package:letschat/utils/progress_utils.dart';

class ChatScreen extends StatelessWidget {
  final String ChatRoomId, name;

  ChatScreen(this.ChatRoomId, this.name);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatScreenBloc>(
        create: (context) => ChatScreenBloc(ChatRoomId, name),
        child: Scaffold(
          body: ChatScreenWidget(ChatRoomId, name),
        ));
  }
}

class ChatScreenWidget extends StatefulWidget {
  final String ChatRoomId, name;

  ChatScreenWidget(this.ChatRoomId, this.name);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreenWidget> {
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
  ChatScreenBloc _chatScreenBloc;

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
  @override
  Widget build(BuildContext context) {
    Timer(Duration(milliseconds: 500),
        () => _myController.jumpTo(_myController.position.maxScrollExtent));
    return Scaffold(
      body: WillPopScope(
        onWillPop: onBackPress,
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatScreenBloc, ChatScreenState>(
                  builder: (context, state) {
                if (state is ChatScreenFetchCompletedState) {
                  return _chatMessageList(state.getStream());
                } else if (state is LoadingState) {
                  return LoadingIndicator();
                } else {
                  return LoadingIndicator();
                }
              }),
            ),
            buildChatController(),
            (isShowSticker ? Container(child: buildSticker()) : Container()),
          ],
        ),
      ),
    );
  }

  Widget _chatMessageList(props) {
    return Container(
      child: StreamBuilder(
          stream: props,
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
      NotificationUtils.sendAndRetrieveMessage(
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
    // getChat();
    _chatScreenBloc = context.read<ChatScreenBloc>();
    _chatScreenBloc.add(ChatScreenFetchEvent(widget.ChatRoomId));
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
                        CommonUtils.hideKeyboard(textFieldFocus);
                        showEmojiContainer();
                      } else {
                        CommonUtils.showKeyboard(textFieldFocus);

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
                                            CommonWidgets
                                                .chatScreenBottomSheetComponent(
                                                    "Image",
                                                    Icons.image,
                                                    uploadImage),
                                            CommonWidgets
                                                .chatScreenBottomSheetComponent(
                                                    "Camera",
                                                    Icons.camera_alt_outlined,
                                                    _takePhoto),
                                            CommonWidgets
                                                .chatScreenBottomSheetComponent(
                                                    "Video",
                                                    Icons.videocam_outlined,
                                                    _recordVideo),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            CommonWidgets
                                                .chatScreenBottomSheetComponent(
                                                    "Audio",
                                                    Icons.audiotrack_outlined,
                                                    uploadImage),
                                            CommonWidgets
                                                .chatScreenBottomSheetComponent(
                                                    "Documents",
                                                    Icons.file_copy_outlined,
                                                    uploadImage),
                                            CommonWidgets
                                                .chatScreenBottomSheetComponent(
                                                    "Contact",
                                                    Icons.person,
                                                    uploadImage),
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

  void uploadImage() async {
    final pickedFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ViewImageBeforeUpload(
                pickedFile, widget.ChatRoomId, widget.name)));
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

  // getChat() async {
  //   // isLoading=true;
  //   await DataBaseMethods.getConversationMessage(widget.ChatRoomId)
  //       .then((value) {
  //     setState(() {
  //       chatMessageStream = value;
  //       // isLoading=false;
  //     });
  //   });
  // }

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
        onTap: () => {
          // sendMessage("message", messageController.text),
        _chatScreenBloc.add(ChatScreenSendMessageEvent(widget.ChatRoomId,messageController.text,"message",Constants.MyName))

      },
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
