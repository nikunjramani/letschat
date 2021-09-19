import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomRepository {
  static getChatRooms(String username) async {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("users", arrayContains: username)
        .snapshots();
  }
}
