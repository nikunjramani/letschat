import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letschat/ui/chatroom/chat_room.dart';
import 'package:letschat/ui/splash/splash_page.dart';

import 'authenticate/authentication_bloc.dart';
import 'authenticate/authentication_event.dart';
import 'authenticate/authentication_state.dart';
import 'data/login_repository.dart';
import 'simple_bloc_observer.dart';
import 'ui/login/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  LoginRepository userRepository = LoginRepository();
  Bloc.observer = SimpleBlocObserver();
  runApp(BlocProvider(
    create: (context) => AuthenticationBloc(userRepository)..add(AppStarted()),
    child: MyApp(userRepository: userRepository),
  ));
}

class MyApp extends StatefulWidget {
  final LoginRepository _userRepository;

  MyApp({Key key, @required LoginRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  LoginRepository get userRepository => widget._userRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is Uninitialized) {
            return SplashPage();
          } else if (state is Unauthenticated) {
            return LoginPage(
              userRepository: userRepository,
            );
          } else if (state is Authenticated) {
            return ChatRoom();
          } else {
            return SplashPage();
          }
        },
      ),
    );
  }
}
