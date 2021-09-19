import 'package:bloc/bloc.dart';
import 'package:letschat/data/chat_screen_repository.dart';
import 'package:letschat/ui/chatscreen/bloc/bloc.dart';

class ChatScreenBloc extends Bloc<ChatScreenEvent, ChatScreenState> {
  final String chatRoomId, name;

  ChatScreenBloc(this.chatRoomId, this.name) : super(null);

  ChatScreenBloc get initialState => null;

  @override
  Stream<ChatScreenState> mapEventToState(ChatScreenEvent event) async* {
    // TODO: implement mapEventToState

    if (event is ChatScreenFetch) {
      yield FetchCompletedState(await _fetchChat(event.chatRoomId));
    }else if(event is ChatScreenSendMessage){

    }
    else{
      throw UnimplementedError();
    }
  }

  _fetchChat(String chatRoomId) async {
    return await ChatScreenRepository.getConversationMessage(chatRoomId);
  }
}
