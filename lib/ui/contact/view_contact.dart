import 'dart:async';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:letschat/model/contacts.dart';
import 'package:letschat/ui/searchuser/search_user.dart';
import 'package:letschat/ui/searchuser/search_user_list.dart';
import 'package:letschat/utils/constants.dart';
import 'package:letschat/utils/firestore_provider.dart';
import 'package:letschat/utils/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart';

class ViewContact extends StatefulWidget {
  @override
  _ViewContactState createState() => _ViewContactState();
}

class _ViewContactState extends State<ViewContact> {
  PermissionHandler permissionHandler = new PermissionHandler();
  Iterable<Contact> contacts;
  Stream chatRoomStream;
  List<Contacts> contactList = <Contacts>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarBuild(),
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
    permissionHandler.getStoragePermission(Permission.contacts);
    getContact();
  }

  Widget appbarBuild() {
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

  Widget getAllContact() {
    return StreamBuilder(
        stream: chatRoomStream,
        builder: (context, snapshop) {
          return snapshop.hasData
              ? ListView.builder(
                  itemCount: snapshop.data.documents.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    if (getCompareList(snapshop, index)) {
                      return SearchUser(
                        name: snapshop.data.documents[index].get("name"),
                        number: snapshop.data.documents[index].get("number"),
                        image: snapshop.data.documents[index].get("image"),
                        token: snapshop.data.documents[index].get("usertoken"),
                      );
                    } else {
                      return Container();
                    }
                  })
              : Container();
        });
  }

  bool getCompareList(snapshop, index) {
    bool aa = false;
    for (int i = 0; i < contactList.length; i++) {
      if (contactList[i].number ==
              snapshop.data.documents[index].get("number") &&
          snapshop.data.documents[index].get("number") != Constants.MyNumber) {
        aa = true;
        break;
      } else {
        aa = false;
      }
    }
    return aa;
  }

  getContact() async {
    contacts = await ContactsService.getContacts();
    splitContact();
    getData();
  }

  splitContact() {
    contacts.forEach((contact) async {
      if (contact.phones.isNotEmpty) {
        contact.phones.toList().forEach((element) {
          String num = element.value.toString();
          String num1 = num.split(" ").join("");
          if (num1.substring(0, 1) != "+") {
            num1 = "+91" + num1;
          }
          contactList.add(new Contacts(contact.displayName, num1));
        });
      }
    });
  }

  getData() async {
    await DataBaseMethods.getAllUser().then((value) {
      setState(() {
        chatRoomStream = value;
      });
    });
  }
}
