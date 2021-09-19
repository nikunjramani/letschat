import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreenRepository {
  static getConversationMessage(String chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("Chats")
        .orderBy("time", descending: false)
        .snapshots();
  }

  static sendConversationMessage(
      String chatRoomId, Map<String, String> messageMap) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("Chats")
        .add(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }
}
