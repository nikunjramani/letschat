import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:letschat/helper/Constants.dart';
import 'package:letschat/helper/HelperFunction.dart';
import 'package:letschat/main.dart';
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
  Stream chatRoomStream;
  FirebaseAuth auth = FirebaseAuth.instance;

  Widget chatRoomList(){
    return StreamBuilder(
      stream: chatRoomStream,
        builder: (context,snapshop){
          return snapshop.hasData?ListView.builder(
              itemCount: snapshop.data.documents.length,
              shrinkWrap: true,
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
  Widget AppbarBuild(){
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
      ],
    );
  }
  signOut() async {
    await auth.signOut();
    await HelperFunction.saveUserLoginSharedPreference(false);
    Navigator.push(context, MaterialPageRoute(builder: (context)=>new MyApp()));
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
          child:Column(
            children: [
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
                onPressed: signOut,
                shape: CircleBorder(),
                padding: const EdgeInsets.all(24.0),
                child: Icon(Icons.logout, color: Colors.lightBlueAccent),
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
  }

  getData() async{
    await DataBaseMethods.getChatRooms(Constants.MyName).then((value){
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
    getData();
  }
}

class ChatRoomTile extends StatelessWidget {
  final String username,chatRoom;
  ChatRoomTile(this.username, this.chatRoom);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatRoom(chatRoom,username)));
      },
      child: Card(
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
              Text(username,style: TextStyle(
                  fontSize: 17
              ))
            ],
          ),
        ),
      ),
    );
  }
}


class CustomSearchDelegate extends SearchDelegate {

  QuerySnapshot userList;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    print(query);

    DataBaseMethods.GetUserByName(query).then((val) {
      userList=val;
    });

    if(userList!=null){
      return Container(
          child: ListView.builder(
            itemCount: userList.documents.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return SearchUserList(
                name: userList.documents[index].get("name"),
                number: userList.documents[index].get("number"),
                image: userList.documents[index].get("image"),
              );
            },
          )
      );
    }else{
      return Container();
    }

  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.

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

        Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatRoom(chatRoomId,name)));
      } ,
      child:Card(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24,vertical: 16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: Image.network(
                  image,
                  width: 40.0,
                  height: 40.0,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(width: 8,),
              Text(name,style: TextStyle(
                  fontSize: 17
              )),
              Text(name,style: TextStyle(
                  fontSize: 17
              ))
            ],
          ),
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
