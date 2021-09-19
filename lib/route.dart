import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:letschat/data/user_repository.dart';
import 'package:letschat/ui/chatroom/chat_room.dart';
import 'package:letschat/ui/login/login_page.dart';
import 'package:letschat/ui/splash/splash_page.dart';

const String LOGIN_PAGE = "/login";
const String SPLASH_PAGE = "/";
const String HOME_PAGE = "/home";
const String USER_DETAIL = "/user_detail";

class Router {
  static final userRepository =
      UserRepository(firebaseAuth: FirebaseAuth.instance);

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case LOGIN_PAGE:
        return MaterialPageRoute(
            builder: (BuildContext context) =>
                LoginPage(userRepository: userRepository));
      case HOME_PAGE:
        return MaterialPageRoute(builder: (_) => ChatRoom());
      case SPLASH_PAGE:
        return MaterialPageRoute(builder: (_) => SplashPage());

      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
