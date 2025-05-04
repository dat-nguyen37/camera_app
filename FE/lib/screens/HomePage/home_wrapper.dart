import 'package:camera_app/screens/HomePage/full_screen.dart';
import 'package:flutter/material.dart';
import 'home_main.dart';
import 'cameradetail.dart';

class HomeWrapper extends StatelessWidget {
  const HomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: HomeRoutes.home,
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case HomeRoutes.home:
            return MaterialPageRoute(
              builder: (_) => const Homepage(),
            );
          case HomeRoutes.detail:
            final args = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => CameraDetail(streamUrl: args),
            );
          case HomeRoutes.fullscreen:
            final args = settings.arguments as String;
            return MaterialPageRoute(
              builder:
                  (_) =>
                      FullscreenCameraPage(streamUrl: args),
            );
          default:
            return MaterialPageRoute(
              builder:
                  (_) => Scaffold(
                    body: Center(
                      child: Text('Page not found'),
                    ),
                  ),
            );
        }
      },
    );
  }
}

class HomeRoutes {
  static const String home = '/home_main';
  static const String detail = '/detail';
  static const String fullscreen = '/fullscreen';
}
