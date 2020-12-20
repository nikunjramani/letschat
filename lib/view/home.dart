import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:letschat/helper/Constants.dart';
import 'package:letschat/helper/HelperFunction.dart';
import 'package:letschat/services/DataBaseMethod.dart';
import 'package:letschat/view/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chatRoom.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SearchBar searchBar;
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DataBaseMethods dataBaseMethods=new DataBaseMethods();
  QuerySnapshot UserList;

  Stream chatRoomStream;

  Widget chatRoomList(){
    return StreamBuilder(
      stream: chatRoomStream,
        builder: (context,snapshop){
          return snapshop.hasData?ListView.builder(
              itemCount: snapshop.data.documents.length,
              itemBuilder: (context,index){
                return ChatRoomTile(
                    snapshop.data.documents[index].get("chatroomId")
                        .toString().replaceAll("_", "")
                        .replaceAll(Constants.MyName, ""),
                    snapshop.data.documents[index].get("chatroomId")
                );
              }):Container();
        }
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
        title: new Text('LetsChat'),
        actions: [
          searchBar.getSearchAction(context),
        ]
    );
  }

 void onSubmitted(String value) {
    if(value!=null) {
      DataBaseMethods.GetUserByName(value).then((val) {
        setState(() {
          UserList = val;
        });
      });
    }
  }
  Widget SearchList(){
    return UserList!=null ? ListView.builder(
        itemCount: UserList.documents.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return SearchUserList(
            name: UserList.documents[index].get("name"),
            number: UserList.documents[index].get("number"),
            image: UserList.documents[index].get("image"),
          );
        },
      ):Container();
      print(UserList);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: searchBar.build(context),
        key: _scaffoldKey,
        body: Container(
          child:Column(
            children: [
              SearchList(),
              chatRoomList()
            ],
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
            onDisplayChange: (isOpen) {
            },
            children: <Widget>[
              RawMaterialButton(
                onPressed: () {
                  fabKey.currentState.close();

                },
                shape: CircleBorder(),
                padding: const EdgeInsets.all(24.0),
                child: Icon(Icons.settings, color: Colors.lightBlueAccent),
              ),
              RawMaterialButton(
                onPressed: () {
                  fabKey.currentState.close();
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>new Profile()));
                },
                shape: CircleBorder(),
                padding: const EdgeInsets.all(24.0),
                child: Icon(Icons.person, color: Colors.lightBlueAccent),
              ),
              RawMaterialButton(
                onPressed: () {
                  fabKey.currentState.close();
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
    // Constants.MyName=HelperFunction.getUserNameSharedPreference();
    searchBar = new SearchBar(
        inBar: false,
        setState: setState,
        onChanged: onSubmitted,
        buildDefaultAppBar: buildAppBar,
        onCleared: () {print("cleared");},
        onClosed: () {}
        );


  }

  getData() async{
    DataBaseMethods.getChatRooms(Constants.MyName).then((value){
      setState(() {
        chatRoomStream=value;
      });
    });
  }

  getUserInfo() async {
    Constants.MyName=await HelperFunction.getUserNameSharedPreference();
    Constants.MyNumber=await HelperFunction.getUserNumberSharedPreference();
    Constants.MyDob=await HelperFunction.getUserDobSharedPreference();
    Constants.MyImage=await HelperFunction.getUserImageSharedPreference();
    Constants.MyAvoutMe=await HelperFunction.getUserAboutSharedPreference();
    print(Constants.MyName);
  }
}

class SearchUserList extends StatelessWidget {
  String name,number,image;
  String chatRoomId;
  SearchUserList({this.name,this.number,this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap:(){
          print(Constants.MyName);
          chatRoomId=getChatRoomId(name,Constants.MyName);
          List<String> user=[name,Constants.MyName];

          Map<String,dynamic> chatRoomMap=new Map();
          chatRoomMap['users']=user;
          chatRoomMap['chatroomId']=chatRoomId;

          DataBaseMethods.createChatRoom(chatRoomId, chatRoomMap);

          Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatRoom(chatRoomId)));
        } ,
        child: Container(
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: Image.network(
                  image,
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.fill,
                ),
              ),
              Column(
                children: [
                  Text(name),
                  Text(number)
                ],
              ),
            ],
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

class ChatRoomTile extends StatelessWidget {
  final String username,chatRoom;
  ChatRoomTile(this.username, this.chatRoom);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatRoom(chatRoom)));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24,vertical: 16),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(48),
              ),
              child: Text("${username.substring(0,1).toUpperCase()}"),
            ),
            SizedBox(width: 8,),
            Text(username)
          ],
        ),
      ),
    );
  }
}


