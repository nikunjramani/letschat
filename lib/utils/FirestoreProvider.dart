import 'package:cloud_firestore/cloud_firestore.dart';

class DataBaseMethods {
  static getUserByNumber(String number) {
    FirebaseFirestore.instance
        .collection("User")
        .where("number", isEqualTo: number)
        .get();
  }

  static getUserByName(String name) async {
    return await FirebaseFirestore.instance
        .collection("User")
        .where("name", isEqualTo: name)
        .get();
  }

  static getAllUser() async {
    return FirebaseFirestore.instance.collection("User").snapshots();
  }

  static uploadUserInfo(userMap) {
    FirebaseFirestore.instance.collection("User").add(userMap);
  }

  static createChatRoom(String chatRoomId, chatRoomMap) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .set(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  static sendConversationMessage(String chatRoomId, messageMap) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("Chats")
        .add(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  static getConversationMessage(String chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("Chats")
        .orderBy("time", descending: false)
        .snapshots();
  }

  static getChatRooms(String username) async {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("users", arrayContains: username)
        .snapshots();
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
