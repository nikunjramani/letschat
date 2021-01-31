import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:letschat/constant/Constants.dart';

Future<Map<String, dynamic>> sendAndRetrieveMessage(String title,String message,String token,String name,String ChatRoomId) async {
  await FirebaseMessaging().requestNotificationPermissions(
    const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),
  );

  await http.post(
    'https://fcm.googleapis.com/fcm/send',
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'key='+Constants.ServerToken,
    },
    body: jsonEncode(
      <String, dynamic>{
        'notification': <String, dynamic>{
          'body': '$message',
          'title': '$title'
        },
        'priority': 'high',
        'data': <String, dynamic>{
          'click_action': ''+ChatRoomId+","+name,
          'id': '1',
          'status': 'done'
        },
        'to': token,
      },
    ),
  );
}