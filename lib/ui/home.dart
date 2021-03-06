import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:letschat/constant/Constants.dart';
import 'package:letschat/data/localdatabase/FileFunction.dart';
import 'package:letschat/data/sharedprefe/shared_preference.dart';
import 'package:letschat/model/chatroomtile.dart';
import 'package:letschat/model/userlist.dart';
import 'package:letschat/data/firestore/DataBaseMethod.dart';
import 'package:letschat/ui/login.dart';
import 'package:letschat/ui/profile.dart';
import 'package:letschat/ui/viewContact.dart';
import 'package:letschat/utils/permissionhandler.dart';
import 'package:letschat/widget/homewidgets.dart';

import 'chatRoom.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SearchBar searchBar;
  PermissionHandler permissionHandler=new PermissionHandler();
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DataBaseMethods dataBaseMethods = new DataBaseMethods();
  Stream chatRoomStream;
  FileHelperFunction _fileHelperFunction = new FileHelperFunction();
  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Widget chatRoomList() {
    return StreamBuilder(
        stream: chatRoomStream,
        builder: (context, snapshop) {
          return snapshop.hasData
              ? ListView.builder(
                  itemCount: snapshop.data.documents.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
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

  Widget AppbarBuild() {
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
            return {'New Group', 'New Broadcast','Favorite Message','Setting'}.map((String choice) {
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
    await HelperFunction.saveUserLoginSharedPreference(false);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => new LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppbarBuild(),
        key: _scaffoldKey,
        body: Container(
          child: Column(
            children: [chatRoomList()],
          ),
        ),
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
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo();
    initiNotification();
    permissionHandler.getAllRequirePermission();
    // _fileHelperFunction.createFolders();
    // Constants.MyName=HelperFunction.getUserNameSharedPreference();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        setState(() {});
        createNotification(message);
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
      });
    });
  }

  getUserInfo() async {
    Constants.MyName = await HelperFunction.getUserNameSharedPreference();
    Constants.MyNumber = await HelperFunction.getUserNumberSharedPreference();
    Constants.MyDob = await HelperFunction.getUserDobSharedPreference();
    Constants.MyImage = await HelperFunction.getUserImageSharedPreference();
    Constants.MyAvoutMe = await HelperFunction.getUserAboutSharedPreference();
    getData();
  }

  Future<void> initiNotification() async {
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

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ChatRoom(chatId, username)));
    }
  }
}