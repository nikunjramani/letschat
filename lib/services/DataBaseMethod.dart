import 'package:cloud_firestore/cloud_firestore.dart';

class DataBaseMethods{
  static GetUserByNumber(String  number){
    Firestore.instance.collection("User")
        .where("number",isEqualTo: number)
        .get();
  }
  static GetUserByName(String name) async {
    return await Firestore.instance.collection("User")
        .where("name",isEqualTo: name)
        .get();
  }
  static uploadUserInfo(UserMap){
    Firestore.instance.collection("User").
    add(UserMap);
  }

  static createChatRoom(String chatRoomId,chatRoomMap){
    Firestore.instance.collection("ChatRoom").document(chatRoomId).setData(chatRoomMap).catchError((e){
      print(e.toString());
    });
  }
  static sendConversationMessage(String chatRoomId,messageMap){
    Firestore.instance.collection("ChatRoom")
        .document(chatRoomId)
        .collection("Chats")
        .add(messageMap).catchError((e){print(e.toString());});
  }
  static getConversationMessage(String chatRoomId) async {
    return await Firestore.instance.collection("ChatRoom")
        .document(chatRoomId)
        .collection("Chats")
        .orderBy("time",descending: false)
        .snapshots();
  }

  static getChatRooms(String username) async {
    return await Firestore.instance
        .collection("ChatRoom")
        .where("users",arrayContains: username)
        .snapshots();
  }

}