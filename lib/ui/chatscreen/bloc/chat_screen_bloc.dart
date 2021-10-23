import 'package:bloc/bloc.dart';
import 'package:letschat/data/chat_screen_repository.dart';
import 'package:letschat/ui/chatscreen/bloc/bloc.dart';
import 'package:letschat/utils/constants.dart';
import 'package:letschat/utils/firestore_provider.dart';
import 'package:letschat/utils/notification_utils.dart';

class ChatScreenBloc extends Bloc<ChatScreenEvent, ChatScreenState> {
  final String chatRoomId, name;

  ChatScreenBloc(this.chatRoomId, this.name) : super(null);

  ChatScreenBloc get initialState => null;

  @override
  Stream<ChatScreenState> mapEventToState(ChatScreenEvent event) async* {
    // TODO: implement mapEventToState

    if (event is ChatScreenFetchEvent) {
      yield ChatScreenFetchCompletedState(await _fetchChat(event.chatRoomId));
    }else if(event is ChatScreenSendMessageEvent){
      yield ChatScreenSendMessageState(await _sendMessage(event.chatRoomId,event.type,event.message,event.sendBy));
    }
    else{
      throw UnimplementedError();
    }
  }

  _fetchChat(String chatRoomId) async {
    return await ChatScreenRepository.getConversationMessage(chatRoomId);
  }

  Future<bool> _sendMessage(String _chatRoomId,String _type, String _message,String _sendBy) async {
      Map<String, dynamic> messageMap = new Map();
      messageMap["message"] = _message;
      messageMap["sendBy"] = _sendBy;
      messageMap["type"] = _type;
      messageMap["time"] = DateTime.now().millisecondsSinceEpoch;
      ChatScreenRepository.sendConversationMessage(chatRoomId, messageMap);
      String sendToken = await ChatScreenRepository.getUserToken(Constants.Token);
      NotificationUtils.sendAndRetrieveMessage(
          Constants.MyName, _message, sendToken, name, chatRoomId);
      return true;
  }
}
