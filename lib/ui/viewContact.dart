import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:letschat/constant/Constants.dart';
import 'package:letschat/data/firestore/DataBaseMethod.dart';
import 'package:letschat/model/Contacts.dart';
import 'package:letschat/model/Users.dart';
import 'package:letschat/model/chatroomtile.dart';
import 'package:letschat/model/searchusers.dart';
import 'package:letschat/model/userlist.dart';
import 'package:letschat/utils/permissionhandler.dart';
import 'package:permission_handler/permission_handler.dart';

class ViewContact extends StatefulWidget {
  @override
  _ViewContactState createState() => _ViewContactState();
}

class _ViewContactState extends State<ViewContact> {
  PermissionHandler permissionHandler=new PermissionHandler();
  Iterable<Contact> contacts;
  Stream chatRoomStream;
  List<Contacts> contactList=List<Contacts>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarBuild(),
      backgroundColor: Colors.white,
      body: new Container(
        child: new Column(
          children: [
            getAllContact(),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    permissionHandler.getStroragePermission(Permission.contacts);
    getContact();
  }

  Widget AppbarBuild() {
    return AppBar(
      title: Text("Contacts"),
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
  Widget getAllContact() {
    return StreamBuilder(
        stream: chatRoomStream,
        builder: (context, snapshop) {
          return snapshop.hasData
              ? ListView.builder(
              itemCount: snapshop.data.documents.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if(GetComparelist(snapshop, index)){
                  return SearchUserList(
                    name: snapshop.data.documents[index].get("name"),
                    number: snapshop.data.documents[index].get("number"),
                    image: snapshop.data.documents[index].get("image"),
                    token: snapshop.data.documents[index].get("usertoken"),
                  );
                }else{
                  return Container();
                }
              })
              : Container();
        });
  }

  bool GetComparelist(snapshop,index){
    bool aa=false;
    for(int i=0;i<contactList.length;i++) {
      if(contactList[i].number==snapshop.data.documents[index].get("number") && snapshop.data.documents[index].get("number")!=Constants.MyNumber){
        aa=true;
        break;
      }else{
        aa=false;
      }
    }
    return aa;
  }

  getContact() async {
    contacts = await ContactsService.getContacts();
    splitContact();
    getData();
  }

  splitContact(){
    contacts.forEach((contact) async {
      if(contact.phones.isNotEmpty){
          contact.phones.toList().forEach((element) {
            String num=element.value.toString();
            String num1=num.split(" ").join("");
            if(num1.substring(0,1)!="+"){
              num1="+91"+num1;
            }
            var userContact = Contacts(
                contact.displayName,
                num1
            );
            contactList.add(userContact);
          });
      }
    });
  }
  getData() async {
    await DataBaseMethods.GetAllUser().then((value) {
      setState(() {
        chatRoomStream = value;
      });
    });
  }
}
