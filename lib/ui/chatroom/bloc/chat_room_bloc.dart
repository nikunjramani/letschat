import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:letschat/data/chat_room_repository.dart';
import 'package:letschat/ui/chatroom/bloc/bloc.dart';

class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  final String _name;

  ChatRoomBloc({@required String name})
      : assert(name != null),
        _name = name,
        super(null);
  // ChatRoomBloc get initialState => null;

  @override
  Stream<ChatRoomState> mapEventToState(ChatRoomEvent event) async* {
    if (event is ChatRoomFetch) {
      yield ChatRoomFetchCompleted(await _fetchChat(event.name));
    }else{
      throw UnimplementedError();
    }
  }

  _fetchChat(String name) async {
    return await ChatRoomRepository.getChatRooms(name);
  }
}
