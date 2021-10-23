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
  static getUserToken(String token) async {
    var querySnap = await FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("userToken", arrayContains: token)
        .get();
    List userToken =
    querySnap.docs.map((snap) => snap.get("userToken")).toList();

    if (userToken[0][0] == token) {
      return userToken[0][1];
    } else {
      return userToken[0][0];
    }
  }
}
