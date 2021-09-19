import 'package:equatable/equatable.dart';

class ChatRoomEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ChatRoomFetch extends ChatRoomEvent {
  String name;

  ChatRoomFetch({this.name});
}
