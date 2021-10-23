import 'package:equatable/equatable.dart';

class ChatScreenEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ChatScreenFetchEvent extends ChatScreenEvent {
  String chatRoomId;

  ChatScreenFetchEvent(this.chatRoomId);
}

class ChatScreenSendMessageEvent extends ChatScreenEvent {
  String chatRoomId,message,type,sendBy;

  ChatScreenSendMessageEvent(
      this.chatRoomId, this.message, this.type, this.sendBy);
}

class ChatScreenSendNotificationEvent extends ChatScreenEvent {
  String chatRoomId;
  Map<String, String> messageMap;

  ChatScreenSendNotificationEvent(this.chatRoomId, this.messageMap);
}
