import 'package:camera_app/screens/HomePage/full_screen.dart';
import 'package:camera_app/screens/main.dart';
import 'package:camera_app/screens/signin.dart';
import 'package:camera_app/screens/signup.dart';
import 'package:flutter/material.dart';

class AppRoute {
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String main = '/home';
  static const String detail = '/detail';

  static Route<dynamic> generateRoute(
    RouteSettings settings,
  ) {
    switch (settings.name) {
      case signup:
        return MaterialPageRoute(builder: (_) => Signup());
      case signin:
        return MaterialPageRoute(builder: (_) => Signin());
      case main:
        return MaterialPageRoute(
          builder: (_) => MainPageView(),
        );
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(child: Text('NOT FOUND')),
              ),
        );
    }
  }
}
