import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:letschat/utils/Constants.dart';

class NotificationUtils {
  static Future sendAndRetrieveMessage(String title, String message,
      String token, String name, String chatRoomId) async {
    await FirebaseMessaging().requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );

    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=' + Constants.ServerToken,
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': '$message',
            'title': '$title'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': '' + chatRoomId + "," + name,
            'id': '1',
            'status': 'done'
          },
          'to': token,
        },
      ),
    );
  }

  static void createNotification(Map<String, dynamic> message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    var flutterLocalNotificationsPlugin;
    await flutterLocalNotificationsPlugin.show(
        0,
        message["notification"]["title"],
        message["notification"]["body"],
        platformChannelSpecifics,
        payload: message["data"]["click_action"]);
  }
}
