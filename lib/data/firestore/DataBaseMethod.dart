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
  static GetAllUser() async{
    return await Firestore.instance.collection("User")
        .snapshots();
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

  static getUserToken(String token) async {
    var querySnap= await Firestore.instance
        .collection("ChatRoom")
        .where("userToken",arrayContains: token)
        .get();

    List userToken=querySnap.documents
        .map((snap) => snap.get("userToken"))
        .toList();

    if(userToken[0][0]==token){
      return userToken[0][1];
    }else{
      return userToken[0][0];
    }
  }

}