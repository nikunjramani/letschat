import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class ChatRoomState extends Equatable {}

class ChatRoomFetchCompleted extends ChatRoomState {
  Stream _stream;

  ChatRoomFetchCompleted(this._stream);
  Stream getStream() {
    return _stream;
  }

  @override
  List<Object> get props => [_stream];
}

class LoadingState extends ChatRoomState {
  @override
  List<Object> get props => [];
}
