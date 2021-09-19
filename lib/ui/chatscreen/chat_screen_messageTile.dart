import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  final String message, type;
  final bool isSendByMe;
  bool downloading = false;
  var progress = "";
  var path = "No Data";
  var platformVersion = "Unknown";
  var _onPressed;
  static final Random random = Random();
  Directory externalDir;
  FirebaseStorage storage = FirebaseStorage.instance;

  MessageTile(this.message, this.isSendByMe, this.type);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
            left: isSendByMe ? 0 : 16, right: isSendByMe ? 16 : 0),
        margin: EdgeInsets.symmetric(vertical: 5),
        width: MediaQuery.of(context).size.width,
        alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: type == "message"
            ? Container(
                height: 45,
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSendByMe
                          ? [const Color(0xff007EF4), const Color(0xff2A75BC)]
                          : [const Color(0xff2A75BC), const Color(0xff2A75BC)],
                    ),
                    borderRadius: isSendByMe
                        ? BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15))
                        : BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15))),
                child: Text(
                  message,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ))
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSendByMe
                          ? [const Color(0xff007EF4), const Color(0xff2A75BC)]
                          : [const Color(0xff2A75BC), const Color(0xff2A75BC)],
                    ),
                    borderRadius: isSendByMe
                        ? BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10))
                        : BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10))),
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    width: 150.0,
                    height: 150.0,
                    padding: EdgeInsets.all(20.0),
                  ),
                  imageUrl: message,
                  width: 150.0,
                  height: 150.0,
                  fit: BoxFit.cover,
                )));
  }
}
