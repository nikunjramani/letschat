import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class ChatScreenState extends Equatable {}

class ChatScreenFetchCompletedState extends ChatScreenState {
  Stream<dynamic> _stream;

  ChatScreenFetchCompletedState(this._stream);

  Stream getStream() {
    return _stream;
  }
  @override
  List<Object> get props => [_stream];
}

class LoadingState extends ChatScreenState {
  @override
  List<Object> get props => [];
}

class ChatScreenSendMessageState extends ChatScreenState {
  bool isSuccess;

  ChatScreenSendMessageState(this.isSuccess);

  @override
  List<Object> get props => [];
}
