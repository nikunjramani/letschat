import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void createNotification(Map<String, dynamic> message) async{
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
      0, message["notification"]["title"], message["notification"]["body"], platformChannelSpecifics,
      payload: message["data"]["click_action"]);
}
