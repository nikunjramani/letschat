import 'dart:async';

import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:letschat/ui/chatroom/bloc/bloc.dart';
import 'package:letschat/ui/chatroom/chat_room_tile.dart';
import 'package:letschat/ui/contact/view_contact.dart';
import 'package:letschat/ui/login/login_page.dart';
import 'package:letschat/ui/profile/profile.dart';
import 'package:letschat/ui/searchuser/search_user_list.dart';
import 'package:letschat/ui/signin/SignIn.dart';
import 'package:letschat/utils/constants.dart';
import 'package:letschat/utils/firestore_provider.dart';
import 'package:letschat/utils/notification_utils.dart';
import 'package:letschat/utils/permission_handler.dart';
import 'package:letschat/utils/preference_utils.dart';

import '../chatscreen/chat_screen.dart';

class ChatRoom extends StatelessWidget {
  const ChatRoom({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatRoomBloc>(
        create: (context) => ChatRoomBloc(name: Constants.MyName),
        child: Scaffold(
          body: ChatRoomWidget(),
        ));
  }
}

class ChatRoomWidget extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoomWidget> {
  SearchBar searchBar;
  PermissionHandler permissionHandler = new PermissionHandler();
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DataBaseMethods dataBaseMethods = new DataBaseMethods();
  Stream chatRoomStream;
  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  ChatRoomBloc _chatRoomBloc;

  Widget chatRoomList(Stream chatRoom) {
    return StreamBuilder(
        stream: chatRoom,
        builder: (context, snapshop) {
          return snapshop.hasData
              ? ListView.builder(
                  itemCount: snapshop.data.documents.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    print(snapshop.data.documents[index].get("chatroomId"));
                    return ChatRoomTile(
                        snapshop.data.documents[index]
                            .get("chatroomId")
                            .toString()
                            .replaceAll("_", "")
                            .replaceAll(Constants.MyName, ""),
                        snapshop.data.documents[index].get("chatroomId"));
                  })
              : Container();
        });
  }

  Widget appbarBuild() {
    return AppBar(
      title: Text("Letschat"),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.search,
          ),
          onPressed: () {
            showSearch(
              context: context,
              delegate: CustomSearchDelegate(),
            );
          },
        ),
        PopupMenuButton<String>(
          onSelected: handleClick,
          itemBuilder: (BuildContext context) {
            return {'New Group', 'New Broadcast', 'Favorite Message', 'Setting'}
                .map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
      ],
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'New Group':
        break;
      case 'Settings':
        break;
      case 'New Broadcast':
        break;
      case 'Favorite Message':
        break;
    }
  }

  signOut() async {
    await auth.signOut();
    await PreferenceUtils.setBoolean(
        Constants.sharedPreferenceUserLogInKey, false);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => new SignIn()));
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return BlocBuilder<ChatRoomBloc, ChatRoomState>(builder: (context, state) {
        return Scaffold(
          appBar: appbarBuild(),
          key: _scaffoldKey,
          body: Container(child: getViewAsPerState(state)),
          floatingActionButton: Builder(
            builder: (context) => FabCircularMenu(
              key: fabKey,
              // Cannot be `Alignment.center`
              alignment: Alignment.bottomRight,
              ringColor: Colors.white.withAlpha(25),
              ringDiameter: 500.0,
              ringWidth: 150.0,
              fabSize: 64.0,
              fabElevation: 8.0,
              fabIconBorder: CircleBorder(),
              fabColor: Colors.white,
              fabOpenIcon: Icon(Icons.menu, color: primaryColor),
              fabCloseIcon: Icon(Icons.close, color: primaryColor),
              fabMargin: const EdgeInsets.all(16.0),
              animationDuration: const Duration(milliseconds: 800),
              animationCurve: Curves.easeInOutCirc,
              onDisplayChange: (isOpen) {},
              children: <Widget>[
                RawMaterialButton(
                  onPressed: signOut,
                  shape: CircleBorder(),
                  padding: const EdgeInsets.all(24.0),
                  child: Icon(Icons.logout, color: Colors.lightBlueAccent),
                ),
                RawMaterialButton(
                  onPressed: () {
                    fabKey.currentState.close();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => new Profile()));
                  },
                  shape: CircleBorder(),
                  padding: const EdgeInsets.all(24.0),
                  child: Icon(Icons.person, color: Colors.lightBlueAccent),
                ),
                RawMaterialButton(
                  onPressed: () {
                    fabKey.currentState.close();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ViewContact()));
                  },
                  shape: CircleBorder(),
                  padding: const EdgeInsets.all(24.0),
                  child: Icon(Icons.chat, color: Colors.lightBlueAccent),
                )
              ],
            ),
          ),
        );
      });
  }

  getViewAsPerState(ChatRoomState state) {
    if (state is ChatRoomFetchCompleted) {
      print(state.getStream());
      return chatRoomList(state.getStream());
    } else if (state is LoadingState) {
      return LoadingIndicator();
    } else {
      return LoadingIndicator();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _chatRoomBloc = BlocProvider.of<ChatRoomBloc>(context);


    super.initState();
    getUserInfo();
    initNotification();
    permissionHandler.getAllRequirePermission();
    // _fileHelperFunction.createFolders();
    // Constants.MyName=HelperFunction.getUserNamePreferenceUtils();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        setState(() {});
        NotificationUtils.createNotification(message);
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        setState(() {});
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        setState(() {});
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        Constants.Token = token;
        print(token);
      });
    });

  }

  getData() async {
    await DataBaseMethods.getChatRooms(Constants.MyName).then((value) {
      setState(() {
        chatRoomStream = value;
        print(chatRoomStream);
      });
    });
  }

  getUserInfo() async {
    Constants.MyName =
        await PreferenceUtils.getString(Constants.sharedPreferenceUserName);
    Constants.MyNumber =
        await PreferenceUtils.getString(Constants.sharedPreferenceUserNumber);
    Constants.MyDob =
        await PreferenceUtils.getString(Constants.sharedPreferenceUserDob);
    Constants.MyImage =
        await PreferenceUtils.getString(Constants.sharedPreferenceUserImage);
    Constants.MyAvoutMe =
        await PreferenceUtils.getString(Constants.sharedPreferenceUserAbout);
    _chatRoomBloc.add(ChatRoomFetch(name:Constants.MyName));
  }

  Future<void> initNotification() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("userprofile");
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(onDidReceiveLocalNotification: null);
    final MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
      print(payload);
      var parts = payload.split(',');
      var chatId = parts[0].trim();
      var username = parts.sublist(1).join(':').trim();

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatScreen(chatId, username)));
    }
  }
}
