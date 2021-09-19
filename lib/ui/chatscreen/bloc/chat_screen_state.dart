import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class ChatScreenState extends Equatable {}

class FetchCompletedState extends ChatScreenState {
  Stream<dynamic> _stream;

  FetchCompletedState(this._stream);

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
