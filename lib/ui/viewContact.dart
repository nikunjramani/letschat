import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

class ViewContact extends StatefulWidget {
  @override
  _ViewContactState createState() => _ViewContactState();
}

class _ViewContactState extends State<ViewContact> {
  Iterable<Contact> contacts;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(

      ),
    );
  }
  getAllContact() async {
    contacts = await ContactsService.getContacts();
    print(contacts.toString());
    print("aa");
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllContact();
  }
}
