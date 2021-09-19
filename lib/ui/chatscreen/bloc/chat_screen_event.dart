import 'package:equatable/equatable.dart';

class ChatScreenEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ChatScreenFetch extends ChatScreenEvent {
  String chatRoomId;

  ChatScreenFetch(this.chatRoomId);
}

class ChatScreenSendMessage extends ChatScreenEvent {
  String chatRoomId;
  Map<String, String> messageMap;

  ChatScreenSendMessage(this.chatRoomId, this.messageMap);
}
